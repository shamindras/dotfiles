"""Open Library — primary API. Edition-level records by ISBN (exactly the
edition-year semantics the convention wants), plus title/author search used
only to corroborate filename parses (DjVu scans have no ISBN to offer)."""

from urllib.parse import quote

from booklib import slugs
from booklib.sources import http


def by_isbn(isbn13):
    data = http.get_json(
        f"https://openlibrary.org/api/books?bibkeys=ISBN:{isbn13}&format=json&jscmd=data"
    )
    rec = (data or {}).get(f"ISBN:{isbn13}")
    if not rec:
        return None
    return {
        "api": "openlibrary",
        "authors": [a.get("name", "") for a in rec.get("authors", []) if a.get("name")],
        "title": rec.get("title"),
        "subtitle": rec.get("subtitle"),
        "publisher": next((p.get("name") for p in rec.get("publishers", []) if p.get("name")), None),
        "year": slugs.extract_year(rec.get("publish_date", "")),
    }


def search(title, author=None, limit=3):
    q = f"https://openlibrary.org/search.json?title={quote(title)}&limit={limit}"
    if author:
        q += f"&author={quote(author)}"
    docs = (http.get_json(q) or {}).get("docs") or []
    if not docs:
        return None
    doc = docs[0]
    return {
        "api": "openlibrary-search",
        "authors": doc.get("author_name") or [],
        "title": doc.get("title"),
        "subtitle": None,
        "publisher": None,
        "year": str(doc["first_publish_year"]) if doc.get("first_publish_year") else None,
    }
