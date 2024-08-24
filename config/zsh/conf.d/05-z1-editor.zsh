#!/bin/zsh

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

# endregion --------------------------------------------------------------------