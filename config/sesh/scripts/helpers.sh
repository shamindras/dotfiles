#!/usr/bin/env bash
# Shared helper functions for sesh startup scripts.
# Source this file — do not execute directly.

# Window: nvim with Snacks file picker (renames window 1)
sesh_window_nvim() {
  local session="$1" work_dir="$2"
  tmux rename-window -t "${session}:1" "nvim"
  tmux send-keys -l -t "${session}:nvim" \
    "nvim +'autocmd User VeryLazy ++once lua require(\"shamindras.plugins.snacks.pickers\").picker_with_fd(Snacks.picker.files)'"
  tmux send-keys -t "${session}:nvim" Enter
}

# Window: claude (single pane)
sesh_window_claude() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "claude" -c "${work_dir}"
  tmux send-keys -t "${session}:claude" "claude" Enter
}

# Window: plain terminal
sesh_window_term() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "term" -c "${work_dir}"
}

# Window: yazi (direct command for correct PTY sizing)
sesh_window_yazi() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "yazi" -c "${work_dir}" yazi
}

# Focus a named window
sesh_focus_window() {
  local session="$1" window_name="$2"
  tmux select-window -t "${session}:${window_name}"
}
