"""Cached, rate-limited HTTP GET for the metadata APIs.

Cache-before-network: every response (including 404 negative hits) is stored
as one JSON file under $XDG_CACHE_HOME/booklib/http/, so re-resolving the
library never re-fetches. Per-host minimum interval + exponential backoff
with jitter on 429/5xx keeps us polite everywhere.
"""

import hashlib
import json
import random
import threading
import time
import urllib.error
import urllib.request
from urllib.parse import urlsplit

from booklib import config

_lock = threading.Lock()
_last_request = {}  # host -> monotonic ts

USER_AGENT = f"booklib/1.0 (mailto:{config.mailto()})"
MIN_INTERVAL = 1.0  # seconds per host
RETRIES = 4


def _cache_path(url):
    return config.HTTP_CACHE_DIR / (hashlib.sha256(url.encode()).hexdigest() + ".json")


def _throttle(host):
    with _lock:
        wait = _last_request.get(host, 0) + MIN_INTERVAL - time.monotonic()
        _last_request[host] = max(time.monotonic(), _last_request.get(host, 0) + MIN_INTERVAL)
    if wait > 0:
        time.sleep(wait)


def get_json(url):
    """Parsed JSON body for url, or None on miss/failure. Never raises."""
    cache = _cache_path(url)
    if cache.exists():
        entry = json.loads(cache.read_text())
        return json.loads(entry["body"]) if entry["status"] == 200 else None

    host = urlsplit(url).netloc
    status, body = None, None
    for attempt in range(RETRIES):
        _throttle(host)
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=30) as resp:
                status, body = resp.status, resp.read().decode("utf-8", "replace")
            break
        except urllib.error.HTTPError as e:
            status = e.code
            if status == 404:
                body = ""
                break
            if status == 429 or status >= 500:
                time.sleep(2**attempt + random.random())
                continue
            body = ""
            break
        except (urllib.error.URLError, OSError, TimeoutError):
            time.sleep(2**attempt + random.random())
    if status is None:
        return None  # network dead: not cached, retried next resolve

    # Cache definitive answers only — 200s and 404 misses. Transient failures
    # (429 quota, 5xx) must stay uncached or one bad hour poisons the ladder.
    if status in (200, 404):
        config.HTTP_CACHE_DIR.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps({"url": url, "status": status, "body": body or ""}))
    if status != 200:
        return None
    try:
        return json.loads(body)
    except json.JSONDecodeError:
        return None
