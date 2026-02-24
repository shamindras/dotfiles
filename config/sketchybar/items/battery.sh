#!/usr/bin/env bash

sketchybar --add item battery right \
  --set battery \
  icon.drawing=off \
  label.color="$TEXT" \
  update_freq=120 \
  script="$PLUGIN_DIR/battery.sh"
