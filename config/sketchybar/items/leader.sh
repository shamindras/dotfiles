#!/usr/bin/env bash

sketchybar --add item leader left \
  --set leader \
    icon.drawing=off \
    label.color="$LAVENDER" \
    label.font="JetBrainsMono Nerd Font:Bold:15.0" \
    padding_left=-10 \
    padding_right=0 \
    label.padding_left=4 \
    label.padding_right=4 \
    background.color="$PILL_BG" \
    background.height="$PILL_HEIGHT" \
    background.corner_radius="$PILL_RADIUS" \
    background.border_width="$PILL_BORDER_WIDTH" \
    background.border_color="$LEADER_PILL_BORDER" \
    drawing=off
