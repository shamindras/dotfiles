#!/usr/env/bin zsh

# ------------------------------------------------------------------------------
# region: z1_colorize: Add color to your terminal
# ------------------------------------------------------------------------------

function z1_colorize {
  # Built-in zsh colors
  autoload -Uz colors && colors

  # colormap: Print a quick colormap.
  function colormap {
    for i in {0..255}; do
      print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
    done
  }

  # Show man pages in color.
  export LESS_TERMCAP_mb=$'\e[01;34m'      # mb:=start blink-mode (bold,blue)
  export LESS_TERMCAP_md=$'\e[01;34m'      # md:=start bold-mode (bold,blue)
  export LESS_TERMCAP_so=$'\e[00;47;30m'   # so:=start standout-mode (white bg, black fg)
  export LESS_TERMCAP_us=$'\e[04;35m'      # us:=start underline-mode (underline magenta)
  export LESS_TERMCAP_se=$'\e[0m'          # se:=end standout-mode
  export LESS_TERMCAP_ue=$'\e[0m'          # ue:=end underline-mode
  export LESS_TERMCAP_me=$'\e[0m'          # me:=end modes

  # __memoize_cmd: Evaluate a command, cache its output, and use its cache for 20 hours.
  function __memoize_cmd {
    emulate -L zsh; setopt local_options $__z1_opts
    local memofile=$__zsh_cache_dir/memoized/$1; shift
    local -a cached=($memofile(Nmh-20))
    if ! (( $#cached )); then
      mkdir -p ${memofile:h}
      "$@" >| $memofile
    fi
    source $memofile
  }

  # Set colors for grep and ls command using dircolors if available.
  alias grep="${aliases[grep]:-grep} --color=auto"
  if (( $+commands[gdircolors] )); then
    __memoize_cmd 'gdircolors.zsh' gdircolors --sh
    alias gls="${aliases[gls]:-gls} --group-directories-first --color=auto"
  fi
  if (( $+commands[dircolors] )); then
    __memoize_cmd 'dircolors.zsh' dircolors --sh
    alias ls="${aliases[ls]:-ls} --group-directories-first --color=auto"
  else
    alias ls="${aliases[ls]:-ls} -G"
    export LSCOLORS=${LSCOLORS:-exfxcxdxbxGxDxabagacad}
  fi
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh 