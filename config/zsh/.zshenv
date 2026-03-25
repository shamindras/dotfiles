# Tiny trampoline: sets ZDOTDIR so zsh finds config in ~/.config/zsh/.
# No `export` — ZDOTDIR is zsh-internal, not needed by child processes.
# source: https://www.reddit.com/r/zsh/comments/qtehjs/comment/hkkpzyi/
ZDOTDIR=~/.config/zsh

# XDG path specifications.
# Set here (not .zshrc) so they're available to ALL zsh invocations
# (scripts, cron, zsh -c), not just interactive shells.
export XDG_BIN_HOME=$HOME/.local/bin
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export XDG_RUNTIME_DIR=$HOME/.xdg
export XDG_PROJECTS_DIR=$HOME/Projects

# Ensure XDG directories exist.
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
  done
} XDG_{BIN,CONFIG,CACHE,DATA,STATE}_HOME XDG_{RUNTIME,PROJECTS}_DIR

# vim: ft=zsh
