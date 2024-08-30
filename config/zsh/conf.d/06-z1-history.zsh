#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Set options, variables, and aliases for Zsh history
# ------------------------------------------------------------------------------

# z1_history: 
function z1_history {
  setopt bang_hist               # Treat the '!' character specially during expansion.
  setopt extended_history        # Write the history file in the ':start:elapsed;command' format.
  setopt hist_expire_dups_first  # Expire a duplicate event first when trimming history.
  setopt hist_find_no_dups       # When using find, only display a command once.
  setopt hist_ignore_dups        # Do not record an event that was just recorded again.
  setopt hist_ignore_space       # Do not record an event starting with a space.
  setopt hist_verify             # Do not execute immediately upon history expansion.
  setopt inc_append_history      # Write to the history file immediately, not when the shell exits.
  setopt NO_share_history        # Do not share history between all sessions.
  setopt NO_hist_beep            # Do not beep when accessing non-existent history.

  # Set the path to the history file.
  zstyle -s ':z1:history' histfile 'HISTFILE' || HISTFILE="$__zsh_user_data_dir/zsh_history"
  # Set the maximum number of events to save in the internal history.
  zstyle -s ':z1:history' histsize 'HISTSIZE' || HISTSIZE=20000
  # Set the maximum number of events to save in the history file.
  zstyle -s ':z1:history' savehist 'SAVEHIST' || SAVEHIST=100000

  # Use a better history command.
  alias history='fc -li'
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh 