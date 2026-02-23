#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="dotfiles"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/REPOS/dotfiles"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

sesh_window_nvim   "${SESSION}" "${WORK_DIR}"   # Window 1
sesh_window_claude "${SESSION}" "${WORK_DIR}"   # Window 2
sesh_window_term   "${SESSION}" "${WORK_DIR}"   # Window 3
sesh_window_yazi   "${SESSION}" "${WORK_DIR}"   # Window 4
sesh_focus_window  "${SESSION}" "nvim"
