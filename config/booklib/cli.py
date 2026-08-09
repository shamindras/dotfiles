"""book-librarian CLI. Read-only verbs are always safe; mutating verbs
print a dry-run plan unless --apply is given."""

import argparse
import fcntl
import os
import subprocess
import sys
from pathlib import Path

from booklib import apply as apply_mod
from booklib import backup, bibgen, config, review, scan
from booklib.manifest import Manifest


def main(argv=None):
    args = _parser().parse_args(argv)
    manifest = Manifest()
    try:
        return args.func(args, manifest) or 0
    finally:
        manifest.close()


def _parser():
    p = argparse.ArgumentParser(prog="book-librarian", description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("scan", help="stat/hash sweep of scoped dirs into the manifest")
    s.add_argument("--rebuild", action="store_true", help="drop path index and re-hash")
    s.add_argument("dirs", nargs="*", type=Path)
    s.set_defaults(func=cmd_scan)

    s = sub.add_parser("resolve", help="run the metadata ladder over pending files")
    s.add_argument("--limit", type=int)
    s.add_argument("--offline", action="store_true", help="skip API rungs")
    s.add_argument("--retry-review", action="store_true",
                   help="also re-resolve needs_review rows (after going online)")
    s.add_argument("--dir", action="append", type=Path, dest="dirs",
                   help="restrict to files under this directory (repeatable)")
    s.set_defaults(func=cmd_resolve)

    s = sub.add_parser("plan", help="show every proposed rename/conversion")
    s.add_argument("--only", choices=["rename", "convert"])
    s.add_argument("--dir", action="append", type=Path, dest="dirs",
                   help="restrict to files under this directory (repeatable)")
    s.set_defaults(func=cmd_plan)

    s = sub.add_parser("review", help="export/import review batches")
    rs = s.add_subparsers(dest="review_cmd", required=True)
    r = rs.add_parser("export")
    r.add_argument("--batch-size", type=int)
    r.set_defaults(func=cmd_review_export)
    r = rs.add_parser("import")
    r.add_argument("file", type=Path)
    r.set_defaults(func=cmd_review_import)
    rs.add_parser("list").set_defaults(func=cmd_review_list)

    s = sub.add_parser("apply", help="execute approved + auto-confident operations")
    s.add_argument("--only", choices=["rename", "convert"])
    s.add_argument("--dir", action="append", type=Path, dest="dirs",
                   help="restrict to files under this directory (repeatable)")
    _mutating(s)
    s.set_defaults(func=cmd_apply)

    s = sub.add_parser("convert", help="djvu->pdf subset of apply")
    s.add_argument("--ocr", action="store_true", help="add text layer via ocrmypdf")
    _mutating(s)
    s.set_defaults(func=cmd_convert)

    s = sub.add_parser("bib", help="regenerate books.bib (+ biber validation)")
    s.add_argument("--check-only", action="store_true")
    s.set_defaults(func=cmd_bib)

    sub.add_parser("status", help="pipeline state; exit 0 done / 1 pending / 2 review").set_defaults(
        func=cmd_status
    )

    s = sub.add_parser("backup", help="APFS clone of the library + verification")
    s.add_argument("--apply", action="store_true")
    s.set_defaults(func=cmd_backup)

    s = sub.add_parser("dedupe", help="delete byte-identical duplicate copies (keeps one)")
    s.add_argument("--apply", action="store_true")
    s.set_defaults(func=cmd_dedupe)

    sub.add_parser("clean", help="remove pipeline litter (temp files, orphaned quarantine,"
                   " decided review batches)").set_defaults(func=cmd_clean)

    s = sub.add_parser("undo", help="reverse the most recent operations")
    s.add_argument("--last", type=int, default=1)
    s.add_argument("--apply", action="store_true")
    s.set_defaults(func=cmd_undo)

    s = sub.add_parser("sweep", help="arrival path: scan + resolve + apply new files only")
    s.add_argument("--async", dest="async_", action="store_true", help="detach and return immediately")
    s.add_argument("--apply", action="store_true")
    s.set_defaults(func=cmd_sweep)

    return p


def _mutating(s):
    s.add_argument("--apply", action="store_true", help="execute (default: dry-run)")
    s.add_argument("--i-paused-dropbox", action="store_true", dest="dropbox_ack")


# -- commands ---------------------------------------------------------------


def cmd_scan(args, manifest):
    stats = scan.scan(manifest, dirs=args.dirs or None, rebuild=args.rebuild)
    print(
        f"known {stats['known']}  new {stats['new']}  relinked {stats['relinked']}"
        f"  conforming->applied {stats['conforming']}"
    )
    for p in stats["dataless"]:
        print(f"DATALESS (make available offline first): {p}")
    return 0


def cmd_resolve(args, manifest):
    from booklib import resolve

    counts = resolve.resolve_pending(
        manifest, limit=args.limit, offline=args.offline,
        retry_review=args.retry_review, dirs=args.dirs,
    )
    print("  ".join(f"{k} {v}" for k, v in sorted(counts.items())) or "nothing pending")
    return 0


def cmd_plan(args, manifest):
    ops = apply_mod.plan_ops(manifest, only=args.only, dirs=args.dirs)
    for op in ops:
        conf = op["conf"] if op["conf"] is not None else "·"
        if op["op"] == "rename":
            print(f"rename [{conf:>3}] {op['src'].name}  ->  {op['dst'].name}")
        else:
            print(f"convert [{conf:>3}] {op['src'].name}  ->  {op['stem']}.pdf")
    print(f"{len(ops)} operations planned")
    return 0


def cmd_review_export(args, manifest):
    paths = review.export_batches(manifest, batch_size=args.batch_size)
    for p in paths:
        print(p)
    print(f"{len(paths)} batch(es) written" if paths else "nothing needs review")
    return 0


def cmd_review_import(args, manifest):
    counts = review.import_file(manifest, args.file)
    print(f"approved {counts['approved']}  skipped {counts['skipped']}")
    return 0


def cmd_review_list(args, manifest):
    for path, total, decided in review.list_batches(manifest):
        print(f"{path.name}: {decided}/{total} decided")
    return 0


def cmd_apply(args, manifest):
    ops = apply_mod.plan_ops(manifest, only=args.only, dirs=args.dirs)
    if not ops:
        print("nothing to apply")
        return 0
    ok, reason = apply_mod.check_gate(manifest, ops)
    if args.apply and not ok:
        raise SystemExit(f"refusing to apply: {reason}")
    counts = apply_mod.execute(manifest, ops, do_apply=args.apply, dropbox_ack=args.dropbox_ack)
    print(_summary(counts))
    return 0


def cmd_convert(args, manifest):
    from booklib import convert as convert_mod

    if args.ocr:
        convert_mod.require_ocr()
    ops = apply_mod.plan_ops(manifest, only="convert")
    if not ops:
        print("nothing to convert")
        return 0
    ok, reason = apply_mod.check_gate(manifest, ops)
    if args.apply and not ok:
        raise SystemExit(f"refusing to convert: {reason}")
    counts = apply_mod.execute(
        manifest, ops, do_apply=args.apply, dropbox_ack=args.dropbox_ack, ocr=args.ocr
    )
    print(_summary(counts))
    return 0


def cmd_bib(args, manifest):
    return 0 if bibgen.generate(manifest, check_only=args.check_only) else 1


def cmd_status(args, manifest):
    counts = manifest.status_counts()
    for status in ("pending", "resolved", "needs_review", "approved", "applied", "skipped", "failed"):
        if counts.get(status):
            print(f"{status:>13}: {counts[status]}")
    unconv = manifest.unconverted_djvu()
    if unconv:
        print(f"{'djvu-pending':>13}: {len(unconv)}")
    no_text = manifest.db.execute(
        "SELECT COUNT(*) n FROM conversions WHERE has_text_layer=0"
    ).fetchone()["n"]
    if no_text:
        print(f"{'ocr-later':>13}: {no_text} converted pdfs lack a text layer")
    for path, total, decided in review.list_batches(manifest):
        print(f"{'review':>13}: {path.name} {decided}/{total} decided")
    if counts.get("needs_review"):
        return 2
    if counts.get("pending") or counts.get("resolved") or counts.get("approved") or unconv:
        return 1
    return 0


def cmd_dedupe(args, manifest):
    from booklib import dedupe

    dedupe.run(manifest, do_apply=args.apply)
    return 0


def cmd_clean(args, manifest):
    from booklib import housekeeping

    removed = housekeeping.clean(manifest)
    for p in removed:
        print(f"removed: {p}")
    print(f"{len(removed)} item(s) cleaned")
    return 0


def cmd_backup(args, manifest):
    return 0 if backup.run(manifest, do_apply=args.apply) else 1


def cmd_undo(args, manifest):
    apply_mod.undo(manifest, last=args.last, do_apply=args.apply)
    return 0


def cmd_sweep(args, manifest):
    if args.async_:
        launcher = Path(__file__).resolve().parent.parent / "bin" / "book-librarian"
        config.STATE_DIR.mkdir(parents=True, exist_ok=True)
        log = open(config.STATE_DIR / "sweep.log", "a")
        subprocess.Popen(
            [sys.executable, str(launcher), "sweep"] + (["--apply"] if args.apply else []),
            stdout=log, stderr=log, start_new_session=True,
        )
        print("sweep detached")
        return 0

    lock = _try_lock()
    if lock is None:
        print("another booklib run holds the lock; skipping sweep")
        return 0
    try:
        from booklib import resolve

        stats = scan.scan(manifest)
        # Janitor first: every sweep clears pipeline litter (temp files,
        # orphaned quarantine, fully-decided review batches) even when no
        # new books arrived.
        if args.apply:
            from booklib import housekeeping

            for p in housekeeping.clean(manifest):
                print(f"cleaned: {p}")
        new_shas = set(stats["new_shas"])
        if not new_shas and not stats.get("pruned"):
            print("no new files")
            return 0
        counts = {}
        if new_shas:
            resolve.resolve_pending(manifest, shas=new_shas)
            ops = [o for o in apply_mod.plan_ops(manifest) if o["sha"] in new_shas]
            ok, reason = apply_mod.check_gate(manifest, ops, arrival_shas=new_shas)
            if ops and ok:
                counts = apply_mod.execute(manifest, ops, do_apply=args.apply, dropbox_ack=True)
        # Regenerate the bib for arrivals AND for manual deletions the scan
        # just pruned — entries only cover files still on disk.
        if args.apply and (
            counts.get("renamed") or counts.get("converted") or stats.get("pruned")
        ):
            bibgen.generate(manifest)
        review_n = sum(
            1 for r in manifest.rows_with_status("needs_review") if r["sha256"] in new_shas
        )
        # Silent by design (user preference): outcome lands in sweep.log and
        # `book-librarian status`; no notification pop-up.
        print(_summary(counts) + (f", {review_n} need review" if review_n else ""))
        return 0
    finally:
        os.close(lock)
        config.LOCK_FILE.unlink(missing_ok=True)


def _try_lock():
    config.STATE_DIR.mkdir(parents=True, exist_ok=True)
    fd = os.open(config.LOCK_FILE, os.O_CREAT | os.O_RDWR)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return fd
    except BlockingIOError:
        os.close(fd)
        return None


def _summary(counts):
    return (
        f"{counts.get('renamed', 0)} renamed, {counts.get('converted', 0)} converted,"
        f" {counts.get('skipped', 0)} skipped"
    )
