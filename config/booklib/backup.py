"""Pre-mutation backup: APFS copy-on-write clone + verification.

`cp -Rc` clones the whole library in seconds and occupies ~zero extra disk
until files diverge. The clone lands OUTSIDE Dropbox (~/books_backup) so
56 GiB doesn't re-upload. apply refuses to run without a verified backup.
"""

import os
import random
import subprocess
from datetime import datetime
from pathlib import Path

from booklib import config
from booklib.hashing import full_sha256

BACKUP_ROOT = Path(os.environ.get("BOOKLIB_BACKUP_ROOT", os.path.expanduser("~/books_backup")))


def _tree_census(root):
    files, nbytes = 0, 0
    for dirpath, _, names in os.walk(root):
        for n in names:
            p = os.path.join(dirpath, n)
            if os.path.isfile(p):
                files += 1
                nbytes += os.path.getsize(p)
    return files, nbytes


def run(manifest, do_apply=False, sample=25):
    src = config.BOOKS_ROOT
    dest = BACKUP_ROOT / f"books-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    if not do_apply:
        files, nbytes = _tree_census(src)
        print(f"DRY-RUN: would clone {src} ({files} files, {nbytes / 1e9:.1f} GB) -> {dest}")
        return True

    BACKUP_ROOT.mkdir(parents=True, exist_ok=True)
    print(f"cloning {src} -> {dest} (APFS copy-on-write)")
    subprocess.run(["cp", "-Rc", str(src), str(dest)], check=True)

    src_files, src_bytes = _tree_census(src)
    dst_files, dst_bytes = _tree_census(dest)
    ok = src_files == dst_files and src_bytes == dst_bytes
    print(f"count: src {src_files} vs backup {dst_files}; bytes: {src_bytes} vs {dst_bytes}")

    if ok:
        candidates = [
            os.path.join(dp, n)
            for dp, _, names in os.walk(src)
            for n in names
            if Path(n).suffix.lower() in config.EXTS
        ]
        for p in random.sample(candidates, min(sample, len(candidates))):
            twin = dest / Path(p).relative_to(src)
            if full_sha256(p) != full_sha256(twin):
                print(f"CHECKSUM MISMATCH: {p}")
                ok = False
                break

    manifest.record_backup(str(dest), dst_files, dst_bytes, ok)
    manifest.commit()
    print("backup verified" if ok else "backup FAILED verification")
    return ok
