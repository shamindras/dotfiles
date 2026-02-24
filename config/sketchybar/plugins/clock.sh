#!/usr/bin/env bash
set -Eeuo pipefail

sketchybar --set clock label="$(date '+%a %b %-d %H:%M')"
