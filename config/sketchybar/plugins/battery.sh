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

# Color by percentage regardless of charging state
if [ "$PCT_NUM" -ge 95 ]; then
  COLOR="$COLOR_GREEN"
elif [ "$PCT_NUM" -le 20 ]; then
  COLOR="$COLOR_RED"
else
  COLOR="$COLOR_TEXT"
fi

# Lightning bolt indicates charging, battery icon otherwise
if [ "$CHARGING" -gt 0 ]; then
  ICON="󱐋"
else
  ICON="󰁹"
fi

sketchybar --set battery icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}" label.color="$COLOR"
