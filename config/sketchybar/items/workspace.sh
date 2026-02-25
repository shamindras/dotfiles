#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change

sketchybar --add item workspace right \
  --set workspace \
  icon.drawing=off \
  label.color="$MAUVE" \
  label.font="JetBrainsMono Nerd Font:Bold:14.0" \
  padding_left=5 \
  padding_right=5 \
  script="$PLUGIN_DIR/workspace.sh" \
  --subscribe workspace aerospace_workspace_change
