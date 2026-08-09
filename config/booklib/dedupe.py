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
