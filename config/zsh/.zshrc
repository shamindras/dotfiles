#!/bin/zsh

# clear the "Last login" message for new tabs in terminal --------
# source: https://stackoverflow.com/a/69915614/4687531
printf '\33c\e[3J'

# Based on the .zshrc1 config
# source: https://github.com/mattmc3/zshrc1

# ------------------------------------------------------------------------------
# region: Basic XDG variable setup
# source: https://github.com/mattmc3/zdotdir/blob/main/.zshenv
# ------------------------------------------------------------------------------

# XDG path specifications
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$HOME/.xdg}
export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}

# Ensure XDG directories exist.
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
  done
} XDG_{CONFIG,CACHE,DATA,STATE}_HOME XDG_{RUNTIME,PROJECTS}_DIR

# endregion --------------------------------------------------------------------

# ------------------------------------------------------------------------------
# region: Init z1
# ------------------------------------------------------------------------------
 
() {
  typeset -g Z1_VERSION="0.0.1"
  typeset -gaH __z1_opts=(extended_glob NO_monitor NO_xtrace NO_ksh_arrays)

  # Add variables for key Zsh directories.
  export __zsh_config_dir=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
  export __zsh_user_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
  export __zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh

  # Ensure Zsh directories exist.
  local zdir
  for zdir in __zsh_{config,user_data,cache}_dir; do
    [[ -d "${(P)zdir}" ]] || mkdir -p ${(P)zdir}
  done

  # Define Z1 paths
  typeset -g Z1_{COMPLETIONS,CONFIGS,FUNCTION,REPO}_DIR
  typeset -g Z1_{COMPSTYLE,THEME}

  # Directory for Zsh autoload functions.
  zstyle -s ':z1:functions' dir 'Z1_FUNCTION_DIR' \
    || Z1_FUNCTION_DIR=${Z1_FUNCTION_DIR:-$__zsh_config_dir/functions}

  # Directory for cloned Zsh plugin repos.
  zstyle -s ':z1:repos' dir 'Z1_REPO_DIR' \
    || Z1_REPO_DIR=${Z1_REPO_DIR:-$__zsh_cache_dir/repos}

  # Customize with zstyles.
  [[ ! -r $__zsh_config_dir/.zstyles ]] || source $__zsh_config_dir/.zstyles
}

# endregion --------------------------------------------------------------------

# ------------------------------------------------------------------------------
# region: z1_confd: Source Zsh config files in a conf.d directory
# ------------------------------------------------------------------------------
 
function z1_confd {
  local confd zfile
  zstyle -s ':z1:configs' dir 'confd' || confd=$__zsh_config_dir/conf.d
  for zfile in $confd/*.zsh(N); do
    [[ ${zfile:t} != '~'* ]] || continue
    source $zfile
  done
}

# endregion --------------------------------------------------------------------

# ------------------------------------------------------------------------------
# region: Run z1
# ------------------------------------------------------------------------------

() {
  # source all conf.d files first, so that the `z1_` funcs below are loaded
  z1_confd 

  # conf.d functions
  z1_funcdir
  z1_colorize
  z1_directory
  z1_editor
  z1_history
  z1_utility
  z1_plugins
  z1_completions
  z1_brew_app_starship
  z1_brew_app_zoxide
  z1_brew_app_fzf
  z1_aliases
  z1_suffix_aliases
}

# vim: ft=zsh 
