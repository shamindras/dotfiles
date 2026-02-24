#!/usr/bin/env bash

sketchybar --add item battery right \
  --set battery \
  icon.drawing=off \
  padding_left=2 \
  padding_right=2 \
  update_freq=120 \
  script="$PLUGIN_DIR/battery.sh"
