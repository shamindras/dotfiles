#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="notes"
WORK_DIR="${DROPBOX_DIR:-$HOME/Dropbox}/notes/zk"
IDEAS_DIR="${WORK_DIR}/ideas"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

# Window 1: journal (rename default window, defer send-keys until all windows exist)
tmux rename-window -t "${SESSION}:1" "journal"

# Window 2: yazi with preloaded tabs (Downloads active)
sesh_window_yazi_tabs "${SESSION}" "${WORK_DIR}" downloads

# Window 3: claude resuming the most recent ~/Downloads session (booklib/bibtex).
# Falls back to a fresh session when there is no history to continue
# (e.g. new machine with no ~/Downloads .claude history).
sesh_window_claude_new "${SESSION}" "${HOME}/Downloads" "cl-dl-recent" "claude --continue || claude"

# Window 4: claude in the zk notes dir
sesh_window_claude_new "${SESSION}" "${WORK_DIR}" "cl-zk-notes"

# Window 5: ideas (nvim with file picker in ideas dir)
tmux new-window -a -t "${SESSION}:\$" -n "ideas" -c "${IDEAS_DIR}"
tmux send-keys -l -t "${SESSION}:ideas" \
  "nvim +'autocmd User VeryLazy ++once lua require(\"shamindras.plugins.snacks.pickers\").picker_with_fd(Snacks.picker.files)';clear"
tmux send-keys -t "${SESSION}:ideas" Enter

sesh_window_term       "${SESSION}" "${WORK_DIR}"   # Window 6

# Now send journal startup command.
# Uses explicit binaries instead of the `kds` zsh alias so the command
# works even if the pane's shell hasn't finished loading .zshrc (cold-start
# race when `sesh connect notes` is run from a fresh terminal with no tmux server).
tmux send-keys -l -t "${SESSION}:journal" \
  "cd '${WORK_DIR}' && rsync -au --delete ~/.config/zk/templates/ '${WORK_DIR}/.zk/templates/' 2>/dev/null; zk daily;clear"
tmux send-keys -t "${SESSION}:journal" Enter

sesh_focus_window "${SESSION}" "journal"
