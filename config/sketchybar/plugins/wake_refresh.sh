#!/usr/bin/env bash
set -Eeuo pipefail

# Only force a global refresh on actual system wake, not on routine
# updates — otherwise sketchybar --update re-triggers this script
# in an infinite loop.
if [ "$SENDER" = "system_woke" ]; then
  sketchybar --update
fi
