#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Setup editor and keybinds
# ------------------------------------------------------------------------------

# Set up vi style keybindings
# source: https://github.com/mrnugget/dotfiles/blob/c4624ed521d539856bcf764f04a295bb19093566/zshrc#L67C1-L116C25
function z1_vi_style_keybindings {
  # Vim Keybindings
  bindkey -v

  # Open line in Vim by pressing 'v' in Command-Mode
  autoload -U edit-command-line
  zle -N edit-command-line
  bindkey -M vicmd v edit-command-line

  # Push current line to buffer stack, return to PS1
  bindkey "^Q" push-input

  # Make up/down arrow put the cursor at the end of the line
  # instead of using the vi-mode mappings for these keys
  bindkey "\eOA" up-line-or-history
  bindkey "\eOB" down-line-or-history
  bindkey "\eOC" forward-char
  bindkey "\eOD" backward-char

  # CTRL-R to search through history
  # bindkey '^R' history-incremental-search-backward
  # CTRL-S to search forward in history
  # bindkey '^S' history-incremental-search-forward
  # Accept the presented search result
  # bindkey '^Y' accept-search

  # Use the arrow keys to search forward/backward through the history,
  # using the first word of what's typed in as search word
  bindkey '^[[A' history-search-backward
  bindkey '^[[B' history-search-forward

  # Use the same keys as bash for history forward/backward: Ctrl+N/Ctrl+P
  bindkey '^P' history-search-backward
  bindkey '^N' history-search-forward

  # Backspace working the way it should
  bindkey '^?' backward-delete-char
  bindkey '^[[3~' delete-char

  # Some emacs keybindings
  bindkey '^A' beginning-of-line
  bindkey '^E' end-of-line
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh 