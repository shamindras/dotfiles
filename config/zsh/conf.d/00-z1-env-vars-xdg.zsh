# ------------------------------------------------------------------------------
# region: Set apps to use XDG basedir spec.
# XDG basedir support outlined here:
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
# ------------------------------------------------------------------------------

# bat
# source: https://github.com/sharkdp/bat#configuration-file
export BAT_CONFIG_PATH="$XDG_CONFIG_HOME/bat/config"

# bat-extras
# Use `delta` as the default pager for `batdiff`
# source: https://github.com/eth-p/bat-extras/blob/master/doc/batdiff.md#environment
export BATDIFF_USE_DELTA=true

# Cache
export CCACHE_DIR="$XDG_CACHE_HOME/ccache"

# Dropbox
export DROPBOX_DIR="$HOME/Dropbox"
export DROPBOX_REPOS_DIR="$DROPBOX_DIR/repos"
export DROPBOX_RESOURCES_DIR="$DROPBOX_DIR/resources"
export DROPBOX_BOOKS_DIR="$DROPBOX_RESOURCES_DIR/books"
export DROPBOX_NOTES_DIR="$DROPBOX_DIR/notes"

# less
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# GNU parallel
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

# Python
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export PYTHONIOENCODING='UTF-8'
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"

# starship
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export STARSHIP_CACHE="$XDG_CACHE_HOME/starship/cache"

# Tealdeer
# source: https://dbrgn.github.io/tealdeer/config.html#override-config-directory
export TEALDEER_CONFIG_DIR="$XDG_CONFIG_HOME/tealdeer"

# Terminfo
export TERMINFO="$XDG_DATA_HOME/terminfo"
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"

# Zoxide
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"
export _ZO_ECHO=0
export _ZO_MAXAGE=10000

# gpg
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# gh
# source: https://cli.github.com/manual/gh_help_environment
export GH_CONFIG_DIR="$XDG_CONFIG_HOME/gh"

# gh-dash
# source: https://dlvhdr.github.io/gh-dash/configuration/
export GH_DASH_CONFIG="$XDG_CONFIG_HOME/gh-dash/config.yml"

# Node
# source: https://blog.mitsunee.com/post/n-xdg-setup
export NVM_DIR="$XDG_DATA_HOME/nvm"
export N_PREFIX="$XDG_DATA_HOME/node"
export N_CACHE_PREFIX="$XDG_CACHE_HOME"
export N_PRESERVE_NPM=1
export N_PRESERVE_COREPACK=1
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export COREPACK_HOME="$XDG_CACHE_HOME/node/corepack"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl/history"

# readline
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# ripgrep
# source: https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

# tmux
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME/tmux/plugins"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# curl
export CURL_HOME="$XDG_CONFIG_HOME/curl"

# zk - https://zk-org.github.io/zk/
export ZK_NOTEBOOK_DIR="$DROPBOX_NOTES_DIR/zk"

# endregion --------------------------------------------------------------------

# vim: ft=zsh
