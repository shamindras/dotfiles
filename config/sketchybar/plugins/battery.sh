#!/usr/bin/env bash

BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | head -1)"
CHARGING="$(echo "$BATTERY_INFO" | grep -c 'AC Power')"

if [ "$CHARGING" -gt 0 ]; then
  sketchybar --set battery label="${PERCENTAGE} 󰂄"
else
  sketchybar --set battery label="${PERCENTAGE} 󰁹"
fi
