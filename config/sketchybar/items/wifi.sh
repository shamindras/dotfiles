#!/usr/bin/env bash

sketchybar --add item wifi right \
  --set wifi \
  icon.drawing=off \
  padding_left=2 \
  padding_right=2 \
  update_freq=30 \
  script="$PLUGIN_DIR/wifi.sh"
