#!/usr/bin/env bash
set -Eeuo pipefail

# Only update the stored app name on actual app switches — not on
# forced updates (e.g., system wake) where $INFO is empty, which
# would clear the label and make the workspace display incomplete.
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set front_app label="$INFO"
  sketchybar --trigger aerospace_workspace_change
fi
