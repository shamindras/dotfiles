#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Environment and envvars
# ------------------------------------------------------------------------------

# Set common variables if they have not already been set.
export EDITOR=${EDITOR:-vim}
export VISUAL=${VISUAL:-vim}
export PAGER=${PAGER:-less}
[[ "$OSTYPE" == darwin* ]] && export BROWSER=${BROWSER:-open}
export LANG=${LANG:-en_US.UTF-8}

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
export LESS="${LESS:--g -i -M -R -S -w -z-4}"

# Reduce key delay
export KEYTIMEOUT=${KEYTIMEOUT:-1}

# Make Apple Terminal behave.
if [[ "$OSTYPE" == darwin* ]]; then
  export SHELL_SESSIONS_DISABLE=${SHELL_SESSIONS_DISABLE:-1}
fi

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Add /usr/local/bin to path.
path=(/usr/local/{,s}bin(N) $path)

# Set the list of directories that Zsh searches for programs.
typeset -gaU prepath
if [[ "${#prepath}" -eq 0 ]]; then
  zstyle -s ':zephyr:plugin:environment' 'prepath' 'prepath' \
  || prepath=(
      $HOME/{,s}bin(N)
      $HOME/.local/{,s}bin(N)
    )
fi

# If path gets prepended and is now out of order, do `path=($prepath $path)`.
path=($prepath $path)

#
#endregion
#region homebrew

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