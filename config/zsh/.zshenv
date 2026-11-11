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

# Tool state/config relocation vars. These live here — NOT conf.d/ — because
# conf.d is sourced by .zshrc (interactive only) and these must reach ALL zsh
# invocations (zsh -c, scripts). SHELL_SESSIONS_DISABLE additionally must be
# set before /etc/zshrc, which sources the Apple Terminal session script.
export SHELL_SESSIONS_DISABLE=1
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Profile values (REPOS_DIR, NOTES_DIR, ZK_NOTEBOOK_DIR) from the rendered
# generated/<profile>/env.zsh, which ./install links to this fixed path.
# Sourced here so every zsh (scripts, zsh -c, tmux) sees them.
if [[ -r "$XDG_CONFIG_HOME/dotfiles/env.zsh" ]]; then
  source "$XDG_CONFIG_HOME/dotfiles/env.zsh"
else
  # transitional: home defaults until ./install links dotfiles/env.zsh on this
  # Mac (the move to ~/repos, node N16). Remove once that link exists.
  export REPOS_DIR="$HOME/repos"
  [[ -d "$REPOS_DIR" ]] || REPOS_DIR="$HOME/Dropbox/repos" # transitional
  export NOTES_DIR="$HOME/Dropbox/notes" # transitional
  export ZK_NOTEBOOK_DIR="$NOTES_DIR/zk"
fi

# Ensure XDG directories exist.
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
  done
} XDG_{BIN,CONFIG,CACHE,DATA,STATE}_HOME XDG_{RUNTIME,PROJECTS}_DIR

# vim: ft=zsh
