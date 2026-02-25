#!/usr/bin/env bash
set -Eeuo pipefail

VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo "0")"
MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo "false")"

# Catppuccin Mocha colors (ARGB hex)
COLOR_TEXT=0xffcdd6f4
COLOR_YELLOW=0xfff9e2af
COLOR_RED=0xfff38ba8

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  sketchybar --set volume icon="󰖁" icon.color="$COLOR_YELLOW" label.drawing=off
else
  if [ "$VOLUME" -le 33 ]; then
    ICON="󰕿" COLOR="$COLOR_TEXT"
  elif [ "$VOLUME" -lt 60 ]; then
    ICON="󰖀" COLOR="$COLOR_TEXT"
  else
    ICON="󰕾" COLOR="$COLOR_RED"
  fi
  sketchybar --set volume icon="$ICON" icon.color="$COLOR" label="${VOLUME}%" label.color="$COLOR" label.drawing=on
fi
