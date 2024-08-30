#!/usr/env/bin zsh

# ------------------------------------------------------------------------------
# region: Set Zsh utilities and options
# ------------------------------------------------------------------------------

function z1_utility {
  # 16.2.6 Input/Output
  setopt interactive_comments    # Enable comments in interactive shell.
  setopt rc_quotes               # Allow 'Hitchhiker''s Guide' instead of 'Hitchhiker'\''s Guide'.
  setopt NO_mail_warning         # Don't print a warning if a mail file was accessed.
  setopt NO_rm_star_silent       # Ask for confirmation for `rm *' or `rm path/*'

  # 16.2.7 Job Control
  setopt auto_resume             # Attempt to resume existing job before creating a new process.
  setopt long_list_jobs          # List jobs in the long format by default.
  setopt notify                  # Report status of background jobs immediately.
  setopt NO_bg_nice              # Don't run all background jobs at a lower priority.
  setopt NO_check_jobs           # Don't report on jobs when shell exit.
  setopt NO_hup                  # Don't kill jobs on shell exit.

  # 16.2.12 Zle
  setopt combining_chars         # Combine 0-len chars with base chars (eg: accents).
  setopt NO_beep                 # Be quiet

  # Use built-in paste magic.
  autoload -Uz bracketed-paste-url-magic
  zle -N bracketed-paste bracketed-paste-url-magic
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic

  # Load more specific 'run-help' function from $fpath.
  (( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
  alias help=run-help
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh 