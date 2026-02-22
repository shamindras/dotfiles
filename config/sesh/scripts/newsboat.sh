#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="newsboat"

# Window 1: newsboat
tmux rename-window -t "${SESSION}:1" "newsboat"
tmux send-keys -t "${SESSION}:newsboat" "newsboat" Enter
