#!/usr/bin/env bash
set -Eeuo pipefail

VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo "0")"
MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo "false")"

# Catppuccin Mocha colors (ARGB hex)
COLOR_TEXT=0xffcdd6f4
COLOR_YELLOW=0xfff9e2af
COLOR_RED=0xfff38ba8

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  sketchybar --set volume label="󰝟" label.color="$COLOR_YELLOW"
elif [ "$VOLUME" -le 33 ]; then
  sketchybar --set volume label="󰕿 ${VOLUME}%" label.color="$COLOR_TEXT"
elif [ "$VOLUME" -lt 75 ]; then
  sketchybar --set volume label="󰖀 ${VOLUME}%" label.color="$COLOR_TEXT"
else
  sketchybar --set volume label="󰕾 ${VOLUME}%" label.color="$COLOR_RED"
fi
