#!/usr/bin/env bash
set -Eeuo pipefail

# Prune old tmux-resurrect save files, keeping the 10 most recent.
# Intended to run as a @resurrect-hook-post-save-all callback.

RESURRECT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"

# Nothing to do if the directory doesn't exist
[[ -d "$RESURRECT_DIR" ]] || exit 0

# Collect save files sorted newest-first (filename encodes the timestamp)
mapfile -t saves < <(
  find "$RESURRECT_DIR" -maxdepth 1 -name 'tmux_resurrect_*.txt' -type f \
    | sort -r
)

KEEP=10

# Nothing to prune if we have KEEP or fewer saves
(( ${#saves[@]} > KEEP )) || exit 0

# Delete everything beyond the newest KEEP files
for file in "${saves[@]:$KEEP}"; do
  rm -f "$file"

  # Remove matching pane-contents archive if present
  pane_archive="${file%.txt}.tar.gz"
  rm -f "$pane_archive"
done
