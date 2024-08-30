#!/usr/env/bin zsh

# ------------------------------------------------------------------------------
# region: Setup editor and keybinds
# ------------------------------------------------------------------------------

function z1_editor_no_ps2 {
  emulate -L zsh
  local -r func=no-ps2-test

  if (( ${+functions[$func]} )); then
    unfunction -- $func
  fi

  if functions[$func]=$PREBUFFER$BUFFER 2>/dev/null &&
    (( ${+functions[$func]} )); then
    unfunction -- $func
    if functions[$func]=$PREBUFFER$BUFFER$'\ndo\ndone' 2>/dev/null &&
      (( ${+functions[$func]} )) ; then
      unfunction -- $func
    else
      local w
      zstyle -s 'z1:editor:no-ps2:' accept-line w || w=accept-line
      if [[ -n $w ]]; then
        builtin zle -- $w
      fi
      return
    fi
  fi

  LBUFFER+=$'\n'
}

function z1_editor {
  # Allow mapping Ctrl+S and Ctrl+Q shortcuts
  [[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

  # No PS2
  builtin zle -N z1_editor_no_ps2
  bindkey '^J' z1_editor_no_ps2
  bindkey '^M' z1_editor_no_ps2
  bindkey -e
}

# Set up vi style keybindings
# source: https://github.com/mrnugget/dotfiles/blob/c4624ed521d539856bcf764f04a295bb19093566/zshrc#L67C1-L116C25
function z1_vi_style_keybindings {
  # Vim Keybindings
  bindkey -v

  # This is a "fix" for zsh in Ghostty:
  # Ghostty implements the fixterms specification https://www.leonerd.org.uk/hacks/fixterms/
  # and under that `Ctrl-[` doesn't send escape but `ESC [91;5u`.
  #
  # (tmux and Neovim both handle 91;5u correctly, but raw zsh inside Ghostty doesn't)
  #
  # Thanks to @rockorager for this!
  # bindkey "^[[91;5u" vi-cmd-mode

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

  # Some emacs keybindings won't hurt nobody
  bindkey '^A' beginning-of-line
  bindkey '^E' end-of-line
}
# endregion --------------------------------------------------------------------

# vim: ft=zsh 