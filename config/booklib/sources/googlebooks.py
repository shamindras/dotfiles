"""Google Books — second API for ISBN misses; edition-specific publishedDate.
Unauthenticated quota is stingy; http.py's throttle and 429 backoff apply."""

from booklib import slugs
from booklib.sources import http


def by_isbn(isbn13):
    data = http.get_json(f"https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn13}")
    items = (data or {}).get("items") or []
    if not items:
        return None
    info = items[0].get("volumeInfo", {})
    if not info.get("title"):
        return None
    return {
        "api": "googlebooks",
        "authors": info.get("authors") or [],
        "title": info.get("title"),
        "subtitle": info.get("subtitle"),
        "publisher": info.get("publisher"),
        "year": slugs.extract_year(info.get("publishedDate", "")),
    }
