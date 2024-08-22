#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Directory
# ------------------------------------------------------------------------------

# z1_directory: Set options and aliases for file system.
function z1_directory {
  # Set options related to the file system, globbing, and directory stack.
  setopt auto_pushd     # Make cd push the old directory onto the dirstack.
  setopt pushd_minus    # Exchange meaning of +/- when navigating the dirstack.
  setopt pushd_silent   # Do not print the directory stack after pushd or popd.
  setopt pushd_to_home  # Push to home directory when no argument is given.
  setopt extended_glob  # Use extended globbing syntax.
  setopt glob_dots      # Don't hide dotfiles from glob patterns.
  setopt multios        # Write to multiple descriptors.
  setopt NO_clobber     # Don't overwrite files with >. Use >| to bypass.

  # Show directory stack.
  alias dirh='dirs -v'
}

# endregion --------------------------------------------------------------------
