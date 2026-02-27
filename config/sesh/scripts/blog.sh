#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="blog"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/REPOS/ss_personal_quarto_blog"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

sesh_window_nvim   "${SESSION}" "${WORK_DIR}"   # Window 1
sesh_window_claude "${SESSION}" "${WORK_DIR}"   # Window 2
sesh_window_term   "${SESSION}" "${WORK_DIR}"   # Window 3
sesh_window_yazi   "${SESSION}" "${WORK_DIR}"   # Window 4

# Window 5: quarto preview server (session-specific)
tmux new-window -a -t "${SESSION}:\$" -n "preview" -c "${WORK_DIR}"
tmux send-keys -t "${SESSION}:preview" "quarto preview" Enter

sesh_focus_window "${SESSION}" "nvim"
