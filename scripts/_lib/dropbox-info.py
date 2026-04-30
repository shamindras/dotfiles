#!/usr/bin/env python3
"""Print the synced Dropbox root path from ~/.dropbox/info.json.

Internal helper for ./bootstrap. Handles both `personal` and `business`
top-level keys. Exits non-zero with a stderr message if the file is missing,
malformed, or has no `path` field.
"""

import json
import os
import sys


def main() -> int:
    info_path = os.path.expanduser("~/.dropbox/info.json")
    try:
        with open(info_path) as f:
            data = json.load(f)
    except (OSError, ValueError) as e:
        print(f"failed to read {info_path}: {e}", file=sys.stderr)
        return 1
    for key in ("personal", "business"):
        entry = data.get(key)
        if isinstance(entry, dict) and entry.get("path"):
            print(entry["path"])
            return 0
    print(f"no `path` field found in {info_path}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
