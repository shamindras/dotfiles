"""Metadata resolution ladder → proposed stem + confidence.

Rungs: bare ISBN in filename → in-file ISBN/DOI → API record → embedded
metadata (corroboration, capped) → structured filename parse (capped) →
review queue. Nothing below the auto threshold is ever applied silently.

Year rule (load-bearing): the edition in hand wins. An in-file © year that
is NEWER than the API's year is trusted outright (APIs habitually return
first-publication years); any other disagreement forces review.
"""

import difflib
import json
import re
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from booklib import config, slugs
from booklib.manifest import now
from booklib.sources import crossref, embedded, epub, filename, googlebooks, openlibrary, pagetext


def resolve_pending(manifest, limit=None, offline=False, shas=None, retry_review=False, dirs=None):
    """Resolve pending/failed rows (optionally re-run needs_review ones,
    e.g. after going online or improving a parser); returns per-status counts."""
    statuses = ("pending", "failed", "needs_review") if retry_review else ("pending", "failed")
    rows = manifest.rows_with_status(*statuses)
    if shas is not None:
        rows = [r for r in rows if r["sha256"] in set(shas)]
    # Paths resolved up front: the sqlite connection stays on this thread.
    # Dir filter matches if ANY copy of the content lives under the dirs
    # (duplicates across dirs share one metadata row).
    targets = [(r["sha256"], manifest.path_for_sha(r["sha256"]), r["kind"]) for r in rows]
    if dirs:
        prefixes = tuple(str(d).rstrip("/") + "/" for d in dirs)
        targets = [
            t for t in targets
            if any(p.startswith(prefixes) for p in manifest.paths_for_sha(t[0]))
        ]
    if limit:
        targets = targets[:limit]

    # Stream: store each result as it arrives, commit + report periodically —
    # progress is visible from outside and an interrupted run keeps its work.
    counts = {}
    done = 0
    with ThreadPoolExecutor(max_workers=4) as ex:
        for (sha, _, _), res in zip(
            targets, ex.map(lambda t: _gather(t[1], t[2], offline), targets)
        ):
            status = _store(manifest, sha, res)
            counts[status] = counts.get(status, 0) + 1
            done += 1
            if done % 50 == 0:
                manifest.commit()
                print(
                    f"[{done}/{len(targets)}] "
                    + "  ".join(f"{k} {v}" for k, v in sorted(counts.items())),
                    flush=True,
                )
    manifest.commit()
    return counts


# -- evidence gathering (no DB access: runs in worker threads) --------------


def _gather(path, kind, offline):
    try:
        return _gather_inner(path, kind, offline)
    except Exception as e:  # one bad file must never kill the batch
        return {"error": f"{type(e).__name__}: {e}"}


def _gather_inner(path, kind, offline):
    if path is None or not Path(path).exists():
        return {"error": "path missing"}
    name = Path(path).name
    ev = {
        "path": path,
        "name": name,
        "kind": kind,
        "fn": filename.parse(name),
        "fn_isbn": filename.bare_isbn(name),
        "fn_doi": filename.embedded_doi(name),
        "isbns": [],
        "doi": None,
        "ev_year": None,
        "ev_rung": None,
        "api": None,
        "epub": None,
        "embedded": None,
    }
    if kind == "pdf":
        text = pagetext.extract_text(path)
        if len(text.strip()) < 200:
            # Image-only scan: OCR the first pages so the standard evidence
            # checks (ISBN, © year, title-in-text) can still run.
            ocr = pagetext.ocr_text(path)
            if ocr.strip():
                text = ocr
                ev["ocr"] = True
        ev["isbns"] = pagetext.find_isbns(text)
        ev["doi"] = pagetext.find_doi(text)
        ev["ev_year"], ev["ev_rung"] = pagetext.year_evidence(text)
        ev["embedded"] = embedded.pdf_meta(path)
        ev["text_head"] = text[:20000].lower()
    elif kind == "djvu":
        # Image-only by definition: OCR the front pages so ISBN/©/title
        # evidence works for scans too (same rung as textless pdfs).
        text = pagetext.ocr_text(path)
        if text.strip():
            ev["ocr"] = True
            ev["isbns"] = pagetext.find_isbns(text)
            ev["doi"] = pagetext.find_doi(text)
            ev["ev_year"], ev["ev_rung"] = pagetext.year_evidence(text)
            ev["text_head"] = text[:20000].lower()
    elif kind == "epub":
        ev["epub"] = epub.metadata(path)

    if not offline:
        for isbn in ([ev["fn_isbn"]] if ev["fn_isbn"] else []) + ev["isbns"]:
            ev["api"] = openlibrary.by_isbn(isbn) or googlebooks.by_isbn(isbn)
            if ev["api"]:
                ev["api_isbn"] = isbn
                break
        if not ev["api"] and (ev.get("fn_doi") or ev["doi"]):
            ev["doi"] = ev.get("fn_doi") or ev["doi"]
            # DOI sanity check: DOIs harvested from page text are often a
            # CITED work's (references bleed into front matter). Only trust
            # the Crossref record if its title appears in the book itself.
            rec = crossref.by_doi(ev["doi"])
            if rec and _title_in_text(rec.get("title"), ev.get("text_head")):
                ev["api"] = rec
            elif rec:
                ev["doi"] = None  # wrong work — discard both record and DOI
        # Second-source year agreement: an independent API confirming the
        # primary record's year earns corroboration in scoring.
        if ev.get("api") and ev.get("api_isbn") and ev["api"].get("year"):
            other = googlebooks if ev["api"]["api"] == "openlibrary" else openlibrary
            second = other.by_isbn(ev["api_isbn"])
            if second and second.get("year") == ev["api"]["year"]:
                ev["api2_agrees"] = second["api"]
        if not ev["api"] and ev["fn"] and ev["fn"].get("title") and kind == "djvu":
            # image-only scans: corroborate the filename parse by search
            ev["api"] = openlibrary.search(
                ev["fn"]["title"], ev["fn"]["authors"][0] if ev["fn"]["authors"] else None
            )
    return ev


# -- scoring + storage ------------------------------------------------------


def _title_agrees(a, b):
    if not (a and b):
        return False
    ratio = difflib.SequenceMatcher(None, a.lower(), b.lower()).ratio()
    return ratio >= 0.6


def _title_in_text(title, text_head):
    if not (title and text_head):
        return False
    words = [w for w in re.sub(r"[^a-z0-9 ]", "", title.lower()).split() if len(w) > 2]
    if len(words) >= 2:
        return all(w in text_head for w in words)
    # Single-word titles ("Thermodynamics") corroborate only when the word
    # is long enough to be distinctive — short generics ("Analysis",
    # "Geometry") appear incidentally in almost any math text.
    return len(words) == 1 and len(words[0]) >= 9 and words[0] in text_head


def _surname_agrees(fn, api):
    if not (fn and fn.get("authors") and api and api.get("authors")):
        return False
    return slugs.surname_slug(fn["authors"][0]) == slugs.surname_slug(api["authors"][0])


def _store(manifest, sha, ev):
    if "error" in ev:
        manifest.set_metadata(sha, status="failed", source=ev["error"])
        return "failed"

    fn, api, ep = ev["fn"], ev["api"], ev["epub"]
    conf = 0
    source = []
    forced_review = False
    isbn13 = ev.get("api_isbn") or ev["fn_isbn"] or (ev["isbns"][0] if ev["isbns"] else None)

    # Primary record preference: API > epub OPF > filename > embedded.
    api_is_search = bool(api) and api.get("api") == "openlibrary-search"
    if api and not api_is_search:
        conf = 60
        source.append(api["api"])
        record = dict(api)
    elif ep and ep.get("authors") and ep.get("title") and ep.get("year"):
        conf = 85  # proven-reliable rung: our epub OPF metadata
        source.append("opf")
        record = {"authors": ep["authors"], "title": ep["title"], "subtitle": None,
                  "publisher": None, "year": ep["year"]}
    elif fn and fn.get("title"):
        conf = 70
        source.append("filename")
        record = {"authors": fn["authors"], "title": fn["title"], "subtitle": None,
                  "publisher": fn["publisher"], "year": fn["year"]}
        if api_is_search:  # corroboration only — never overrides the parse
            source.append("ol-search")
            if _title_agrees(fn["title"], api["title"]) and _surname_agrees(fn, api):
                conf += 10
    elif ev["embedded"] and (ev["embedded"]["title"] or ev["embedded"]["authors"]):
        conf = 40
        source.append("embedded")
        record = dict(ev["embedded"], subtitle=None, publisher=None, year=None)
    else:
        record = None

    if record and api and not api_is_search:
        # Title corroboration: filename agreement, or (for ISBN-named files
        # with no filename signal) the API title appearing verbatim in the
        # book's own first pages.
        if fn and _title_agrees(fn.get("title"), api.get("title")):
            conf += 15
        elif _title_in_text(api.get("title"), ev.get("text_head")):
            conf += 15
        if _surname_agrees(fn, api):
            conf += 10
        if ev.get("api2_agrees"):
            conf += 10  # independent second API confirms the year

    # -- year: edition-in-hand rule ------------------------------------
    api_year = int(record["year"]) if record and record.get("year") else None
    ev_year, ev_rung = ev["ev_year"], ev["ev_rung"]
    year = None
    if ev_year and api_year:
        if ev_year == api_year:
            year = ev_year
            conf += 15
        elif ev_rung == "copyright" and ev_year > api_year:
            year = ev_year  # API returned first-publication year
        else:
            year = ev_year
            forced_review = True
    elif ev_year:
        year = ev_year
        # Tiebreak rule (user-approved, 2026-08-17): a filename year equal
        # to the © year, or exactly one less, is agreement — publishers
        # routinely post-date the copyright page (CRC: 2006 file, © 2007).
        if fn and fn.get("year") and int(fn["year"]) in (ev_year, ev_year - 1):
            conf += 15
    elif api_year:
        year = api_year
        # No in-file © evidence, but the (trusted, user-named) filename year
        # agreeing with the API is corroboration of its own.
        if fn and fn.get("year") and int(fn["year"]) == api_year:
            conf += 10

    first_pub = api_year if (api_year and year and api_year < year) else None

    # -- stem ----------------------------------------------------------
    stem = None
    if record and record.get("authors") and record.get("title") and year:
        vol = slugs.volume_suffix(record.get("title"), record.get("subtitle"), ev["name"])
        stem = slugs.make_stem(
            slugs.first_surname(record["authors"]), str(year),
            slugs.title_slug(record["title"]), vol,
        )
    if not stem:
        forced_review = True

    # -- collisions (kind-scoped: format twins may share a stem) -------
    if stem:
        holder = manifest.stem_taken(stem, kind=ev["kind"])
        if holder and holder != sha:
            forced_review = True
            source.append("collision")
            n = 2
            while manifest.stem_taken(f"{stem}-{n}", kind=ev["kind"]):
                n += 1
            stem = f"{stem}-{n}"

    status = "needs_review" if (forced_review or conf < config.AUTO_CONFIDENCE) else "resolved"
    if conf < config.REVIEW_PREFILL and status == "needs_review":
        stem = None  # low confidence: review starts from blanks

    evidence_bits = []
    if isbn13:
        evidence_bits.append(f"isbn:{isbn13}")
    if ev["doi"]:
        evidence_bits.append(f"doi:{ev['doi']}")
    if ev_year:
        evidence_bits.append(f"{ev_rung}:{ev_year}")
    if fn and fn.get("year"):
        evidence_bits.append(f"fn-year:{fn['year']}")
    if api:
        evidence_bits.append(f"api:{api['api']}" + (f"={api_year}" if api_year else ""))
    if ev.get("api2_agrees"):
        evidence_bits.append(f"api2:{ev['api2_agrees']}")
    if ev.get("ocr"):
        evidence_bits.append("ocr")

    manifest.set_metadata(
        sha,
        authors_json=json.dumps(record["authors"]) if record and record.get("authors") else None,
        title=record.get("title") if record else None,
        subtitle=record.get("subtitle") if record else None,
        publisher=record.get("publisher") if record else None,
        edition_year=year,
        first_pub_year=first_pub,
        year_evidence=" ".join(evidence_bits) or None,
        isbn13=isbn13,
        doi=ev["doi"],
        source="+".join(source) or None,
        confidence=conf,
        status=status,
        proposed_stem=stem,
        resolved_at=now(),
    )

    # Already wearing the right name? Applied, no rename needed.
    if status == "resolved" and stem and Path(ev["path"]).stem == stem:
        manifest.mark_applied(sha, stem)
        return "applied"
    return status
