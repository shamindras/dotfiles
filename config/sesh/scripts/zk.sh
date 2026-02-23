#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="zk"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/notes/zk"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

# Window 1: rename only (defer send-keys until all windows exist)
tmux rename-window -t "${SESSION}:1" "zk"

sesh_window_claude "${SESSION}" "${WORK_DIR}"   # Window 2
sesh_window_term   "${SESSION}" "${WORK_DIR}"   # Window 3
sesh_window_yazi   "${SESSION}" "${WORK_DIR}"   # Window 4

# Now send zk startup command to window 1.
# Uses explicit binaries instead of the `kds` zsh alias so the command
# works even if the pane's shell hasn't finished loading .zshrc (cold-start
# race when `sesh connect zk` is run from a fresh terminal with no tmux server).
tmux send-keys -l -t "${SESSION}:zk" \
  "cd '${WORK_DIR}' && tmux resize-window -A && rsync -au --delete ~/.config/zk/templates/ '${WORK_DIR}/.zk/templates/' 2>/dev/null; zk daily"
tmux send-keys -t "${SESSION}:zk" Enter

sesh_focus_window "${SESSION}" "zk"
