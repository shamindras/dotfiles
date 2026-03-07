#!/usr/bin/env bash
set -Eeuo pipefail

SESSION="notes"
WORK_DIR="${DROPBOX_DIR:-$HOME/DROPBOX}/notes/zk"
IDEAS_DIR="${WORK_DIR}/ideas"

# shellcheck source=helpers.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

sesh_window_claude "${SESSION}" "${WORK_DIR}"   # Window 1

# Window 2: journal (defer send-keys until all windows exist)
tmux new-window -a -t "${SESSION}:\$" -n "journal" -c "${WORK_DIR}"

# Window 3: ideas (nvim with file picker in ideas dir)
tmux new-window -a -t "${SESSION}:\$" -n "ideas" -c "${IDEAS_DIR}"
tmux send-keys -l -t "${SESSION}:ideas" \
  "nvim +'autocmd User VeryLazy ++once lua require(\"shamindras.plugins.snacks.pickers\").picker_with_fd(Snacks.picker.files)'"
tmux send-keys -t "${SESSION}:ideas" Enter
sesh_window_term   "${SESSION}" "${WORK_DIR}"   # Window 4
sesh_window_yazi   "${SESSION}" "${WORK_DIR}"   # Window 5

# Now send journal startup command.
# Uses explicit binaries instead of the `kds` zsh alias so the command
# works even if the pane's shell hasn't finished loading .zshrc (cold-start
# race when `sesh connect notes` is run from a fresh terminal with no tmux server).
tmux send-keys -l -t "${SESSION}:journal" \
  "cd '${WORK_DIR}' && rsync -au --delete ~/.config/zk/templates/ '${WORK_DIR}/.zk/templates/' 2>/dev/null; zk daily"
tmux send-keys -t "${SESSION}:journal" Enter

sesh_focus_window "${SESSION}" "journal"
