#!/usr/bin/env bash
# Shared helper functions for sesh startup scripts.
# Source this file — do not execute directly.

# Window: items (renames window 1 — taskwarrior-tui with clear on exit)
sesh_window_items() {
  local session="$1" work_dir="$2"
  tmux rename-window -t "${session}:1" "items"
  tmux send-keys -t "${session}:items" "taskwarrior-tui;clear" Enter
}

# Window: claude (renames window 1 — inherits cwd from sesh.toml path)
sesh_window_claude() {
  local session="$1" work_dir="$2"
  tmux rename-window -t "${session}:1" "claude"
  tmux send-keys -t "${session}:claude" "clear && claude" Enter
}

# Window: claude (new window — use when another window owns W1)
sesh_window_claude_new() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "claude" -c "${work_dir}"
  tmux send-keys -t "${session}:claude" "clear && claude" Enter
}

# Window: nvim with Snacks file picker (creates new window)
sesh_window_nvim() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "nvim" -c "${work_dir}"
  tmux send-keys -l -t "${session}:nvim" \
    "nvim +'autocmd User VeryLazy ++once lua require(\"shamindras.plugins.snacks.pickers\").picker_with_fd(Snacks.picker.files)'"
  tmux send-keys -t "${session}:nvim" Enter
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
