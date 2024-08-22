#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Utility
# ------------------------------------------------------------------------------

() {
  # Use built-in paste magic.
  autoload -Uz bracketed-paste-url-magic
  zle -N bracketed-paste bracketed-paste-url-magic
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic

  # Load more specific 'run-help' function from $fpath.
  (( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
  alias help=run-help

  # Make ls more useful.
  if (( ! $+commands[dircolors] )) && [[ "$OSTYPE" != darwin* ]]; then
    # Group dirs first on non-BSD systems
    alias ls="${aliases[ls]:-ls} --group-directories-first"
  fi
  # Show human readable file sizes.
  alias ls="${aliases[ls]:-ls} -h"

  # Ensure python commands exist.
  if (( $+commands[python3] )) && ! (( $+commands[python] )); then
    alias python=python3
  fi
  if (( $+commands[pip3] )) && ! (( $+commands[pip] )); then
    alias pip=pip3
  fi

  # Ensure envsubst command exists.
  if ! (( $+commands[envsubst] )); then
    alias envsubst="python -c 'import os,sys;[sys.stdout.write(os.path.expandvars(l)) for l in sys.stdin]'"
  fi

  # Ensure hd (hex dump) command exists.
  if ! (( $+commands[hd] )) && (( $+commands[hexdump] )); then
    alias hd="hexdump -C"
  fi

  # Ensure open command exists.
  if ! (( $+commands[open] )); then
    if [[ "$OSTYPE" == cygwin* ]]; then
      alias open='cygstart'
    elif [[ "$OSTYPE" == linux-android ]]; then
      alias open='termux-open'
    elif (( $+commands[xdg-open] )); then
      alias open='xdg-open'
    fi
  fi

  # Ensure pbcopy/pbpaste commands exist.
  if ! (( $+commands[pbcopy] )); then
    if [[ "$OSTYPE" == cygwin* ]]; then
      alias pbcopy='tee > /dev/clipboard'
      alias pbpaste='cat /dev/clipboard'
    elif [[ "$OSTYPE" == linux-android ]]; then
      alias pbcopy='termux-clipboard-set'
      alias pbpaste='termux-clipboard-get'
    elif (( $+commands[wl-copy] && $+commands[wl-paste] )); then
      alias pbcopy='wl-copy'
      alias pbpaste='wl-paste'
    elif [[ -n $DISPLAY ]]; then
      if (( $+commands[xclip] )); then
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
      elif (( $+commands[xsel] )); then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
      fi
    fi
  fi

  # Cross platform `sed -i` syntax.
  function sedi {
    # GNU/BSD
    sed --version &>/dev/null && sed -i -- "$@" || sed -i "" "$@"
  }
}

# endregion --------------------------------------------------------------------