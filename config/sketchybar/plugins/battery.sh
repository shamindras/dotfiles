#!/usr/bin/env bash
set -Eeuo pipefail

BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | head -1 || echo "??%")"
PCT_NUM="${PERCENTAGE%\%}"
CHARGING="$(echo "$BATTERY_INFO" | grep -c 'AC Power' || true)"

# Catppuccin Mocha colors (ARGB hex)
COLOR_TEXT=0xffcdd6f4
COLOR_GREEN=0xffa6e3a1
COLOR_YELLOW=0xfff9e2af
COLOR_RED=0xfff38ba8

if [ "$CHARGING" -gt 0 ]; then
  ICON="󰂄"
  if [ "$PCT_NUM" -ge 100 ]; then
    COLOR="$COLOR_GREEN"
  else
    COLOR="$COLOR_YELLOW"
  fi
else
  ICON="󰁹"
  if [ "$PCT_NUM" -le 20 ]; then
    COLOR="$COLOR_RED"
  else
    COLOR="$COLOR_TEXT"
  fi
fi

sketchybar --set battery label="$ICON ${PERCENTAGE}" label.color="$COLOR"
