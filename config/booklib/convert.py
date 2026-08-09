"""DjVu → PDF conversion. Fast by design: plain ddjvu, no OCR by default.

Per file (name resolved FIRST, so the PDF is born with its final name and
Dropbox sees exactly one new file): render to stem.pdf.part → verify page
count → promote to stem.pdf → archive the original as djvu_originals/
stem.djvu. Page-count mismatch quarantines the output and leaves the
original untouched. `--ocr` (off by default) runs ocrmypdf afterward and
errors up front if it isn't installed."""

import os
import re
import shutil
import subprocess
import unicodedata
from pathlib import Path

from booklib import config, hashing
from booklib.sources import pagetext

SIZE_BLOWUP = 4  # retry with -subsample=2 when pdf > 4x djvu


def require_ocr():
    if not shutil.which("ocrmypdf"):
        raise SystemExit("--ocr needs ocrmypdf: brew install ocrmypdf")


def djvu_pages(path):
    out = subprocess.run(
        ["djvused", str(path), "-e", "n"], capture_output=True, text=True, check=False
    )
    return int(out.stdout.strip()) if out.stdout.strip().isdigit() else None


def convert_one(manifest, sha, src, stem, do_apply=False, ocr=False):
    """Convert src (.djvu) to <same-dir>/<stem>.pdf; archive original."""
    src = Path(src)
    pdf = src.with_name(f"{stem}.pdf")
    archived = config.DJVU_ARCHIVE / f"{stem}.djvu"
    prefix = "" if do_apply else "DRY-RUN: "

    if pdf.exists():
        print(f"{prefix}SKIPPED (target exists): {src.name} -> {pdf.name}")
        return False
    print(f"{prefix}convert {src.name}  ->  {pdf.name}  (original -> {archived})")
    if not do_apply:
        return True
    if ocr:
        require_ocr()

    part = pdf.with_suffix(".pdf.part")
    if not _render(src, part):
        return _quarantine(src, part, "ddjvu failed")

    pages_src, pages_dst = djvu_pages(src), _pdf_pages(part)
    if not pages_src or pages_src != pages_dst:
        return _quarantine(src, part, f"page mismatch: djvu={pages_src} pdf={pages_dst}")

    if part.stat().st_size > SIZE_BLOWUP * src.stat().st_size:
        smaller = pdf.with_suffix(".pdf.sub")
        if _render(src, smaller, subsample=2) and _pdf_pages(smaller) == pages_src:
            if smaller.stat().st_size < part.stat().st_size:
                part.unlink()
                part = smaller
            else:
                smaller.unlink()

    # Record intent, then mutate: pdf appears, original moves to archive.
    manifest.record_event("convert", str(src), str(pdf), sha)
    manifest.commit()
    src_stat = os.stat(src)
    os.rename(part, pdf)
    config.DJVU_ARCHIVE.mkdir(parents=True, exist_ok=True)
    _log_undo(str(archived), str(src))
    os.rename(src, archived)

    if ocr:
        subprocess.run(
            ["ocrmypdf", "-l", "eng", "--optimize", "1", str(pdf), str(pdf)], check=False
        )
    # The converted pdf inherits the scan's modified time (after OCR, which
    # rewrites the file), so mtime-ordered views keep the library's original
    # chronology (user preference).
    os.utime(pdf, ns=(src_stat.st_atime_ns, src_stat.st_mtime_ns))

    dst_sha = hashing.full_sha256(pdf)
    st = os.stat(pdf)
    manifest.upsert_file(dst_sha, st.st_size, hashing.partial_fingerprint(pdf, st.st_size), "pdf")
    manifest.unlink_path(_norm(src))
    manifest.link_path(_norm(pdf), dst_sha, st.st_mtime_ns, st.st_size)
    manifest.mark_applied(dst_sha, stem)
    manifest.mark_applied(sha, stem)  # the archived djvu keeps its record
    manifest.record_conversion(
        sha, dst_sha, pages_src, pages_dst,
        ocr=ocr, has_text=int(pagetext.has_text_layer(pdf)),
    )
    manifest.commit()
    return True


def _render(src, out, subsample=None):
    cmd = ["ddjvu", "-format=pdf", "-mode=color", "-skip"]
    if subsample:
        cmd.append(f"-subsample={subsample}")
    cmd += [str(src), str(out)]
    res = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return res.returncode == 0 and out.exists() and out.stat().st_size > 0


def _pdf_pages(path):
    out = subprocess.run(["pdfinfo", str(path)], capture_output=True, text=True, check=False)
    m = re.search(r"^Pages:\s+(\d+)", out.stdout, re.MULTILINE)
    return int(m.group(1)) if m else None


def _quarantine(src, part, reason):
    print(f"FAILED ({reason}): {src.name} — original untouched")
    if part.exists():
        config.FAILED_DIR.mkdir(parents=True, exist_ok=True)
        os.rename(part, config.FAILED_DIR / part.name)
    return False


def _log_undo(new, old):
    config.UNDO_LOG.parent.mkdir(parents=True, exist_ok=True)
    with open(config.UNDO_LOG, "a") as fh:
        fh.write(f"{new}\t{old}\n")


def _norm(p):
    return unicodedata.normalize("NFC", str(p))
