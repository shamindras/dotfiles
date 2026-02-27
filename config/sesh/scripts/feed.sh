#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="feed"
WORK_DIR="$HOME/Downloads"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

# Window 1: newsboat
tmux rename-window -t "${SESSION}:1" "newsboat"
tmux send-keys -t "${SESSION}:newsboat" "newsboat" Enter

# Window 2: term
sesh_window_term "${SESSION}" "${WORK_DIR}"

# Window 3: yazi
sesh_window_yazi "${SESSION}" "${WORK_DIR}"

sesh_focus_window "${SESSION}" "newsboat"
