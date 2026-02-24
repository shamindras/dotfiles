#!/usr/bin/env bash

sketchybar --add item clock right \
  --set clock \
  icon.drawing=off \
  label.color="$TEXT" \
  update_freq=30 \
  script="$PLUGIN_DIR/clock.sh"
