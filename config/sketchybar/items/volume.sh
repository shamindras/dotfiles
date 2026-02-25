#!/usr/bin/env bash

sketchybar --add item volume right \
  --set volume \
  icon.drawing=off \
  label.color="$TEXT" \
  padding_left=2 \
  padding_right=2 \
  update_freq=5 \
  script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change
