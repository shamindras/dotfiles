#!/bin/zsh
# Define Zsh environment variables.
# source: https://github.com/mattmc3/zshrc1/blob/main/.zshrc

# Even with `$ZDOTDIR` set ~/.zshenv needs to remain.
# But, you can symlink it to this file
# ln -s ~/.config/zsh/.zshenv ~/.zshenv
export ZDOTDIR=${ZDOTDIR:-~/.config/zsh}

# ------------------------------------------------------------------------------
# region: Setup zshrc1 
# ------------------------------------------------------------------------------

typeset -g ZSHRC1="${(%):-%N}}"
typeset -g ZSHRC1_VERSION="2.0.0"

# Define core environment vars.
export __zsh_config_dir=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
export __zsh_user_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
export __zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
mkdir -p $__zsh_config_dir $__zsh_user_data_dir $__zsh_cache_dir

# Users can customize with zstyles if they want.
[[ ! -r $__zsh_config_dir/.zstyles ]] || source $__zsh_config_dir/.zstyles

# There's not really a post_zshrc event, so we're going to fake one by adding a
# function called run_post_zshrc to the precmd event. That function only runs once,
# and then unregisters itself. If the user wants to (or needs to because it doesn't
# play well with a plugin), they can run it themselves manually at the very end of
# their .zshrc, and then it unregisters the precmd event.

# Define a variable to hold actions run during the post_zshrc event.
typeset -ga post_zshrc_hook

# Add our new event.
function run_post_zshrc {
  # Run anything attached to the post_zshrc hook
  local fn
  for fn in $post_zshrc_hook; do
    # Uncomment to debug:
    # echo "post_zshrc is about to run: ${=fn}"
    "${=fn}"
  done

  # Now delete the precmd hook and self-remove this function and its list var so
  # that it only runs once, and doesn't keep running on every future precmd event.
  add-zsh-hook -d precmd run_post_zshrc
  unfunction -- run_post_zshrc
  unset -- post_zshrc_hook
}

# Attach run_post_zshrc to built-in precmd.
autoload -U add-zsh-hook
add-zsh-hook precmd run_post_zshrc

# endregion --------------------------------------------------------------------

# ------------------------------------------------------------------------------
# region: conf.d
# ------------------------------------------------------------------------------

function run_confd {
  # Which conf.d directory to use? Use glob_subst to support '~'.
  : ${__zsh_config_dir:=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}
  local confd
  zstyle -s ':zephyr:plugin:confd' directory 'confd' || confd=$__zsh_config_dir/conf.d
  confd=${~confd}

  # Source all scripts in conf.d.
  local zrcfile
  for zrcfile in $confd/*.{z,}sh(N); do
    # ignore files that begin with ~
    [[ "${zrcfile:t}" == '~'* ]] && continue
    source "$zrcfile"
  done
}
post_zshrc_hook+=(run_confd)

# endregion --------------------------------------------------------------------