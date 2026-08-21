# booklib (book-librarian)

- **Docs**: N/A (custom package; this file is the doc)
- **Installed version**: python3 stdlib only (3.14 at time of writing)

## Overview

Deterministic, incremental pipeline over `~/Dropbox/resources/books/`:
renames PDF/DjVu/EPUB to `author-year-title` (`[a-z0-9-]`, edition year),
converts DjVu→PDF (no OCR by default), and regenerates `books.bib`.
Invoked via `config/bin/book-librarian` (thin launcher; `~/.config/bin`
symlink resolves back into the repo so the package imports with zero
extra setup). `config/bin/rename-ebooks` imports `slugs.py` and
`sources/epub.py` from here — single source of truth for the convention.

## CLI

Read-only verbs always safe; mutating verbs dry-run unless `--apply`.

| Verb      | Purpose                                                        |
| --------- | -------------------------------------------------------------- |
| `scan`    | stat/hash sweep of scoped dirs into the manifest (`--rebuild`) |
| `resolve` | metadata ladder over pending files (`--limit`, `--offline`); OCRs textless scans, pdf and djvu (tesseract), sanity-checks in-text DOIs against page text, +10 when a second API confirms the year |
| `plan`    | table of proposed renames/conversions                          |
| `review`  | `export` / `import FILE` / `list` TSV batches                  |
| `apply`   | execute approved + auto-confident ops (backup-gated)           |
| `convert` | djvu→pdf subset (`--ocr` optional, needs ocrmypdf)             |
| `bib`     | regenerate books.bib + `biber --tool` validation               |
| `status`  | counts; exit 0 done / 1 pending / 2 needs review               |
| `backup`  | APFS clone to `~/books_backup/` + verification                 |
| `dedupe`  | delete byte-identical duplicate copies, keep one (priority: current_reading > ebooks > reference_books) |
| `clean`   | janitor: temp files (.part/.sub/.blg/tmp*.bib.tmp), orphaned quarantine, fully-decided review batches, empty .booklib dirs; also runs automatically at the start of every `sweep --apply` |
| `undo`    | reverse recent renames/conversions (`--last N`)                |
| `sweep`   | arrival path (move-books): new files only (`--async`)          |

## State layout (deliberate sync split)

| Location                          | Contents                         | Synced |
| --------------------------------- | -------------------------------- | ------ |
| `$XDG_STATE_HOME/booklib/`        | manifest.db, rename-log.tsv, lock, sweep.log | NO — live SQLite + Dropbox corrupts |
| `$XDG_CACHE_HOME/booklib/http/`   | API response cache               | NO     |
| `books/.booklib/review/`          | review TSV batches               | yes    |
| `books/.booklib/failed/`          | quarantined conversions          | yes    |
| `books/djvu_originals/`           | archived DjVu originals (renamed)| yes    |
| `books/books.bib`                 | generated BibTeX                 | yes    |

If the library or config ever moves off Dropbox, re-audit this table
(auto-memory: booklib-manifest-outside-dropbox). The manifest is a
rebuildable index — filenames on disk + books.bib are authoritative.

## Env overrides (testing)

`BOOKLIB_ROOT`, `BOOKLIB_STATE_DIR`, `BOOKLIB_CACHE_DIR`,
`BOOKLIB_BACKUP_ROOT`, `BOOKLIB_MAILTO` — point the whole pipeline at a
scratch tree, same pattern as `MOVE_BOOKS_*`.

## Key invariants

- Never overwrite; collisions → review with `-N` disambiguator.
- `apply` requires a verified backup only for mass runs (>20 ops);
  small applies rely on the undo log (arrivals via sweep always exempt).
- Mass applies (>20) require `--i-paused-dropbox`.
- Edition year of the copy in hand, coalesced intrinsic-first: in-file ©
  evidence > API year > filename year — first source present wins. API
  reissue/first-publication disagreement never forces review; the only
  year hold is an uncorroborated OCR-read year older than the API's.
- Auto-apply only at confidence ≥ 80 (`config.AUTO_CONFIDENCE`).
- Every mutation: undo-TSV line + events row committed BEFORE `os.rename`.
- Paths NFC-normalized at manifest boundaries (APFS NFD pitfall).
