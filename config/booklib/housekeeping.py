"""Janitor: sweep away pipeline litter. Runs at the end of every arrival
sweep (leader `RCmd → r → m`) and manually via `book-librarian clean`.

Conservative by construction — only exact temp patterns, orphaned
quarantine files, review batches with no still-pending rows, and empty
scaffolding dirs. Never touches books."""

import csv
import os

from booklib import config

_TEMP_GLOBS = ("*.pdf.part", "*.pdf.sub", "*.pdf.part.*", "*.blg", "tmp*.bib.tmp")


def clean(manifest):
    removed = []

    # 1. Conversion/validation temp files in the library root and scoped dirs.
    for d in [config.BOOKS_ROOT] + config.scoped_dirs():
        for pattern in _TEMP_GLOBS:
            for p in d.glob(pattern):
                p.unlink()
                removed.append(str(p))

    # 2. Quarantined conversions whose source content no longer exists.
    if config.FAILED_DIR.is_dir():
        for p in config.FAILED_DIR.iterdir():
            stem = p.name.split(".")[0]
            alive = manifest.db.execute(
                "SELECT 1 FROM metadata m JOIN paths p USING (sha256)"
                " WHERE m.final_stem=? OR m.proposed_stem=? LIMIT 1",
                (stem, stem),
            ).fetchone()
            if not alive:
                p.unlink()
                removed.append(str(p))

    # 3. Review batches where no row is still awaiting a decision.
    if config.REVIEW_DIR.is_dir():
        for batch in config.REVIEW_DIR.glob("batch-*.tsv"):
            with open(batch, newline="") as fh:
                sha12s = [r.get("sha12", "").strip() for r in csv.DictReader(fh, delimiter="\t")]
            pending = any(
                manifest.db.execute(
                    "SELECT 1 FROM metadata WHERE sha256 LIKE ? AND status='needs_review'",
                    (s + "%",),
                ).fetchone()
                for s in sha12s if s
            )
            if not pending:
                batch.unlink()
                removed.append(str(batch))

    # 4. Empty scaffolding dirs (recreated on demand).
    for d in (config.FAILED_DIR, config.REVIEW_DIR, config.BOOKLIB_DIR):
        try:
            d.rmdir()
        except OSError:
            pass

    return removed
