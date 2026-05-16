#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="feed"
WORK_DIR="$HOME/Downloads"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

# Window 1: newsboat
tmux rename-window -t "${SESSION}:1" "newsboat"
tmux send-keys -t "${SESSION}:newsboat" "newsboat;clear" Enter

# Window 2: yazi with preloaded tabs (WORK_DIR is ~/Downloads so it's tab 0, active)
sesh_window_yazi_tabs "${SESSION}" "${WORK_DIR}" 0 "${SESH_BOOKS_TABS[@]}"

# Window 3: term
sesh_window_term "${SESSION}" "${WORK_DIR}"

sesh_focus_window "${SESSION}" "newsboat"
