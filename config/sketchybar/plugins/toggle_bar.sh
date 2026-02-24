#!/usr/bin/env bash

# Toggle between sketchybar and native macOS menu bar.
# When sketchybar is visible  → hide it, show native menu bar.
# When sketchybar is hidden   → show it, hide native menu bar.

HIDDEN="$(sketchybar --query bar | python3 -c "import sys,json; print(json.load(sys.stdin)['hidden'])")"

if [ "$HIDDEN" = "off" ]; then
  # Hide sketchybar, show native menu bar
  sketchybar --bar hidden=on
  osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to false'
else
  # Show sketchybar, hide native menu bar
  osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true'
  sketchybar --bar hidden=off
fi
