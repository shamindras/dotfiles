"""Mutation executor: renames (and, via convert.py, conversions) with the
backup gate, never-overwrite collision policy, per-file transactions, and
the undo log.

Order per file: undo-TSV line + events row committed BEFORE os.rename, so a
crash leaves an already-recorded action at worst — re-running apply resumes
exactly (applied files are recognized and skipped)."""

import os
import unicodedata
from pathlib import Path

from booklib import config, convert


def plan_ops(manifest, only=None, dirs=None):
    """Ops for every auto-confident or user-approved row — one op per path
    holding the content, so duplicate copies across dirs all get renamed."""
    prefixes = tuple(str(d).rstrip("/") + "/" for d in dirs) if dirs else None
    ops = []
    for row in manifest.rows_with_status("resolved", "approved", "applied"):
        # applied rows stay in the sweep so a stray duplicate copy of
        # already-finished content still gets renamed to the stem.
        stem = row["proposed_stem"] if row["status"] != "applied" else row["final_stem"]
        sha = row["sha256"]
        if not stem:
            continue
        emitted = pending_elsewhere = False
        for path in manifest.paths_for_sha(sha):
            if not os.path.exists(path):
                continue
            if prefixes and not path.startswith(prefixes):
                pending_elsewhere = True
                continue
            src = Path(path)
            if row["kind"] == "djvu":
                if only in (None, "convert"):
                    ops.append({"op": "convert", "sha": sha, "src": src, "stem": stem,
                                "conf": row["confidence"]})
                    emitted = True
            elif only in (None, "rename"):
                dst = src.with_name(f"{stem}{src.suffix.lower()}")
                if dst != src:
                    ops.append({"op": "rename", "sha": sha, "src": src, "dst": dst,
                                "conf": row["confidence"]})
                    emitted = True
                elif prefixes:
                    pending_elsewhere = True  # conforming here; other dirs unscanned
        if not emitted and not pending_elsewhere:
            # every existing copy already wears the stem
            manifest.mark_applied(sha, stem)
    manifest.commit()
    # All renames first (milliseconds each), conversions after (seconds to
    # minutes each) — visible progress fast, and a shorter window where a
    # paused Dropbox is holding back thousands of pending sync events.
    ops.sort(key=lambda o: o["op"] != "rename")
    return ops


def check_gate(manifest, ops, arrival_shas=None):
    """A verified backup is required only for MASS applies (more than
    MASS_APPLY_THRESHOLD ops — the gate's original purpose of protecting
    bulk migrations; user decision 2026-08-10). Small applies rely on the
    undo log and Dropbox history. Arrivals the sweep just discovered are
    always exempt — they pre-date nothing."""
    if len(ops) <= config.MASS_APPLY_THRESHOLD:
        return True, None
    if manifest.latest_verified_backup():
        return True, None
    if arrival_shas is not None and all(o["sha"] in arrival_shas for o in ops):
        return True, None
    return False, "no verified backup (run: book-librarian backup --apply)"


def execute(manifest, ops, do_apply=False, dropbox_ack=False, ocr=False):
    """Returns counts dict. Dry-run prints the plan and touches nothing."""
    counts = {"renamed": 0, "converted": 0, "skipped": 0}
    if not ops:
        return counts
    if do_apply and len(ops) > config.MASS_APPLY_THRESHOLD and not dropbox_ack:
        raise SystemExit(
            f"{len(ops)} operations > {config.MASS_APPLY_THRESHOLD}: pause Dropbox "
            "syncing first, then re-run with --i-paused-dropbox"
        )

    prefix = "" if do_apply else "DRY-RUN: "
    for op in ops:
        if op["op"] == "rename":
            if op["dst"].exists():
                print(f"{prefix}SKIPPED (target exists): {op['src'].name} -> {op['dst'].name}")
                counts["skipped"] += 1
                continue
            print(f"{prefix}{op['src'].name}  ->  {op['dst'].name}")
            if do_apply:
                _rename(manifest, op["sha"], op["src"], op["dst"])
            counts["renamed"] += 1
        else:
            ok = convert.convert_one(
                manifest, op["sha"], op["src"], op["stem"], do_apply=do_apply, ocr=ocr
            )
            counts["converted" if ok else "skipped"] += 1
    return counts


def _rename(manifest, sha, src, dst):
    _log_undo(str(dst), str(src))
    manifest.record_event("rename", str(src), str(dst), sha)
    manifest.commit()
    os.rename(src, dst)
    st = os.stat(dst)
    manifest.unlink_path(_norm(src))
    manifest.link_path(_norm(dst), sha, st.st_mtime_ns, st.st_size)
    # Applied only once every surviving copy of this content wears the stem —
    # a duplicate in another dir must stay eligible for its own rename.
    if all(
        Path(p).stem == dst.stem or not os.path.exists(p)
        for p in manifest.paths_for_sha(sha)
    ):
        manifest.mark_applied(sha, dst.stem)
    manifest.commit()


def undo(manifest, last=1, do_apply=False):
    """Reverse the most recent rename/convert events."""
    prefix = "" if do_apply else "DRY-RUN: "
    done = 0
    for ev in manifest.events_reversed(limit=200):
        if done >= last:
            break
        if ev["op"] == "rename":
            src, dst = Path(ev["src"]), Path(ev["dst"])
            if not dst.exists():
                continue
            print(f"{prefix}undo rename: {dst.name} -> {src.name}")
            if do_apply:
                os.rename(dst, src)
                st = os.stat(src)
                manifest.unlink_path(_norm(dst))
                manifest.link_path(_norm(src), ev["sha256"], st.st_mtime_ns, st.st_size)
                manifest.set_metadata(ev["sha256"], status="approved", final_stem=None)
                manifest.record_event("undo", str(dst), str(src), ev["sha256"])
                manifest.commit()
            done += 1
        elif ev["op"] == "convert":
            # src = original djvu path, dst = generated pdf; the original now
            # sits in the archive under the pdf's stem.
            pdf = Path(ev["dst"])
            archived = config.DJVU_ARCHIVE / (pdf.stem + ".djvu")
            print(f"{prefix}undo convert: rm {pdf.name}; restore {Path(ev['src']).name}")
            if do_apply:
                if pdf.exists():
                    manifest.unlink_path(_norm(pdf))
                    pdf.unlink()
                if archived.exists() and not Path(ev["src"]).exists():
                    os.rename(archived, ev["src"])
                    st = os.stat(ev["src"])
                    manifest.link_path(_norm(Path(ev["src"])), ev["sha256"], st.st_mtime_ns, st.st_size)
                manifest.db.execute(
                    "DELETE FROM conversions WHERE src_sha256=?", (ev["sha256"],)
                )
                manifest.record_event("undo", str(pdf), str(ev["src"]), ev["sha256"])
                manifest.commit()
            done += 1
    if done == 0:
        print("nothing to undo")
    return done


def _log_undo(new, old):
    config.UNDO_LOG.parent.mkdir(parents=True, exist_ok=True)
    with open(config.UNDO_LOG, "a") as fh:
        fh.write(f"{new}\t{old}\n")


def _norm(p):
    return unicodedata.normalize("NFC", str(p))
