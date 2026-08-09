"""Crossref — DOI resolution only (Springer/CRC monographs embed DOIs).
Bibliographic *search* for books is deliberately not used: monograph
coverage and ranking are poor. The polite-pool mailto rides in http.py's
User-Agent."""

from booklib import slugs
from booklib.sources import http


def by_doi(doi):
    msg = (http.get_json(f"https://api.crossref.org/works/{doi}") or {}).get("message")
    if not msg:
        return None
    titles = msg.get("title") or []
    issued = msg.get("issued", {}).get("date-parts") or [[None]]
    year = issued[0][0]
    return {
        "api": "crossref",
        "authors": [
            f"{a.get('family', '')}, {a.get('given', '')}".strip(", ")
            for a in msg.get("author", [])
            if a.get("family")
        ],
        "title": titles[0] if titles else None,
        "subtitle": next(iter(msg.get("subtitle") or []), None),
        "publisher": msg.get("publisher"),
        "year": slugs.extract_year(str(year)) if year else None,
    }
