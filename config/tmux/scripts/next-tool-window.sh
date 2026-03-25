#!/usr/bin/env bash
set -Eeuo pipefail

# Open a new tmux window: first invocation uses <name>, then <name>-1, <name>-2, ...
# Usage: next-tool-window.sh <window-name> <command> [args...]
# Example: next-tool-window.sh claude claude
#          next-tool-window.sh yazi yazi

name="${1:?Usage: next-tool-window.sh <window-name> <command> [args...]}"
shift
cmd=("${@:?Usage: next-tool-window.sh <window-name> <command> [args...]}")

# Check if a window with the base name already exists
has_base=false
max=0
while IFS= read -r wname; do
  if [[ "$wname" == "$name" ]]; then
    has_base=true
  elif [[ "$wname" =~ ^${name}-([0-9]+)$ ]]; then
    n="${BASH_REMATCH[1]}"
    (( n > max )) && max="$n"
  fi
done < <(tmux list-windows -F '#W')

if [[ "$has_base" == false && "$max" -eq 0 ]]; then
  # No existing windows — use the bare name
  window_name="$name"
else
  # Increment from the highest existing number
  window_name="${name}-$(( max + 1 ))"
fi

tmux new-window -a -n "$window_name" -c "#{pane_current_path}" "${cmd[@]}"
