#!/usr/bin/env bash

# Store the app name (hidden, but queryable by workspace plugin)
sketchybar --set front_app label="$INFO"

# Refresh workspace label with new app name
sketchybar --trigger aerospace_workspace_change
