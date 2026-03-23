#!/usr/bin/env bash
set -Eeuo pipefail

# Toggle between current context and "none" for taskwarrior-tui shortcut key.
# If a context is active, save it and switch to none.
# If context is none, restore the saved context (if any).

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/task/prev-context"

current=$(task _get rc.context)

if [[ -n "$current" ]]; then
    mkdir -p "$(dirname "$state_file")"
    printf '%s' "$current" > "$state_file"
    task context none
else
    if [[ -f "$state_file" ]]; then
        saved=$(cat "$state_file")
        if [[ -n "$saved" ]]; then
            task context "$saved"
        fi
    fi
fi
