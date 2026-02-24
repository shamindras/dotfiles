#!/usr/bin/env bash

VOLUME="$(osascript -e 'output volume of (get volume settings)')"

if [ "$VOLUME" -eq 0 ] 2>/dev/null; then
  ICON="󰝟"
elif [ "$VOLUME" -le 33 ] 2>/dev/null; then
  ICON="󰕿"
elif [ "$VOLUME" -le 66 ] 2>/dev/null; then
  ICON="󰖀"
else
  ICON="󰕾"
fi

sketchybar --set volume label="${ICON}"
