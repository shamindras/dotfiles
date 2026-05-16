#!/usr/bin/env bash
# Shared helper functions for sesh startup scripts.
# Source this file — do not execute directly.

# Standard set of extra yazi tabs every session opens to the right of the
# session WORK_DIR. Order is preserved as the on-screen tab order.
# shellcheck disable=SC2034
SESH_BOOKS_TABS=(
  "${DROPBOX_DIR:-$HOME/Dropbox}/resources/books/reference_books"
  "${DROPBOX_DIR:-$HOME/Dropbox}/resources/books/current_reading/books/00_now_reading"
  "${DROPBOX_DIR:-$HOME/Dropbox}/resources/books/current_reading/books/01_next_up"
)

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

# Window: yazi (direct command for correct PTY sizing)
sesh_window_yazi() {
  local session="$1" work_dir="$2"
  tmux new-window -a -t "${session}:\$" -n "yazi" -c "${work_dir}" yazi
}

# Window: yazi with preloaded tabs.
#   $1  session name
#   $2  work_dir (becomes tab 0)
#   $3  0-based index of the tab to activate after launch
#   $4+ additional tab paths (in order, appended after tab 0)
# Extra tabs are passed to yazi via YAZI_STARTUP_TABS / YAZI_ACTIVE_TAB
# env vars, consumed by ~/.config/yazi/init.lua. Paths must not contain ':'.
sesh_window_yazi_tabs() {
  local session="$1" work_dir="$2" active_idx="$3"
  shift 3
  local IFS=':'
  local extra_tabs="$*"
  tmux new-window -a -t "${session}:\$" -n "yazi" -c "${work_dir}" \
    "env YAZI_STARTUP_TABS='${extra_tabs}' YAZI_ACTIVE_TAB='${active_idx}' yazi"
}

# Focus a named window
sesh_focus_window() {
  local session="$1" window_name="$2"
  tmux select-window -t "${session}:${window_name}"
}
