#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="play"
WORK_DIR="${DROPBOX_DIR:-$HOME/Dropbox}/repos/codebox"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

sesh_window_claude    "${SESSION}" "${WORK_DIR}"                                  # Window 1
sesh_window_yazi_tabs "${SESSION}" "${WORK_DIR}" 1 "${SESH_DEFAULT_YAZI_TABS[@]}"  # Window 2
sesh_window_nvim      "${SESSION}" "${WORK_DIR}"                                  # Window 3
sesh_window_term      "${SESSION}" "${WORK_DIR}"                                  # Window 4
tmux send-keys -t "${SESSION}:term" "ua && clear" Enter
sesh_focus_window     "${SESSION}" "claude"
