#!/usr/bin/env bash

sketchybar --add item battery right \
  --set battery \
  icon.drawing=off \
  label.color="$TEXT" \
  padding_left=2 \
  padding_right=2 \
  update_freq=120 \
  script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery power_source_change
