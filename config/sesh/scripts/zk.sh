#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="zk"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/notes/zk"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

# Window 1: zk (syncs templates + opens daily note in nvim)
tmux rename-window -t "${SESSION}:1" "zk"
tmux send-keys -t "${SESSION}:zk" "kds" Enter

sesh_window_claude "${SESSION}" "${WORK_DIR}"   # Window 2
sesh_window_term   "${SESSION}" "${WORK_DIR}"   # Window 3
sesh_window_yazi   "${SESSION}" "${WORK_DIR}"   # Window 4
sesh_focus_window  "${SESSION}" "zk"
