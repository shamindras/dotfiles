"""Byte-identical duplicate handling (user policy, 2026-08): when the same
content exists at multiple paths, keep exactly one copy — canonically named
— and delete the rest.

Keep-priority: current_reading (the active reading queue) > ebooks >
reference_books; within a tier, a conforming name beats a legacy one, then
lexicographic. Deletions are recorded as events (op=delete); the pre-run
backup clone and Dropbox version history are the recovery paths."""

import os
from pathlib import Path

from booklib import config


def _tier(path):
    p = str(path)
    if "/current_reading/" in p:
        return 0
    if "/ebooks/" in p:
        return 1
    return 2


def _rank(path):
    name = Path(path).name
    return (_tier(path), 0 if config.CONFORMING.fullmatch(name) else 1, path)


def find_dupes(manifest):
    """[(sha, keep_path, [delete_paths...])] for every multi-path content."""
    rows = manifest.db.execute(
        "SELECT sha256, COUNT(*) n FROM paths GROUP BY sha256 HAVING n > 1"
    ).fetchall()
    out = []
    for row in rows:
        paths = [p for p in manifest.paths_for_sha(row["sha256"]) if os.path.exists(p)]
        if len(paths) < 2:
            continue
        ordered = sorted(paths, key=_rank)
        out.append((row["sha256"], ordered[0], ordered[1:]))
    return out


def _pages(path):
    import re
    import subprocess

    if str(path).endswith(".djvu"):
        out = subprocess.run(["djvused", str(path), "-e", "n"],
                             capture_output=True, text=True).stdout.strip()
        return int(out) if out.isdigit() else None
    out = subprocess.run(["pdfinfo", str(path)], capture_output=True, text=True).stdout
    m = re.search(r"^Pages:\s+(\d+)", out, re.MULTILINE)
    return int(m.group(1)) if m else None


def resolve_collisions(manifest, shas=None):
    """Same-edition duplicate policy (user directive, 2026-08): a review-held
    collision whose twin has a near-identical page count is a duplicate copy
    — delete the newcomer, keep the incumbent. Real variants (page counts
    diverge) stay in review. Returns number deleted."""
    import re

    rows = manifest.db.execute(
        "SELECT m.sha256, m.proposed_stem FROM metadata m"
        " WHERE m.status='needs_review' AND m.source LIKE '%collision%'"
        " AND m.proposed_stem IS NOT NULL"
    ).fetchall()
    deleted = 0
    for r in rows:
        if shas is not None and r["sha256"] not in shas:
            continue
        base = re.sub(r"-\d+$", "", r["proposed_stem"])
        twin = manifest.db.execute(
            "SELECT p.path FROM metadata m JOIN paths p USING (sha256)"
            " WHERE (m.final_stem=? OR m.proposed_stem=?) AND m.sha256<>? LIMIT 1",
            (base, base, r["sha256"]),
        ).fetchone()
        path = manifest.path_for_sha(r["sha256"])
        if not (path and os.path.exists(path)):
            continue
        if not (twin and os.path.exists(twin["path"])):
            # Incumbent vanished: the hold is orphaned — re-resolve from
            # scratch so the newcomer can claim the now-free base stem.
            manifest.set_metadata(r["sha256"], status="pending", proposed_stem=None)
            manifest.commit()
            print(f"collision hold orphaned (twin gone), re-queued: {os.path.basename(path)}")
            continue
        p1, p2 = _pages(path), _pages(twin["path"])
        if p1 and p2 and abs(p1 - p2) <= 6:
            manifest.record_event("delete", path, "same-edition dup of " + base, r["sha256"])
            os.remove(path)
            manifest.unlink_path(path)
            manifest.set_metadata(r["sha256"], status="skipped")
            manifest.commit()
            print(f"deduped same-edition copy: {os.path.basename(path)}  (kept {base})")
            deleted += 1
    return deleted


def run(manifest, do_apply=False):
    prefix = "" if do_apply else "DRY-RUN: "
    dupes = find_dupes(manifest)
    deleted = 0
    for sha, keep, drops in dupes:
        for drop in drops:
            print(f"{prefix}delete duplicate: {drop}  (keeping {keep})")
            if do_apply:
                manifest.record_event("delete", drop, keep, sha)
                manifest.commit()
                os.remove(drop)
                manifest.unlink_path(drop)
                manifest.commit()
            deleted += 1
    print(f"{prefix}{deleted} duplicate cop{'y' if deleted == 1 else 'ies'} "
          f"across {len(dupes)} book(s)")
    return deleted
