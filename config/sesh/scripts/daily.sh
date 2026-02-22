#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="daily"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/notes/zk"

# Window 1: zk (syncs templates + opens daily note in nvim)
tmux rename-window -t "${SESSION}:1" "zk"
tmux send-keys -t "${SESSION}:zk" "kds" Enter

# Window 2: claude-term (split vertical — claude left, terminal right)
tmux new-window -t "${SESSION}" -n "claude-term" -c "${WORK_DIR}"
tmux send-keys -t "${SESSION}:claude-term" "claude" Enter
tmux split-window -h -t "${SESSION}:claude-term" -c "${WORK_DIR}"
tmux select-pane -t "${SESSION}:claude-term.1"
tmux resize-pane -Z -t "${SESSION}:claude-term.1"

# Window 3: yazi (direct command for correct PTY sizing)
tmux new-window -t "${SESSION}" -n "yazi" -c "${WORK_DIR}" yazi

# Focus on zk window
tmux select-window -t "${SESSION}:zk"
