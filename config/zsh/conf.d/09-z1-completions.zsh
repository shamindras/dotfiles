#!/bin/zsh

# ------------------------------------------------------------------------------
# region: z1_completions: Setup Zsh completion system
# ------------------------------------------------------------------------------

function z1_completions {
  # Set options related to the completions.
  setopt always_to_end     # Move cursor to the end of a completed word.
  setopt auto_list         # Automatically list choices on ambiguous completion.
  setopt auto_menu         # Show completion menu on a successive tab press.
  setopt auto_param_slash  # If completed param is a directory, add trailing slash.
  setopt complete_in_word  # Complete from both ends of a word.
  setopt path_dirs         # Perform path search even on command names with slashes.
  setopt NO_flow_control   # Disable start/stop characters in shell editor.
  setopt NO_menu_complete  # Do not autoselect the first completion entry.

  # Add custom completions directory.
  local compdir
  zstyle -s ':z1:completions' dir 'compdir' || compdir=$__zsh_config_dir/completions
  fpath=($compdir(/N) $fpath)

  # Set completion zstyles.
  local compstyle
  zstyle -s ':z1:completion' compstyle 'compstyle' || compstyle=z1
  (( $+functions[compstyle_${compstyle}_setup] )) && compstyle_${compstyle}_setup

  # Initialize completions if the user didn't.
  (( $+functions[compinit] )) || run_compinit
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh 