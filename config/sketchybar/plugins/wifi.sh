#!/usr/bin/env bash
set -Eeuo pipefail

COLOR_TEXT=0xffcdd6f4
COLOR_YELLOW=0xfff9e2af
COLOR_RED=0xfff38ba8

# Fast connectivity check (~5ms) — skip heavy system_profiler when disconnected
WIFI_IP="$(ipconfig getifaddr en0 2>/dev/null || true)"

if [ -z "$WIFI_IP" ]; then
  sketchybar --set wifi icon="󰤭" icon.color="$COLOR_RED"
  exit 0
fi

# Connected — use system_profiler for RSSI (runs async, ~3s but doesn't block bar)
RSSI="$(
  system_profiler SPAirPortDataType 2>/dev/null |
    awk '/Current Network Information:/{found=1} found && /Signal \/ Noise:/{gsub(/[^0-9-]/, " "); split($0,a); print a[1]; exit}'
)"

if [ -z "$RSSI" ]; then
  # Connected but no RSSI available — assume full strength
  sketchybar --set wifi icon="󰤨" icon.color="$COLOR_TEXT"
elif [ "$RSSI" -gt -50 ]; then
  # Excellent signal — full bars, white
  sketchybar --set wifi icon="󰤨" icon.color="$COLOR_TEXT"
elif [ "$RSSI" -gt -60 ]; then
  # Good signal — 3 bars, yellow
  sketchybar --set wifi icon="󰤥" icon.color="$COLOR_YELLOW"
elif [ "$RSSI" -gt -70 ]; then
  # Fair signal — 2 bars, yellow
  sketchybar --set wifi icon="󰤢" icon.color="$COLOR_YELLOW"
else
  # Weak signal — 1 bar, yellow
  sketchybar --set wifi icon="󰤟" icon.color="$COLOR_YELLOW"
fi
