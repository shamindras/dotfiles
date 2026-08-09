"""Review queue: TSV batches the user edits in any editor.

Batches live inside the library (Dropbox-synced) at books/.booklib/review/.
decision column: ok (accept proposal) | edit (re-derive stem from the edited
fields, or take an explicitly edited proposed_stem) | skip (leave file
alone, status=skipped). Import is all-or-nothing: any malformed row rejects
the whole file with line numbers, so a half-applied batch can't happen.
"""

import csv
import json
import re

from booklib import config, slugs
from booklib.manifest import now

COLUMNS = [
    "sha12", "current_name", "proposed_stem", "authors", "title",
    "edition_year", "isbn13", "confidence", "evidence", "decision",
]


def export_batches(manifest, batch_size=None):
    """Write needs_review rows not yet exported into numbered TSV batches."""
    batch_size = batch_size or config.REVIEW_BATCH_SIZE
    config.REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    exported = _exported_sha12s()
    rows = [
        r for r in manifest.rows_with_status("needs_review")
        if r["sha256"][:12] not in exported
    ]
    if not rows:
        return []

    existing = sorted(config.REVIEW_DIR.glob("batch-*.tsv"))
    next_n = 1 + max((int(p.stem.split("-")[1]) for p in existing), default=0)
    written = []
    for i in range(0, len(rows), batch_size):
        path = config.REVIEW_DIR / f"batch-{next_n + i // batch_size:03d}.tsv"
        with open(path, "w", newline="") as fh:
            w = csv.writer(fh, delimiter="\t")
            w.writerow(COLUMNS)
            for r in rows[i : i + batch_size]:
                authors = "; ".join(json.loads(r["authors_json"])) if r["authors_json"] else ""
                w.writerow([
                    r["sha256"][:12],
                    _name_for(manifest, r["sha256"]),
                    r["proposed_stem"] or "",
                    authors,
                    r["title"] or "",
                    r["edition_year"] or "",
                    r["isbn13"] or "",
                    r["confidence"] if r["confidence"] is not None else "",
                    r["year_evidence"] or "",
                    "",
                ])
        written.append(path)
    return written


def import_file(manifest, path):
    """Validate the whole TSV, then apply decisions. Returns counts."""
    with open(path, newline="") as fh:
        reader = csv.DictReader(fh, delimiter="\t")
        if reader.fieldnames != COLUMNS:
            raise SystemExit(f"{path}: header mismatch — expected {COLUMNS}")
        rows = list(reader)

    errors, plans = [], []
    for lineno, row in enumerate(rows, start=2):
        sha12 = row["sha12"].strip()
        decision = row["decision"].strip().lower()
        full = manifest.db.execute(
            "SELECT m.sha256, f.kind FROM metadata m JOIN files f USING (sha256)"
            " WHERE m.sha256 LIKE ?", (sha12 + "%",)
        ).fetchone()
        if not full:
            errors.append(f"line {lineno}: unknown sha12 {sha12}")
            continue
        if decision in ("", "-"):
            continue  # untouched row: stays in review
        if decision == "skip":
            plans.append((full["sha256"], "skip", None))
            continue
        if decision not in ("ok", "edit"):
            errors.append(f"line {lineno}: bad decision {decision!r} (ok|edit|skip)")
            continue
        if decision == "ok":
            stem = row["proposed_stem"].strip()
        else:
            stem = row["proposed_stem"].strip() or _derive_stem(row)
        if not stem or not config.STEM_RE.fullmatch(stem):
            errors.append(f"line {lineno}: invalid stem {stem!r} (need [a-z0-9-]+)")
            continue
        holder = manifest.stem_taken(stem, kind=full["kind"])
        if holder and holder != full["sha256"]:
            errors.append(f"line {lineno}: stem {stem!r} already taken")
            continue
        plans.append((full["sha256"], "approve", (stem, row)))

    if errors:
        raise SystemExit(f"{path}: rejected, nothing imported:\n  " + "\n  ".join(errors))

    counts = {"approved": 0, "skipped": 0}
    for sha, action, payload in plans:
        if action == "skip":
            manifest.set_metadata(sha, status="skipped", resolved_at=now())
            counts["skipped"] += 1
        else:
            stem, row = payload
            fields = {"status": "approved", "proposed_stem": stem, "resolved_at": now()}
            if row["authors"].strip():
                fields["authors_json"] = json.dumps(
                    [a.strip() for a in row["authors"].split(";") if a.strip()]
                )
            if row["title"].strip():
                fields["title"] = row["title"].strip()
            if row["edition_year"].strip().isdigit():
                fields["edition_year"] = int(row["edition_year"].strip())
            if row["isbn13"].strip():
                fields["isbn13"] = row["isbn13"].strip()
            manifest.set_metadata(sha, **fields)
            counts["approved"] += 1
    manifest.commit()
    return counts


def list_batches(manifest):
    out = []
    for path in sorted(config.REVIEW_DIR.glob("batch-*.tsv")):
        with open(path, newline="") as fh:
            rows = list(csv.DictReader(fh, delimiter="\t"))
        decided = sum(1 for r in rows if r.get("decision", "").strip())
        out.append((path, len(rows), decided))
    return out


def _derive_stem(row):
    authors = [a.strip() for a in row["authors"].split(";") if a.strip()]
    year = row["edition_year"].strip()
    if not (authors and row["title"].strip() and year.isdigit()):
        return None
    return slugs.make_stem(
        slugs.first_surname(authors), year,
        slugs.title_slug(row["title"]),
        slugs.volume_suffix(row["title"], row["current_name"]),
    )


def _exported_sha12s():
    seen = set()
    for path in config.REVIEW_DIR.glob("batch-*.tsv"):
        with open(path, newline="") as fh:
            for r in csv.DictReader(fh, delimiter="\t"):
                if r.get("sha12"):
                    seen.add(r["sha12"].strip())
    return seen


def _name_for(manifest, sha):
    path = manifest.path_for_sha(sha)
    return path.rsplit("/", 1)[-1] if path else "(missing)"
