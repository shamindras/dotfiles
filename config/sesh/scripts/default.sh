#!/usr/bin/env bash
set -Eeuo pipefail

# Generic layout for ad-hoc sessions, registered as [default_session]
# startup_command in sesh.toml. Per-session startup_commands override it,
# so this runs only for sessions with no [[session]] entry.
#
# sesh send-keys this into pane 1 of the new session, so context is
# self-derived. Optional args override for detached creation:
#   default.sh [<session> [<work_dir>]]
SESSION="${1:-$(tmux display-message -p '#S')}"
WORK_DIR="${2:-$PWD}"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

sesh_window_claude    "${SESSION}" "${WORK_DIR}"                                  # Window 1
sesh_window_yazi_tabs "${SESSION}" "${WORK_DIR}" 1 "${SESH_DEFAULT_YAZI_TABS[@]}"  # Window 2
sesh_window_nvim      "${SESSION}" "${WORK_DIR}"                                  # Window 3
sesh_window_term      "${SESSION}" "${WORK_DIR}"                                  # Window 4
sesh_focus_window     "${SESSION}" "claude"
