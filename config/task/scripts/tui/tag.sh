#!/usr/bin/env bash
set -Eeuo pipefail

# Quick-tag script for taskwarrior-tui shortcut keys (1-9).
# Usage: tag.sh <tag_name> <task_uuid...>
# The tag name is passed as the first argument via the taskrc shortcut config.
# Remaining arguments are task UUIDs provided by taskwarrior-tui.

tag="$1"
shift
task rc.bulk=0 rc.confirmation=off rc.recurrence.confirmation=off "$@" modify +"$tag"
