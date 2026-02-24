#!/usr/bin/env bash

sketchybar --add item wifi right \
  --set wifi \
  icon.drawing=off \
  label.color="$TEXT" \
  update_freq=5 \
  script="$PLUGIN_DIR/wifi.sh"
