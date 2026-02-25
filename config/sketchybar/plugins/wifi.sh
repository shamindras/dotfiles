#!/usr/bin/env bash
set -Eeuo pipefail

SSID="$(
  system_profiler SPAirPortDataType 2>/dev/null |
    awk '/Current Network Information:/{getline; gsub(/^[[:space:]]+|:[[:space:]]*$/, ""); print; exit}'
)"

COLOR_TEXT=0xffcdd6f4
COLOR_RED=0xfff38ba8

if [ -z "$SSID" ]; then
  sketchybar --set wifi icon="󰤭" icon.color="$COLOR_RED"
else
  sketchybar --set wifi icon="󰤨" icon.color="$COLOR_TEXT"
fi
