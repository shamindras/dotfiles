#!/usr/bin/env bash
set -Eeuo pipefail

SSID="$(
  system_profiler SPAirPortDataType 2>/dev/null |
    awk '/Current Network Information:/{getline; gsub(/^[[:space:]]+|:[[:space:]]*$/, ""); print; exit}'
)"

if [ -z "$SSID" ]; then
  sketchybar --set wifi label="󰤭"
else
  sketchybar --set wifi label="󰤨"
fi
