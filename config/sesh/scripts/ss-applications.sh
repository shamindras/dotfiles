#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="ss_applications"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/REPOS/ss_applications"

# Window 1: nvim with Snacks picker
tmux rename-window -t "${SESSION}:1" "nvim"
tmux send-keys -t "${SESSION}:nvim" "nvim" Enter
sleep 1
tmux send-keys -t "${SESSION}:nvim" Space Space

# Window 2: claude-term (split vertical — claude left, terminal right)
tmux new-window -t "${SESSION}" -n "claude-term" -c "${WORK_DIR}"
tmux send-keys -t "${SESSION}:claude-term" "claude" Enter
tmux split-window -h -t "${SESSION}:claude-term" -c "${WORK_DIR}"
tmux select-pane -t "${SESSION}:claude-term.1"
tmux resize-pane -Z -t "${SESSION}:claude-term.1"

# Window 3: yazi (use zoxide for frecency, then launch yazi)
tmux new-window -t "${SESSION}" -n "yazi" -c "${WORK_DIR}"
tmux send-keys -t "${SESSION}:yazi" "z ${WORK_DIR} && y" Enter

# Focus on nvim window
tmux select-window -t "${SESSION}:nvim"
