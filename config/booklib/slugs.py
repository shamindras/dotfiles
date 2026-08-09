"""Naming-convention slug rules — single source of truth.

Shared by config/bin/rename-ebooks (epub arrivals) and the booklib pipeline.
Convention: <first-author-lastname>-<edition-year>-<main-title-max-6-words>
all lowercase, strictly [a-z0-9-]. Year is the edition in hand, never the
original first-publication year.
"""

import re
import unicodedata

PARTICLES = {"de", "du", "da", "van", "von", "der", "den", "la", "le", "di", "del", "dos"}
MAX_TITLE_WORDS = 6

# Never surnames: generational/honorific suffixes and editor/author markers.
_SUFFIXES = {"jr", "sr", "ii", "iii", "iv", "phd", "md", "esq", "dr", "prof",
             "ed", "eds", "auth", "auths", "author", "editor", "editors", "trans"}
# Initial tokens: "D." / "D" / "D.O." — one or more single letters, dotted or
# bare. A bare two-letter token like "Do" or "Ng" is a real name, not initials.
_INITIALS = re.compile(r"(?:[A-Za-z]\.)+|[A-Za-z]")

_ROMAN = {"i": 1, "ii": 2, "iii": 3, "iv": 4, "v": 5, "vi": 6, "vii": 7, "viii": 8, "ix": 9, "x": 10}
_VOL_RE = re.compile(r"\b(?:vol(?:ume)?\.?|part)\s*([0-9]+|[ivx]+)\b", re.IGNORECASE)


def ascii_fold(s):
    return "".join(c for c in unicodedata.normalize("NFD", s) if not unicodedata.combining(c))


def split_authors(raw):
    """'A; B & C and D' -> ['A', 'B', 'C', 'D'] (original name forms kept)."""
    parts = re.split(r"[;&]| and ", raw or "")
    return [p.strip().rstrip(";,") for p in parts if p.strip().rstrip(";,")]


def _is_initial(tok):
    return _INITIALS.fullmatch(tok) is not None


def _is_suffix(tok):
    return re.sub(r"[^a-z]", "", tok.lower()) in _SUFFIXES


def surname_slug(name):
    """First-author surname slug: 'Koul, Hira L.' -> koul, 'Marcus du Sautoy'
    -> dusautoy, 'Shklarsky D. O.' -> shklarsky (initials and Jr/PhD-style
    suffixes can never be the surname). None when nothing usable remains."""
    name = (name or "").strip().rstrip(";,")
    if not name:
        return None
    surname = None
    if "," in name:
        head = name.split(",")[0].strip()
        if head and not _is_initial(head) and not _is_suffix(head):
            surname = head
    if surname is None:
        tokens = [t for t in name.replace(",", " ").split()
                  if t and not _is_initial(t) and not _is_suffix(t)]
        if not tokens:
            return None
        surname_parts = [tokens[-1]]
        for tok in reversed(tokens[:-1]):
            if tok.lower() in PARTICLES:
                surname_parts.insert(0, tok)
            else:
                break
        # A particle-only result (a lone trailing 'de'/'van') is not a name.
        if all(p.lower() in PARTICLES for p in surname_parts):
            return None
        surname = "".join(surname_parts)
    slug = re.sub(r"[^a-z0-9]", "", ascii_fold(surname).lower())
    return slug if len(slug) >= 2 else None


def first_surname(authors):
    """Surname slug of the first author that yields one — resolvers should
    fall through junk entries ('PhD', bare initials) to a usable name."""
    for name in authors or []:
        slug = surname_slug(name)
        if slug:
            return slug
    return None


def title_slug(title):
    """Main title only (subtitle dropped), <= MAX_TITLE_WORDS hyphenated words."""
    if not (title or "").strip():
        return None
    main = re.split(r"[:;?(–—]", title.strip())[0]
    main = ascii_fold(main).lower().replace("&", " and ")
    words = re.sub(r"[^a-z0-9 ]", "", main).split()
    return "-".join(words[:MAX_TITLE_WORDS]) or None


def extract_year(text):
    m = re.search(r"(19|20)\d{2}", text or "")
    return m.group(0) if m else None


def volume_suffix(*texts):
    """'-volN' when any text names a volume/part — guards multi-volume sets
    whose distinguishing number lives in the subtitle that title_slug drops."""
    for text in texts:
        m = _VOL_RE.search(text or "")
        if m:
            tok = m.group(1).lower()
            n = int(tok) if tok.isdigit() else _ROMAN.get(tok)
            if n:
                return f"-vol{n}"
    return ""


def make_stem(author, year, title, vol=""):
    """Assemble and validate a filename stem; None if any part is missing."""
    if not (author and year and title):
        return None
    stem = f"{author}-{year}-{title}{vol}"
    return stem if re.fullmatch(r"[a-z0-9-]+", stem) else None
