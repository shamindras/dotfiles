#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="blog"
WORK_DIR="${REPOS_DIR:-$HOME/repos}/ss_personal_website"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

sesh_window_claude    "${SESSION}" "${WORK_DIR}"                                  # Window 1
sesh_window_yazi_tabs "${SESSION}" "${WORK_DIR}" downloads  # Window 2
sesh_window_nvim      "${SESSION}" "${WORK_DIR}"                                  # Window 3

# Window 4: the site's live preview (session-specific): same build as CI,
# drafts shown, no browser opened; it prints the clickable
# http://localhost:8080 line. For one post's worktree, Ctrl-C and run
# `just preview <short>` here.
tmux new-window -a -t "${SESSION}:\$" -n "preview" -c "${WORK_DIR}"
tmux send-keys -t "${SESSION}:preview" "just preview;clear" Enter

sesh_window_term      "${SESSION}" "${WORK_DIR}"                                  # Window 5

sesh_focus_window     "${SESSION}" "nvim"
