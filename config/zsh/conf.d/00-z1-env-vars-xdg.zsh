#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Set apps to use XDG basedir spec.
# XDG basedir support outlined here:
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
# ------------------------------------------------------------------------------

# TODO Modify commented variables below, and uncomment them after utils set up.

# bat
# source: https://github.com/sharkdp/bat/tree/ac734db4213ef4b82c0513e39726627936ebe3f0#configuration-file
export BAT_CONFIG_PATH="${BAT_CONFIG_PATH:-$XDG_CONFIG_HOME/bat/config}"
# export BAT_PAGER="less -RF"

# bat-extras
# Use `delta` as the default pager for `batdiff`
# source: https://github.com/eth-p/bat-extras/blob/master/doc/batdiff.md#environment
BATDIFF_USE_DELTA=true

# Cache
export CCACHE_DIR="${CCACHE_DIR:-$XDG_CACHE_HOME/ccache}"

# Conda
# TODO: check this references a file, not a dir
# export CONDARC="${CONDARC:-$XDG_CONFIG_HOME/conda/condarc}"

# Julia
# export JULIA_NUM_THREADS=16
# export JULIA_DEPOT_PATH="${JULIA_DEPOT_PATH:-$XDG_DATA_HOME/julia}"

# jupyter
# export JUPYTER_CONFIG_DIR="${JUPYTER_CONFIG_DIR:-$XDG_CONFIG_HOME/jupyter}"

# less
# export LESSHISTFILE="-" # Disable less history.
export LESSKEY="${LESSKEY:-$XDG_CONFIG_HOME/less/lesskey}"
export LESSHISTFILE="${LESSHISTFILE:-$XDG_CACHE_HOME/less/history}"

# Python
# export PIP_CONFIG_FILE="${XDG_CONFIG_HOME}/pip/pip.conf"
# export PIP_LOG_FILE="${XDG_DATA_HOME}/pip/log"
export PYENV_ROOT="${PYENV_ROOT:-$XDG_DATA_HOME/pyenv}"
# export IPYTHONDIR="${IPYTHONDIR:-$XDG_CONFIG_HOME/ipython}"
export PYTHONIOENCODING='UTF-8';
# export PYLINTHOME="${PYLINTHOME:-$XDG_CACHE_HOME/pylint.d}"
# export PYTHONSTARTUP="${PYTHONSTARTUP:-$XDG_CONFIG_HOME/python/pythonrc}"
# export MPLCONFIGDIR="${MPLCONFIGDIR:-$XDG_DATA_HOME/matplotlib}"
export MYPY_CACHE_DIR="${MYPY_CACHE_DIR:-$XDG_CACHE_HOME/mypy_cache}"
# export PYGMENTIZE_STYLE='paraiso-dark'
# export PYTHONDONTWRITEBYTECODE=false # TODO: toggle if reviewing bytecode
# export PIPENV_IGNORE_VIRTUALENVS=-1 # always install to pyenv virtualenv
# export ZSH_PYENV_LAZY_VIRTUALENV=1 # used by `../plugins/python/zsh-pyenv-lazy-load.zsh`

# R
# export R_USER="${R_USER:-$XDG_CONFIG_HOME/R}"
# export R_ENVIRON_USER="${R_ENVIRON_USER:-$XDG_CONFIG_HOME/R/Renviron}"
# export R_PROFILE_USER="${R_PROFILE_USER:-$XDG_CONFIG_HOME/R/Rprofile}"
# export R_MAKEVARS_USER="${R_MAKEVARS_USER:-$XDG_CONFIG_HOME/R/Makevars}"
# export R_HISTFILE="${R_HISTFILE:-$XDG_DATA_HOME/Rhistory}"
# export R_LIBS_USER="${HOME}/Library/R/4.0/library"
# export R_HISTSIZE=100000
# export R_STARTUP_DEBUG=TRUE
# export MKL_NUM_THREADS=16
# export OMP_NUM_THREADS=16

# starship
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$XDG_CONFIG_HOME/starship/starship.toml}"
export STARSHIP_CACHE="${STARSHIP_CACHE:-$XDG_CACHE_HOME/starship/cache}"

# Tealdeer
# This must be hardcoded, and must be an absolute path.
# source: https://dbrgn.github.io/tealdeer/config.html#override-config-directory
export TEALDEER_CONFIG_DIR=~/.config/tealdeer

# Terminfo
export TERMINFO="${TERMINFO:-$XDG_DATA_HOME}"/terminfo
export TERMINFO_DIRS="${TERMINFO_DIRS:-$XDG_DATA_HOME}"/terminfo:/usr/share/terminfo

# Zoxide
export _ZO_DATA_DIR="${_ZO_DATA_DIR:-$XDG_DATA_HOME/zoxide}"
export _ZO_ECHO=0
export _ZO_MAXAGE=100

# gpg
export GNUPGHOME="${GNUPGHOME:-$XDG_DATA_HOME/gnupg}"

# gh
# source: https://cli.github.com/manual/gh_help_environment 
export GH_CONFIG_DIR="${GH_CONFIG_DIR:-$XDG_CONFIG_HOME/gh}"

# gh-dash
# source: https://dlvhdr.github.io/gh-dash/configuration/
export GH_DASH_CONFIG="${GH_DASH_CONFIG:-$XDG_CONFIG_HOME/gh-dash/config.yml}"

# Node
# source: https://blog.mitsunee.com/post/n-xdg-setup
export NVM_DIR="${NVM_DIR:-$XDG_DATA_HOME/nvm}"
# export N_PREFIX="${N_PREFIX:-$XDG_DATA_HOME/node}"
# export N_CACHE_PREFIX="${N_CACHE_PREFIX:-$XDG_CACHE_HOME}"
# export N_PRESERVE_NPM=1
# export N_PRESERVE_COREPACK=1
# export NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG:-$XDG_CONFIG_HOME/npm/npmrc}"
# export COREPACK_HOME="${COREPACK_HOME:-$XDG_DATA_HOME/corepack}"
# export NODE_REPL_HISTORY="${NODE_REPL_HISTORY:-$XDG_STATE_HOME/node_repl/history}"

# postgres
# export PSQLRC="${PSQLRC:-$XDG_CONFIG_HOME/pg/psqlrc}"
# export PSQL_HISTORY="${PSQL_HISTORY:-$XDG_CACHE_HOME/pg/psql_history}"
# export PGPASSFILE="${PGPASSFILE:-$XDG_CONFIG_HOME/pg/pgpass}"
# export PGSERVICEFILE="${PGSERVICEFILE:-$XDG_CONFIG_HOME/pg/pg_service.conf}"

# readline
export INPUTRC="${INPUTRC:-$XDG_CONFIG_HOME/readline/inputrc}"

# ruby bundler
export BUNDLE_USER_CONFIG="${BUNDLE_USER_CONFIG:-$XDG_CONFIG_HOME/bundle}"
export BUNDLE_USER_CACHE="${BUNDLE_USER_CACHE:-$XDG_CACHE_HOME/bundle}"
export BUNDLE_USER_PLUGIN="${BUNDLE_USER_PLUGIN:-$XDG_DATA_HOME/bundle}"

# ruby gems
export GEM_HOME="${GEM_HOME:-$XDG_DATA_HOME/gem}"
export GEM_SPEC_CACHE="${GEM_SPEC_CACHE:-$XDG_CACHE_HOME/gem}"

# rust
export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$XDG_DATA_HOME/rustup}"

# screen
export SCREENRC="${SCREENRC:-$XDG_CONFIG_HOME/screen/screenrc}"

# ripgrep
# source: https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-$XDG_CONFIG_HOME/ripgrep/ripgreprc}"

# tmux
# export TMUX_PLUGIN_MANAGER_PATH="${XDG_DATA_HOME}/tmux/plugins"
# export TMUX_CONFIG="${TMUX_CONFIG:-$XDG_CONFIG_HOME/tmux/tmux.conf}"
# [[ -f $TMUX_CONFIG ]] || { mkdir -p $TMUX_CONFIG:h && touch $TMUX_CONFIG }
# alias tmux='tmux -f "$TMUX_CONFIG"'

# wget
export WGETRC="${WGETRC:-$XDG_CONFIG_HOME/wget/wgetrc}"

## Respect XDG directories
# export CURL_HOME="${XDG_CONFIG_HOME}/curl"
# export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
# export GIT_CONFIG="${XDG_CONFIG_HOME}/git/.gitconfig"

# endregion --------------------------------------------------------------------