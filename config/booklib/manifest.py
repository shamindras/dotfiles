"""SQLite manifest — the pipeline's incremental memory.

Keyed by content SHA-256 so files are recognized across moves/renames; the
(path, size, mtime_ns) index makes re-scans a stat sweep. Lives OUTSIDE
Dropbox (config.MANIFEST_DB) because syncing a live SQLite file corrupts.
Rebuildable: names on disk + books.bib are the durable artifacts.
"""

import sqlite3
from datetime import datetime, timezone

from booklib import config

_SCHEMA = """
CREATE TABLE files (
    sha256 TEXT PRIMARY KEY, size INTEGER NOT NULL, partial_hash TEXT NOT NULL,
    kind TEXT NOT NULL, first_seen TEXT NOT NULL, last_verified TEXT NOT NULL);
CREATE INDEX idx_files_partial ON files (partial_hash, size);
CREATE TABLE paths (
    path TEXT PRIMARY KEY, sha256 TEXT NOT NULL REFERENCES files (sha256),
    mtime_ns INTEGER NOT NULL, size INTEGER NOT NULL);
CREATE INDEX idx_paths_sha ON paths (sha256);
CREATE TABLE metadata (
    sha256 TEXT PRIMARY KEY REFERENCES files (sha256),
    authors_json TEXT, title TEXT, subtitle TEXT, publisher TEXT,
    edition_year INTEGER, first_pub_year INTEGER, year_evidence TEXT,
    isbn13 TEXT, doi TEXT, source TEXT, confidence INTEGER,
    status TEXT NOT NULL DEFAULT 'pending',
    proposed_stem TEXT, final_stem TEXT, resolved_at TEXT);
CREATE TABLE conversions (
    src_sha256 TEXT PRIMARY KEY, dst_sha256 TEXT,
    pages_src INTEGER, pages_dst INTEGER,
    ocr_applied INTEGER NOT NULL DEFAULT 0, has_text_layer INTEGER);
CREATE TABLE events (
    id INTEGER PRIMARY KEY, ts TEXT NOT NULL, op TEXT NOT NULL,
    src TEXT, dst TEXT, sha256 TEXT);
CREATE TABLE backups (
    id INTEGER PRIMARY KEY, ts TEXT NOT NULL, dest TEXT NOT NULL,
    files INTEGER, bytes INTEGER, verified INTEGER NOT NULL DEFAULT 0);
"""

STATUSES = ("pending", "resolved", "needs_review", "approved", "applied", "skipped", "failed")


def now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


class Manifest:
    def __init__(self, db_path=None):
        db_path = db_path or config.MANIFEST_DB
        db_path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(db_path)
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA foreign_keys=ON")
        self.db.execute("PRAGMA busy_timeout=30000")
        self._migrate()

    def _migrate(self):
        (version,) = self.db.execute("PRAGMA user_version").fetchone()
        if version < 1:
            self.db.executescript(_SCHEMA)
            self.db.execute(f"PRAGMA user_version = {config.SCHEMA_VERSION}")
            self.db.commit()

    def close(self):
        self.db.close()

    # -- files / paths ------------------------------------------------------

    def fastpath_sha(self, path, size, mtime_ns):
        row = self.db.execute(
            "SELECT sha256 FROM paths WHERE path=? AND size=? AND mtime_ns=?",
            (path, size, mtime_ns),
        ).fetchone()
        return row["sha256"] if row else None

    def sha_for_partial(self, partial, size):
        rows = self.db.execute(
            "SELECT sha256 FROM files WHERE partial_hash=? AND size=?", (partial, size)
        ).fetchall()
        return rows[0]["sha256"] if len(rows) == 1 else None

    def upsert_file(self, sha, size, partial, kind):
        self.db.execute(
            "INSERT INTO files (sha256, size, partial_hash, kind, first_seen, last_verified)"
            " VALUES (?,?,?,?,?,?)"
            " ON CONFLICT(sha256) DO UPDATE SET last_verified=excluded.last_verified",
            (sha, size, partial, kind, now(), now()),
        )
        self.db.execute(
            "INSERT OR IGNORE INTO metadata (sha256, status) VALUES (?, 'pending')", (sha,)
        )

    def link_path(self, path, sha, mtime_ns, size):
        self.db.execute(
            "INSERT INTO paths (path, sha256, mtime_ns, size) VALUES (?,?,?,?)"
            " ON CONFLICT(path) DO UPDATE SET sha256=excluded.sha256,"
            " mtime_ns=excluded.mtime_ns, size=excluded.size",
            (path, sha, mtime_ns, size),
        )

    def unlink_path(self, path):
        self.db.execute("DELETE FROM paths WHERE path=?", (path,))

    def paths_under(self, prefix):
        return [
            r["path"]
            for r in self.db.execute(
                "SELECT path FROM paths WHERE path LIKE ?", (prefix.rstrip("/") + "/%",)
            )
        ]

    def path_for_sha(self, sha):
        row = self.db.execute("SELECT path FROM paths WHERE sha256=?", (sha,)).fetchone()
        return row["path"] if row else None

    def paths_for_sha(self, sha):
        """All paths holding this content — duplicate copies across dirs are
        legitimate (e.g. a backlog copy of a reference book) and every copy
        gets the canonical name in its own directory."""
        return [
            r["path"]
            for r in self.db.execute(
                "SELECT path FROM paths WHERE sha256=? ORDER BY path", (sha,)
            )
        ]

    def first_seen(self, sha):
        row = self.db.execute("SELECT first_seen FROM files WHERE sha256=?", (sha,)).fetchone()
        return row["first_seen"] if row else None

    # -- metadata -----------------------------------------------------------

    def metadata_row(self, sha):
        return self.db.execute("SELECT * FROM metadata WHERE sha256=?", (sha,)).fetchone()

    def set_metadata(self, sha, **fields):
        assert fields
        cols = ", ".join(f"{k}=?" for k in fields)
        self.db.execute(f"UPDATE metadata SET {cols} WHERE sha256=?", (*fields.values(), sha))

    def mark_applied(self, sha, stem):
        self.set_metadata(sha, status="applied", final_stem=stem, resolved_at=now())

    def rows_with_status(self, *statuses):
        marks = ",".join("?" for _ in statuses)
        return self.db.execute(
            f"SELECT m.*, f.kind FROM metadata m JOIN files f USING (sha256)"
            f" WHERE m.status IN ({marks}) ORDER BY m.sha256",
            statuses,
        ).fetchall()

    def status_counts(self):
        return {
            r["status"]: r["n"]
            for r in self.db.execute("SELECT status, COUNT(*) n FROM metadata GROUP BY status")
        }

    def stem_taken(self, stem, kind=None):
        """Holder of a stem; kind-scoped when given — a pdf and an epub may
        legitimately share a stem (format twins, e.g. koul-2026-*.pdf/.epub).
        Only rows with a surviving path count: deleting a book frees its
        stem for a replacement copy."""
        if kind:
            row = self.db.execute(
                "SELECT m.sha256 FROM metadata m JOIN files f USING (sha256)"
                " JOIN paths p USING (sha256)"
                " WHERE (m.proposed_stem=? OR m.final_stem=?) AND f.kind=? LIMIT 1",
                (stem, stem, "pdf" if kind == "djvu" else kind),
            ).fetchone()
        else:
            row = self.db.execute(
                "SELECT m.sha256 FROM metadata m JOIN paths p USING (sha256)"
                " WHERE m.proposed_stem=? OR m.final_stem=? LIMIT 1",
                (stem, stem),
            ).fetchone()
        return row["sha256"] if row else None

    # -- conversions --------------------------------------------------------

    def conversion_row(self, src_sha):
        return self.db.execute(
            "SELECT * FROM conversions WHERE src_sha256=?", (src_sha,)
        ).fetchone()

    def record_conversion(self, src_sha, dst_sha, pages_src, pages_dst, ocr, has_text):
        self.db.execute(
            "INSERT INTO conversions"
            " (src_sha256, dst_sha256, pages_src, pages_dst, ocr_applied, has_text_layer)"
            " VALUES (?,?,?,?,?,?) ON CONFLICT(src_sha256) DO UPDATE SET"
            " dst_sha256=excluded.dst_sha256, pages_src=excluded.pages_src,"
            " pages_dst=excluded.pages_dst, ocr_applied=excluded.ocr_applied,"
            " has_text_layer=excluded.has_text_layer",
            (src_sha, dst_sha, pages_src, pages_dst, int(ocr), has_text),
        )

    def unconverted_djvu(self):
        return self.db.execute(
            "SELECT m.*, f.kind FROM metadata m JOIN files f USING (sha256)"
            " LEFT JOIN conversions c ON c.src_sha256 = m.sha256"
            " WHERE f.kind='djvu' AND c.dst_sha256 IS NULL ORDER BY m.sha256"
        ).fetchall()

    # -- events / backups ---------------------------------------------------

    def record_event(self, op, src, dst, sha):
        self.db.execute(
            "INSERT INTO events (ts, op, src, dst, sha256) VALUES (?,?,?,?,?)",
            (now(), op, src, dst, sha),
        )

    def events_reversed(self, limit):
        return self.db.execute(
            "SELECT * FROM events ORDER BY id DESC LIMIT ?", (limit,)
        ).fetchall()

    def record_backup(self, dest, files, nbytes, verified):
        self.db.execute(
            "INSERT INTO backups (ts, dest, files, bytes, verified) VALUES (?,?,?,?,?)",
            (now(), dest, files, nbytes, int(verified)),
        )

    def latest_verified_backup(self):
        return self.db.execute(
            "SELECT * FROM backups WHERE verified=1 ORDER BY ts DESC LIMIT 1"
        ).fetchone()

    def commit(self):
        self.db.commit()
