#!/usr/bin/env bash

WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null || echo "")"
FRONT_APP="$(sketchybar --query front_app 2>/dev/null | jq -r '.label.value')"

if [ -n "$WORKSPACE" ] && [ -n "$FRONT_APP" ]; then
  sketchybar --set workspace label="$WORKSPACE $FRONT_APP"
elif [ -n "$WORKSPACE" ]; then
  sketchybar --set workspace label="$WORKSPACE"
fi
