#!/usr/bin/env bash
set -Eeuo pipefail

# Prefer the env var passed by aerospace's exec-on-workspace-change;
# fall back to querying aerospace directly (e.g., on app-switch triggers).
WORKSPACE="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null || echo "")}"
FRONT_APP="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null || echo "")"

if [ -n "$WORKSPACE" ] && [ -n "$FRONT_APP" ]; then
  sketchybar --set workspace label="$WORKSPACE $FRONT_APP"
elif [ -n "$WORKSPACE" ]; then
  sketchybar --set workspace label="$WORKSPACE"
fi
