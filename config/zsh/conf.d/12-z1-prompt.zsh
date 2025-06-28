#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Prompt
# ------------------------------------------------------------------------------

# A simple fast-loading zsh prompt
# source: https://dev.to/cassidoo/customizing-my-zsh-prompt-3417
function z1_simple_prompt {
  autoload -Uz vcs_info
  precmd() { vcs_info }

  zstyle ':vcs_info:git:*' formats '%b '

  setopt PROMPT_SUBST
  NEWLINE=$'\n'
  PROMPT='%F{blue}%~%f %F{green}${vcs_info_msg_0_}%f${NEWLINE}> '
}

# endregion --------------------------------------------------------------------
