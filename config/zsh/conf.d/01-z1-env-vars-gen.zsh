#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Environment and envvars
# ------------------------------------------------------------------------------

# Set common variables if they have not already been set.
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}
export PAGER=${PAGER:-less}
export BROWSER=${BROWSER:-firefox}

# Encodings, languges and misc settings
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL='C';

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
export LESS="${LESS:--g -i -M -R -S -w -z-4}"

# Reduce key delay
export KEYTIMEOUT=1

# Make Apple Terminal behave.
if [[ "$OSTYPE" == darwin* ]]; then
  export SHELL_SESSIONS_DISABLE=${SHELL_SESSIONS_DISABLE:-1}
fi

# Homebrew
if [[ "$OSTYPE" == darwin* ]] && (( $+commands[brew] )); then
  if [[ "${commands[brew]}" == "/opt/homebrew/bin/brew" ]]; then
    HOMEBREW_PREFIX=/opt/homebrew
  else
    HOMEBREW_PREFIX=/usr/local
  fi
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar";
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX";
  export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}";
  export HELPDIR="${MANPATH}"
fi

# Set $PATH.

# Ensure path arrays do not contain duplicates.
typeset -gU path

# TODO: add pyenv, conda, and python path below
path=(
  # Rust CLI Utils
  $CARGO_HOME/bin(N)

  # Pyenv CLI utils
  $PYENV_ROOT/bin(N)
  $PYENV_ROOT/shims

  # core
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  $HOMEBREW_PREFIX/{,s}bin(N)

  # apps
  $HOMEBREW_PREFIX/opt/curl/bin(N)
  $HOMEBREW_PREFIX/opt/go/libexec/bin(N)
  $HOMEBREW_PREFIX/opt/ruby/bin(N)
  $HOMEBREW_PREFIX/share/npm/bin(N)
  $HOMEBREW_PREFIX/anaconda3/bin(N)

  # firefox
  # Adapted from: https://stackoverflow.com/a/62203162/4687531
  /Applications/Firefox.app/Contents/MacOS

  $path
)

# endregion --------------------------------------------------------------------
