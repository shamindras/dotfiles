#!/usr/bin/env bash

sketchybar --add item clock right \
  --set clock \
  icon.drawing=off \
  update_freq=30 \
  script="$PLUGIN_DIR/clock.sh"
