"""Scan scoped dirs into the manifest.

Fast path: a file whose (path, size, mtime_ns) matches is skipped without
reading a byte, so re-scans of the whole library are sub-second. New or
touched files fall through to partial-fingerprint relink, then full hash.
Files already wearing a conforming name are recorded as applied on first
sight — the guarantee that old, done files are never re-proposed.
"""

import os
import unicodedata
from pathlib import Path

from booklib import config, hashing


def _norm(path):
    return unicodedata.normalize("NFC", str(path))


def _is_dataless(st):
    """macOS online-only placeholder: nonzero size, zero allocated blocks."""
    return st.st_size > 0 and getattr(st, "st_blocks", 1) == 0


def scan(manifest, dirs=None, rebuild=False):
    dirs = dirs or config.scoped_dirs()
    stats = {"known": 0, "new": 0, "relinked": 0, "conforming": 0, "dataless": [], "new_shas": []}
    if rebuild:
        manifest.db.execute("DELETE FROM paths")

    to_hash = []  # (path, size, mtime_ns, kind, partial)
    seen = set()
    for d in dirs:
        for entry in sorted(os.scandir(d), key=lambda e: e.name):
            p = Path(entry.path)
            if not entry.is_file() or p.suffix.lower() not in config.EXTS:
                continue
            path = _norm(p)
            seen.add(path)
            st = entry.stat()
            if _is_dataless(st):
                stats["dataless"].append(path)
                continue
            if manifest.fastpath_sha(path, st.st_size, st.st_mtime_ns):
                stats["known"] += 1
                continue
            kind = p.suffix.lower().lstrip(".")
            partial = hashing.partial_fingerprint(path, st.st_size)
            sha = manifest.sha_for_partial(partial, st.st_size)
            if sha:  # moved or touched file, content already known
                manifest.link_path(path, sha, st.st_mtime_ns, st.st_size)
                stats["relinked"] += 1
                row = manifest.metadata_row(sha)
                if row and (
                    row["status"] in ("pending", "failed")
                    # Known content wearing the wrong name (re-downloaded or
                    # hand-renamed copy of an applied book): back to work.
                    or (row["status"] == "applied" and row["final_stem"]
                        and p.stem != row["final_stem"])
                ):
                    stats["new_shas"].append(sha)
                _protect_conforming(manifest, sha, p, stats)
                continue
            to_hash.append((path, st.st_size, st.st_mtime_ns, kind, partial))

    for (path, size, mtime_ns, kind, partial), sha in zip(
        to_hash, hashing.hash_many([t[0] for t in to_hash]).values()
    ):
        manifest.upsert_file(sha, size, partial, kind)
        manifest.link_path(path, sha, mtime_ns, size)
        stats["new"] += 1
        stats["new_shas"].append(sha)
        _protect_conforming(manifest, sha, Path(path), stats)

    # Drop path rows whose file vanished from the scanned dirs (manual
    # deletions); sweep uses the count to know the bib needs regenerating.
    stats["pruned"] = 0
    for d in dirs:
        for known in manifest.paths_under(str(d)):
            if known not in seen and not os.path.exists(known):
                manifest.unlink_path(known)
                stats["pruned"] += 1

    manifest.commit()
    return stats


def _protect_conforming(manifest, sha, p, stats):
    """A file already named to convention is done — record it so no future
    run ever proposes renaming it."""
    row = manifest.metadata_row(sha)
    if row and row["status"] == "pending" and config.CONFORMING.fullmatch(p.name):
        manifest.mark_applied(sha, p.stem)
        stats["conforming"] += 1
