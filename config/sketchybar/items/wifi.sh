#!/usr/bin/env bash

sketchybar --add item wifi right \
  --set wifi \
  icon.font="JetBrainsMono Nerd Font:Bold:16.0" \
  icon.color="$TEXT" \
  icon.padding_right=2 \
  label.drawing=off \
  padding_left=2 \
  padding_right=2 \
  update_freq=5 \
  script="$PLUGIN_DIR/wifi.sh" \
  --subscribe wifi wifi_change
