#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change

sketchybar --add item workspace left \
  --set workspace \
  icon.drawing=off \
  label.color="$MAUVE" \
  label.font="JetBrainsMono Nerd Font:Bold:16.0" \
  script="$PLUGIN_DIR/workspace.sh" \
  --subscribe workspace aerospace_workspace_change
