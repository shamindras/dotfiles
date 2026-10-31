#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="scratch"
WORK_DIR="${DROPBOX_NOTES_DIR:-${DROPBOX_DIR:-$HOME/Dropbox}/notes}/scratch"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

# The directory is created lazily by every scratch entry point; make sure it
# exists before tmux tries to cd into it on a fresh machine.
mkdir -p "${WORK_DIR}"

# Window 1: nvim with the scratch picker (newest first, H1 as label).
# Persistent pattern: nvim runs inside the window's shell, so :q drops to
# the prompt and the window survives. Picker code lives in
# config/nvim/lua/shamindras/util/scratch.lua (<leader>nf).
tmux rename-window -t "${SESSION}:1" "nvim"
tmux send-keys -l -t "${SESSION}:nvim" \
  "nvim +'autocmd User VeryLazy ++once lua require(\"shamindras.util.scratch\").pick()';clear"
tmux send-keys -t "${SESSION}:nvim" Enter

sesh_window_yazi_tabs "${SESSION}" "${WORK_DIR}" downloads  # Window 2
sesh_window_term      "${SESSION}" "${WORK_DIR}"            # Window 3
sesh_focus_window     "${SESSION}" "nvim"
