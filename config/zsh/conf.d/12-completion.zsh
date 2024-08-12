#!/bin/zsh

# ------------------------------------------------------------------------------
# region: completion
# ------------------------------------------------------------------------------

# Let's talk compinit... compinit works by finding _completion files in your fpath. That
# means fpath needs to be fully populated prior to calling it. But sometimes you need to
# call compdef before fpath is done being populated to define a completion (eg: plugins
# do this). compinit has big chicken-and-egg problems. This code handles all those
# completion use cases by wrapping compinit, queueing calls to compdef, and hooking the
# real call to compinit to run post_zshrc.

# Define compinit placeholder functions (compdef) so we can queue up calls.
# That way when the real compinit is called, we can execute the queue.
typeset -gHa __zshrc1_compdef_queue=()
function compdef {
  (( $# )) || return
  local compdef_args=("${@[@]}")
  __zshrc1_compdef_queue+=("$(typeset -p compdef_args)")
}

# Wrap compinit temporarily so that when the real compinit call happens, the
# queue of compdef calls is processed.
function compinit {
  unfunction compinit compdef &>/dev/null
  autoload -Uz compinit && compinit "$@"

  # Apply all the queued compdefs.
  local typedef_compdef_args
  for typedef_compdef_args in $__zshrc1_compdef_queue; do
    eval $typedef_compdef_args
    compdef "$compdef_args[@]"
  done
  unset __zshrc1_compdef_queue

  # We can run compinit early, and if we did we no longer need a post_zshrc hook.
  post_zshrc_hook=(${post_zshrc_hook:#run_compinit})
}

function run_compinit {
  # Initialize the built-in Zsh completion system.
  if [[ -z "$ZSH_COMPDUMP" ]]; then
    local ZSH_COMPDUMP
    if zstyle -T ':zephyr:plugin:completion' use-xdg-basedirs; then
      : ${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}
      ZSH_COMPDUMP=$__zsh_cache_dir/compdump
    else
      ZSH_COMPDUMP=$HOME/.zcompdump
    fi
  fi

  # Load and initialize the completion system ignoring insecure directories with a
  # cache time of 20 hours, so it should almost always regenerate the first time a
  # shell is opened each day.
  autoload -Uz compinit
  local comp_files=($ZSH_COMPDUMP(Nmh-20))
  if (( $#comp_files )); then
    compinit -i -C -d "$ZSH_COMPDUMP"
  else
    compinit -i -d "$ZSH_COMPDUMP"
    # Ensure $ZSH_COMPDUMP is younger than the cache time even if it isn't regenerated.
    touch "$ZSH_COMPDUMP"
  fi

  # Compile zcompdump, if modified, in background to increase startup speed.
  {
    if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
      if command mkdir "${ZSH_COMPDUMP}.zwc.lock" 2>/dev/null; then
        zcompile "$ZSH_COMPDUMP"
        command rmdir  "${ZSH_COMPDUMP}.zwc.lock" 2>/dev/null
      fi
    fi
  } &!
}
post_zshrc_hook+=(run_compinit)

() {
  # Set Zsh completion options (16.2.2: https://zsh.sourceforge.io/Doc/Release/Options.html).
  setopt always_to_end           # Move cursor to the end of a completed word.
  setopt auto_list               # Automatically list choices on ambiguous completion.
  setopt auto_menu               # Show completion menu on a successive tab press.
  setopt auto_param_slash        # If completed parameter is a directory, add a trailing slash.
  setopt complete_in_word        # Complete from both ends of a word.
  setopt path_dirs               # Perform path search even on command names with slashes.
  setopt NO_flow_control         # Disable start/stop characters in shell editor.
  setopt NO_menu_complete        # Do not autoselect the first completion entry.

  # Add completions for keg-only brews when available.
  local brew_prefix
  if (( $+commands[brew] )); then
    brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-$commands[brew]:A:h:h}}
    # $HOMEBREW_PREFIX defaults to $HOMEBREW_REPOSITORY but is explicitly set to
    # /usr/local when $HOMEBREW_REPOSITORY is /usr/local/Homebrew.
    # https://github.com/Homebrew/brew/blob/2a850e02d8f2dedcad7164c2f4b95d340a7200bb/bin/brew#L66-L69
    [[ $brew_prefix == '/usr/local/Homebrew' ]] && brew_prefix=$brew_prefix:h

    # Add brew locations to fpath
    fpath=(
      $brew_prefix/opt/curl/share/zsh/site-functions(/N)  # Add curl completions.
      $brew_prefix/share/zsh/site-functions(-/FN)  # Add zsh completions.
      $fpath
    )
  fi

  # Add Fish-like custom completions directory.
  fpath=($__zsh_config_dir/completions(/N) $fpath)
}

() {
  local compstyle
  zstyle -s ':zephyr:plugin:completion' compstyle 'compstyle' || compstyle=zephyr
  (( $+functions[compstyle_${compstyle}_setup] )) && compstyle_${compstyle}_setup
}

#
#endregion
#region Plugins
#

() {
  [[ -r "${ZSHRC1:A:h}/lib/unplugged.zsh" ]] || return 1
  source ${ZSHRC1:A:h}/lib/unplugged.zsh

  local -a clone_plugins path_plugins fpath_plugins zsh_plugins
  zstyle -a ':zephyr:zsh-plugins:kind:clone' load 'clone_plugins'
  zstyle -a ':zephyr:zsh-plugins:kind:path'  load 'path_plugins'
  zstyle -a ':zephyr:zsh-plugins:kind:fpath' load 'fpath_plugins'
  zstyle -a ':zephyr:zsh-plugins:kind:zsh'   load 'zsh_plugins'

  clone_plugins=($clone_plugins $path_plugins $fpath_plugins $zsh_plugins)
  [[ "${#clone_plugins}" -gt 0 ]] || return
  plugin clone $clone_plugins
  plugin load --kind path $path_plugins
  plugin load --kind fpath $fpath_plugins
  plugin load $zsh_plugins
}

# endregion --------------------------------------------------------------------