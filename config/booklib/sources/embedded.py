"""Embedded PDF metadata (pdfinfo, exiftool) — corroboration only.

Libgen-circulated files routinely carry wiped or junk XMP, so this rung is
capped at low confidence when it is the only signal.
"""

import json
import re
import shutil
import subprocess

from booklib import slugs


def pdf_meta(path):
    out = subprocess.run(["pdfinfo", str(path)], capture_output=True, text=True, check=False)
    fields = dict(
        (k.strip(), v.strip())
        for k, _, v in (line.partition(":") for line in out.stdout.splitlines())
        if v.strip()
    )
    title, author = fields.get("Title"), fields.get("Author")
    if (not title or not author) and shutil.which("exiftool"):
        exif = subprocess.run(
            ["exiftool", "-j", "-Title", "-Author", str(path)],
            capture_output=True, text=True, check=False,
        )
        try:
            data = json.loads(exif.stdout)[0]
            title = title or data.get("Title")
            author = author or data.get("Author")
        except (json.JSONDecodeError, IndexError):
            pass
    if _junk(title):
        title = None
    if _junk(author):
        author = None
    return {
        "authors": slugs.split_authors(author) if author else [],
        "title": title,
        "year": None,  # CreationDate is PDF-production time, not edition year
    }


def _junk(value):
    v = (value or "").strip()
    return not v or bool(re.fullmatch(r"(?:untitled|unknown|admin|user|microsoft.*|.*\.(?:dvi|tex|doc))", v, re.I))
