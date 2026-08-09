"""Content hashing: full SHA-256 (identity) + cheap partial fingerprint.

The partial fingerprint (size + first/last 64 KiB) relinks moved files whose
mtime changed without re-reading gigabytes; full hashes are computed once and
parallelized (hashlib releases the GIL, so threads scale on real files).
"""

import hashlib
import os
from concurrent.futures import ThreadPoolExecutor

_CHUNK = 1 << 20
_EDGE = 64 * 1024


def full_sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        while chunk := fh.read(_CHUNK):
            h.update(chunk)
    return h.hexdigest()


def partial_fingerprint(path, size):
    h = hashlib.sha256(str(size).encode())
    with open(path, "rb") as fh:
        h.update(fh.read(_EDGE))
        if size > 2 * _EDGE:
            fh.seek(-_EDGE, os.SEEK_END)
            h.update(fh.read(_EDGE))
    return h.hexdigest()


def hash_many(paths, workers=None):
    """{path: sha256} computed in parallel."""
    if not paths:
        return {}
    workers = workers or min(len(paths), os.cpu_count() or 4)
    with ThreadPoolExecutor(max_workers=workers) as ex:
        return dict(zip(paths, ex.map(full_sha256, paths)))
