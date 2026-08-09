"""EPUB OPF metadata extraction (shared with config/bin/rename-ebooks)."""

import xml.etree.ElementTree as ET
import zipfile

DC = "{http://purl.org/dc/elements/1.1/}"


def opf_root(path):
    """Parsed OPF XML root, located via META-INF/container.xml with a
    first-*.opf fallback; None when the epub is unreadable."""
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        opf = None
        try:
            container = ET.fromstring(z.read("META-INF/container.xml"))
            el = container.find(".//{*}rootfile")
            if el is not None:
                opf = el.get("full-path")
        except Exception:
            pass
        if opf is None or opf not in names:
            opf = next((n for n in names if n.endswith(".opf")), None)
        if opf is None:
            return None
        return ET.fromstring(z.read(opf))


def metadata(path):
    """{'authors': [...], 'title': str|None, 'year': str|None} or None."""
    from booklib import slugs

    try:
        root = opf_root(path)
    except Exception:
        return None
    if root is None:
        return None
    authors = []
    for el in root.findall(f".//{DC}creator"):
        authors.extend(slugs.split_authors(el.text or ""))
    title_el = root.find(f".//{DC}title")
    title = (title_el.text or "").strip() if title_el is not None else None
    year = None
    for el in root.findall(f".//{DC}date"):
        year = slugs.extract_year(el.text or "")
        if year:
            break
    return {"authors": authors, "title": title or None, "year": year}
