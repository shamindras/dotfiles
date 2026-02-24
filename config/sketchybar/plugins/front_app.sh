#!/usr/bin/env bash
set -Eeuo pipefail

# Store the app name (hidden, but queryable by workspace plugin)
INFO="${INFO:-}"
sketchybar --set front_app label="$INFO"

# Refresh workspace label with new app name
sketchybar --trigger aerospace_workspace_change
