#!/usr/bin/env bash
set -Eeuo pipefail

VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo "0")"

if [ "$VOLUME" -eq 0 ]; then
  ICON="󰝟"
elif [ "$VOLUME" -le 33 ]; then
  ICON="󰕿"
elif [ "$VOLUME" -le 66 ]; then
  ICON="󰖀"
else
  ICON="󰕾"
fi

sketchybar --set volume label="$ICON"
