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
    "nvim +'autocmd User VeryLazy ++once lua require(\"shamindras.plugins.snacks.pickers\").picker_with_fd(Snacks.picker.files)';clear"
  tmux send-keys -t "${session}:nvim" Enter
}

# Window: plain terminal
sesh_window_term() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "term" -c "${work_dir}"
}

# Window: yazi with preloaded tabs (persistent — yazi runs inside the
# window's shell via the autoloaded `yt` function, so quitting yazi drops
# to the prompt instead of closing the window; relaunch with `yt`).
#   $1  session name
#   $2  work_dir (becomes tab 1 — the window's shell starts there)
#   $3+ extra args for yt (e.g. active tab name, --profile books)
# -W skips yt's interactive wash (sesh windows have never washed).
# Tab data and resolution live in ~/.config/bin/yazi-tabs (single source
# of truth). Run `yazi-tabs --help` for the interface.
sesh_window_yazi_tabs() {
  local session="$1" work_dir="$2"
  shift 2
  tmux new-window -a -t "${session}:\$" -n "yazi" -c "${work_dir}"
  tmux send-keys -t "${session}:yazi" "yt -W $*" Enter
}

# Focus a named window
sesh_focus_window() {
  local session="$1" window_name="$2"
  tmux select-window -t "${session}:${window_name}"
}
