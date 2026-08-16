"""Structured parsing of legacy filenames (libgen / Anna's Archive / sanet).

The library's non-conforming names are mostly machine-generated and carry
real signal: '(Series) Author - Title-Publisher (Year).pdf' from libgen,
'Title -- Author -- year -- Publisher -- isbn13 ... -- Anna's Archive.pdf',
and bare-ISBN names like '_sanet.st_0521895448.pdf' / '978-3-319-58988-6.pdf'.
Used both as a resolution rung (capped confidence) and to corroborate API
records.
"""

import re

from booklib import slugs
from booklib.sources.pagetext import valid_isbn

_YEAR = re.compile(r"\(((?:19|20)\d{2})")
_ANY_YEAR = re.compile(r"(?:19|20)\d{2}")
_NOISE = re.compile(r"\s*(?:-+\s*)?(?:libgen(?:\.l[ci])?|sanet\.st|z-?lib(?:rary)?[^.]*)\s*", re.I)


def embedded_doi(name):
    """Libgen embeds the book's own DOI in brackets with / as _ :
    '[10.1201_b15876]' -> '10.1201/b15876'. Unlike DOIs harvested from
    page text (often a cited work's), a filename DOI is the book's."""
    m = re.search(r"\[(10\.\d{4,9})_([^\]\s]+)\]", name)
    return f"{m.group(1)}/{m.group(2)}" if m else None


def bare_isbn(name):
    """Validated ISBN-13 from digit runs in the filename itself."""
    for m in re.finditer(r"[\dXx][\dXx -]{8,16}[\dXx]", name):
        isbn = valid_isbn(m.group(0))
        if isbn:
            return isbn
    return None


def parse(name):
    """{'authors': [...], 'title', 'publisher', 'year', 'series'} or None.

    Fused legacy keys (the library's old convention, e.g.
    'calvetti2022lessismorelinalg.pdf') yield surname + year with title=None:
    corroboration signal only — the API supplies the real title."""
    stem = re.sub(r"\.(pdf|djvu|epub)$", "", name, flags=re.I)
    if " -- " in stem:
        return _parse_annas(stem)
    m = re.fullmatch(r"([a-z]+?)((?:19|20)\d{2})([a-z0-9_]*)", stem)
    if m:
        return {
            "authors": [m.group(1).capitalize()],
            "title": None,
            "publisher": None,
            "year": m.group(2),
            "series": None,
        }
    return _parse_libgen(stem)


def _parse_annas(stem):
    # Title -- Author(s) -- [edition,] year -- Publisher -- isbn13 … -- hash -- Anna's Archive
    parts = [p.strip() for p in stem.split(" -- ") if p.strip()]
    if len(parts) < 2:
        return None
    title, authors_raw = parts[0], parts[1]
    year = None
    for p in parts[2:]:
        m = _ANY_YEAR.search(p)
        if m:
            year = m.group(0)
            break
    publisher = next(
        (p for p in parts[2:] if not _ANY_YEAR.search(p) and not re.search(r"\d{6,}|archive", p, re.I)),
        None,
    )
    title = title.replace("_ ", ": ").replace("_", "/")
    return _record(authors_raw, title, publisher, year, None)


def _parse_libgen(stem):
    # (Series) Authors - Title-Publisher (Year)   or   [Series] … (Year, Publisher)
    stem = _NOISE.sub(" ", stem).strip(" -")
    series = None
    m = re.match(r"^(?:\((?P<ps>[^)]*)\)|\[(?P<bs>[^\]]*)\])\s*(?P<rest>.+)$", stem)
    if m:
        series, stem = m.group("ps") or m.group("bs"), m.group("rest").strip()
    year, paren_pub = None, None
    year_m = re.search(r"\((?P<year>(?:19|20)\d{2})(?:\s*,\s*(?P<pub>[^)]+))?\)", stem)
    if year_m:
        year, paren_pub = year_m.group("year"), year_m.group("pub")
        stem = (stem[: year_m.start()] + stem[year_m.end() :]).strip(" ()-")
    if " - " not in stem:
        return None
    authors_raw, rest = stem.split(" - ", 1)
    rest = rest.replace("_ ", ": ").replace("_", "/").strip()
    # Publisher rides after the last '-' that isn't inside the title proper,
    # unless it already came from the (Year, Publisher) parenthetical.
    publisher = paren_pub.strip() if paren_pub else None
    if publisher is None and "-" in rest:
        head, _, tail = rest.rpartition("-")
        if tail and not re.search(r"\d", tail) and len(tail.split()) <= 6 and head:
            rest, publisher = head.strip(), tail.strip()
    return _record(authors_raw, rest, publisher, year, series)


def _record(authors_raw, title, publisher, year, series):
    authors_raw = re.sub(r"\((?:auth|ed)s?\.?\)", "", authors_raw, flags=re.I)
    authors_raw = re.sub(r"\((?:editor|edit)[^)]*\)?", "", authors_raw, flags=re.I)
    authors = [a for chunk in slugs.split_authors(authors_raw) for a in _split_commas(chunk)]
    title = title.strip(" .,-")
    if not (authors and title):
        return None
    return {
        "authors": authors,
        "title": title,
        "publisher": (publisher or "").strip() or None,
        "year": year,
        "series": series,
    }


def _split_commas(chunk):
    """'Koller, Daphne' stays whole; 'A. One, B. Two, C. Three' splits.
    Heuristic: a comma list of 3+ pieces, or pieces that each contain a
    space (full names), is a multi-author list."""
    parts = [p.strip() for p in chunk.split(",") if p.strip()]
    if len(parts) <= 1:
        return parts
    if len(parts) == 2 and " " not in parts[1]:
        return [chunk.strip()]  # "Surname, F." / "Surname, First" — one author... except "First Last" pairs
    return parts
