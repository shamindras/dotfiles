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

  # Register smart-enter as a ZLE widget (used by zsh-no-ps2 below).
  zle -N smart-enter

  # PS2 prevention: validate command syntax before execution.
  # On incomplete input, inserts a newline into the edit buffer instead of
  # dropping to the confusing PS2 secondary prompt.
  # source: https://github.com/romkatv/zsh-no-ps2
  function zsh-no-ps2 {
    setopt local_options no_err_return no_err_exit
    () {
      () {
        builtin emulate -L zsh -o extended_glob
        [[ $1 == (|*[^\\])(\\\\)#\\ ]]
      } "$1" && builtin return 1
      if [[ -v functions[-zsh-no-ps2-test] ]]; then
        builtin unfunction -- -zsh-no-ps2-test
      fi
      functions[-zsh-no-ps2-test]="$1" 2>/dev/null              || builtin return 1
      [[ -v functions[-zsh-no-ps2-test] ]]                      || builtin return 1
      builtin unfunction -- -zsh-no-ps2-test
      functions[-zsh-no-ps2-test]="$1"$'\ndo\ndone' 2>/dev/null || builtin return 0
      [[ -v functions[-zsh-no-ps2-test] ]]                      || builtin return 0
      builtin unfunction -- -zsh-no-ps2-test
      builtin return 1
    } "$PREBUFFER$BUFFER"
    if (( $? )); then
      builtin zle self-insert-unmeta
    else
      builtin local w
      builtin zstyle -s :zsh-no-ps2: accept-line w || w=accept-line
      if [[ -n $w ]]; then
        builtin zle -- "$w"
      fi
    fi
  }

  # Chain zsh-no-ps2 with smart-enter: valid commands go to smart-enter,
  # incomplete commands get a newline in the buffer instead of PS2.
  zstyle ':zsh-no-ps2:' accept-line smart-enter
  zle -N .zsh-no-ps2 zsh-no-ps2
  bindkey '^J' .zsh-no-ps2
  bindkey '^M' .zsh-no-ps2
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh
