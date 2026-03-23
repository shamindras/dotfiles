#!/usr/bin/env bash
set -Eeuo pipefail

# Toggle-tag script for taskwarrior-tui shortcut keys (1-9).
# If the task already has the tag, remove it; otherwise, add it.

tag="$1"
shift

for uuid in "$@"; do
    if task _get "$uuid".tags | grep -qw "$tag"; then
        task rc.bulk=0 rc.confirmation=off rc.recurrence.confirmation=off "$uuid" modify -"$tag"
    else
        task rc.bulk=0 rc.confirmation=off rc.recurrence.confirmation=off "$uuid" modify +"$tag"
    fi
done
