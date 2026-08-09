"""Paths, thresholds, and scope for booklib.

Everything env-overridable so fixtures can point the whole pipeline at a
scratch tree (BOOKLIB_ROOT / BOOKLIB_STATE_DIR / BOOKLIB_CACHE_DIR), same
pattern as MOVE_BOOKS_* in config/bin/move-books.

The manifest/undo/lock live OUTSIDE Dropbox on purpose (live SQLite + file
sync corrupts). Review TSVs, quarantine, djvu_originals, and books.bib live
INSIDE the library so they sync. If the library or config ever moves off
Dropbox, re-audit this split (see auto-memory: booklib-manifest-outside-dropbox).
"""

import os
import re
import subprocess
from pathlib import Path

# Hammerspoon's hs.task spawns with a bare PATH (/usr/bin:/bin:...), so the
# leader-key sweep can't find pdftotext/ddjvu/biber by name. Extend PATH once
# at import so every subprocess call works headless (same reason move-books
# hardcodes /opt/homebrew/bin/fd).
for _extra in ("/opt/homebrew/bin", "/Library/TeX/texbin"):
    if _extra not in os.environ.get("PATH", "").split(":"):
        os.environ["PATH"] = os.environ.get("PATH", "") + ":" + _extra

SCHEMA_VERSION = 1

BOOKS_ROOT = Path(os.environ.get("BOOKLIB_ROOT", os.path.expanduser("~/Dropbox/resources/books")))

STATE_DIR = Path(
    os.environ.get("BOOKLIB_STATE_DIR")
    or os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "booklib")
)
CACHE_DIR = Path(
    os.environ.get("BOOKLIB_CACHE_DIR")
    or os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "booklib")
)

MANIFEST_DB = STATE_DIR / "manifest.db"
UNDO_LOG = STATE_DIR / "rename-log.tsv"
LOCK_FILE = STATE_DIR / "lock"
HTTP_CACHE_DIR = CACHE_DIR / "http"

DJVU_ARCHIVE = BOOKS_ROOT / "djvu_originals"
BOOKLIB_DIR = BOOKS_ROOT / ".booklib"
REVIEW_DIR = BOOKLIB_DIR / "review"
FAILED_DIR = BOOKLIB_DIR / "failed"
BIB_PATH = BOOKS_ROOT / "books.bib"

EXTS = {".pdf", ".djvu", ".epub"}
# Strict author-year-title shape: a bare charset check would grandfather
# ISBN-named files like 0-387-28387-0.pdf as "already done".
CONFORMING = re.compile(r"[a-z][a-z0-9]*-(1[6-9]|20)\d{2}-[a-z0-9][a-z0-9-]*\.(pdf|djvu|epub)")
STEM_RE = re.compile(r"[a-z0-9-]+")

AUTO_CONFIDENCE = 80  # >= : auto-apply tier
REVIEW_PREFILL = 50  # >= : review with prefilled proposal; below: blanks
MASS_APPLY_THRESHOLD = 20  # > : require --i-paused-dropbox
REVIEW_BATCH_SIZE = 50


def scoped_dirs():
    """Directories whose files the pipeline manages (flat, no recursion)."""
    dirs = [BOOKS_ROOT / "reference_books", BOOKS_ROOT / "ebooks"]
    staged = BOOKS_ROOT / "current_reading" / "books"
    if staged.is_dir():
        dirs += sorted(p for p in staged.iterdir() if p.is_dir())
    return [d for d in dirs if d.is_dir()]


def mailto():
    """Contact for the Crossref polite pool: env override, else git identity."""
    email = os.environ.get("BOOKLIB_MAILTO")
    if not email:
        try:
            email = subprocess.run(
                ["git", "config", "user.email"], capture_output=True, text=True, check=False
            ).stdout.strip()
        except OSError:
            email = ""
    return email or "booklib@localhost"
