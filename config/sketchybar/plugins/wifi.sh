#!/usr/bin/env bash

SSID="$(networksetup -getairportnetwork en0 | sed 's/Current Wi-Fi Network: //')"

if [ "$SSID" = "You are not associated with an AirPort network." ]; then
  sketchybar --set wifi label="󰤭 Disconnected"
else
  sketchybar --set wifi label="󰤨 $SSID"
fi
