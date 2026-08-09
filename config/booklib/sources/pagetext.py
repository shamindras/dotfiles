"""Evidence from inside the PDF: text extraction, ISBN/DOI, edition year."""

import re
import subprocess

_ISBN_CAND = re.compile(
    r"ISBN(?:-1[03])?[^0-9]{0,10}((?:97[89][-\s]?)?\d{1,5}[-\s]?\d{1,7}[-\s]?\d{1,7}[-\s]?[\dXx])",
    re.IGNORECASE,
)
_DOI = re.compile(r"\b(10\.\d{4,9}/[-._;()/:A-Za-z0-9]+)")
_COPYRIGHT = re.compile(
    r"(?:©|\(c\)|(?<![a-z])copyright\b)\D{0,40}?"
    r"((?:19|20)\d{2}(?:\s*,\s*(?:19|20)\d{2})*)",
    re.IGNORECASE,
)
_EDITION = re.compile(
    r"\b(?:\d+(?:st|nd|rd|th)?\s+edition|first\s+published)\D{0,30}?((?:19|20)\d{2})",
    re.IGNORECASE,
)
_PUBLISHED = re.compile(r"\bpublished(?:\s+in)?\s+((?:19|20)\d{2})", re.IGNORECASE)

YEAR_MIN, YEAR_MAX = 1900, 2027


def page_count(path):
    out = subprocess.run(["pdfinfo", str(path)], capture_output=True, text=True, check=False)
    m = re.search(r"^Pages:\s+(\d+)", out.stdout, re.MULTILINE)
    return int(m.group(1)) if m else None


def _pdftotext(path, first, last):
    out = subprocess.run(
        ["pdftotext", "-q", "-f", str(first), "-l", str(last), str(path), "-"],
        capture_output=True, text=True, check=False,
    )
    return out.stdout


def extract_text(path, head=8, tail=5):
    """First `head` pages plus last `tail` pages (copyright pages live at
    both ends depending on the publisher)."""
    text = _pdftotext(path, 1, head)
    pages = page_count(path)
    if pages and pages > head + tail:
        text += "\n" + _pdftotext(path, pages - tail + 1, pages)
    return text


def has_text_layer(path, pages=5, min_chars=50):
    text = _pdftotext(path, 1, pages)
    return len(re.sub(r"\s", "", text)) >= min_chars


def valid_isbn(candidate):
    """Normalize to ISBN-13 when the check digit validates, else None."""
    digits = re.sub(r"[-\s]", "", candidate or "").upper()
    if len(digits) == 10 and re.fullmatch(r"\d{9}[\dX]", digits):
        total = sum((10 - i) * (10 if c == "X" else int(c)) for i, c in enumerate(digits))
        if total % 11 == 0:
            core = "978" + digits[:9]
            check = (10 - sum(int(c) * (1, 3)[i % 2] for i, c in enumerate(core)) % 10) % 10
            return core + str(check)
        return None
    if len(digits) == 13 and digits.isdigit() and digits[:3] in ("978", "979"):
        if sum(int(c) * (1, 3)[i % 2] for i, c in enumerate(digits)) % 10 == 0:
            return digits
    return None


def find_isbns(text):
    """Validated ISBN-13s in order of appearance, deduped."""
    seen, out = set(), []
    for m in _ISBN_CAND.finditer(text or ""):
        isbn = valid_isbn(m.group(1))
        if isbn and isbn not in seen:
            seen.add(isbn)
            out.append(isbn)
    return out


def find_doi(text):
    m = _DOI.search(text or "")
    return m.group(1).rstrip(".,;") if m else None


def year_evidence(text):
    """(year, evidence) from in-file text; © chain beats edition beats
    published. 'reprinted' lines are ignored — printing year is not the
    edition year."""
    lines = [ln for ln in (text or "").splitlines() if not re.search(r"\breprint", ln, re.I)]
    joined = "\n".join(lines)
    m = _COPYRIGHT.search(joined)
    if m:
        years = [int(y) for y in re.findall(r"(?:19|20)\d{2}", m.group(1))]
        years = [y for y in years if YEAR_MIN <= y <= YEAR_MAX]
        if years:
            return max(years), "copyright"
    m = _EDITION.search(joined)
    if m and YEAR_MIN <= int(m.group(1)) <= YEAR_MAX:
        return int(m.group(1)), "edition"
    m = _PUBLISHED.search(joined)
    if m and YEAR_MIN <= int(m.group(1)) <= YEAR_MAX:
        return int(m.group(1)), "published"
    return None, None
