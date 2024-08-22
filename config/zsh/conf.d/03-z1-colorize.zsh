#!/bin/zsh

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

() {
  # Where is brew?
  # Setup homebrew if it exists on the system.
  typeset -aU _brewcmd=(
    $commands[brew]
    $HOME/.homebrew/bin/brew(N)
    $HOME/.linuxbrew/bin/brew(N)
    /opt/homebrew/bin/brew(N)
    /usr/local/bin/brew(N)
    #/home/linuxbrew/.linuxbrew/bin/brew(N)
  )
  (( ${#_brewcmd} )) || return 1

  # brew shellenv
  if zstyle -t ':zephyr:plugin:homebrew' 'use-cache'; then
    cached-eval 'brew_shellenv' $_brewcmd[1] shellenv
  else
    source <($_brewcmd[1] shellenv)
  fi
  unset _brewcmd

  # Ensure user bins preceed homebrew in path.
  path=($prepath $path)

  # Default to no tracking.
  HOMEBREW_NO_ANALYTICS=${HOMEBREW_NO_ANALYTICS:-1}

  # Add brewed Zsh to fpath
  if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
    fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
  fi

  # Add keg-only completions to fpath
  zstyle -a ':zephyr:plugin:homebrew' 'keg-only-brews' '_kegonly' \
    || _kegonly=(curl ruby sqlite)
  for _keg in $_kegonly; do
    fpath=($HOMEBREW_PREFIX/opt/${_keg}/share/zsh/site-functions(/N) $fpath)
  done
  unset _keg{,only}

  # Set aliases.
  if ! zstyle -t ':zephyr:plugin:homebrew:alias' skip; then
    alias brewup="brew update && brew upgrade && brew cleanup"
    alias brewinfo="brew leaves | xargs brew desc --eval-all"
    alias brewdeps='brew leaves | xargs brew deps --installed --for-each | awk ''{leaf=$1;$1=""; printf "%s\033[34m%s\033[0m\n",leaf,$0}'''

    # Handle brew on multi-user systems.
    _brew_owner="$(stat -f "%Su" "$HOMEBREW_PREFIX" 2>/dev/null)"
    if [[ -n "$_brew_owner" ]] && [[ "$(whoami)" != "$_brew_owner" ]]; then
      alias brew="sudo -Hu '$_brew_owner' brew"
    fi
    unset _brew_owner
  fi
}

# endregion --------------------------------------------------------------------