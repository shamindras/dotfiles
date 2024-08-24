#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Setup built-in Zsh prompt system
# ------------------------------------------------------------------------------

# function prompt_z1_setup {
#   # Remove right prompt from prior commands
#   setopt transient_rprompt

#   function prompt_pwd {
#     setopt local_options extended_glob

#     local cur_pwd="${PWD/#$HOME/~}"
#     local MATCH result

#     if [[ "$cur_pwd" == (#m)[/~] ]]; then
#       result="$MATCH"
#     elif zstyle -m ':z1:prompt' pwd-length 'full'; then
#       result=${PWD}
#     elif zstyle -m ':z1:prompt' pwd-length 'long'; then
#       result=${cur_pwd}
#     else
#       result="${${${${(@j:/:M)${(@s:/:)cur_pwd}##.#?}:h}%/}//\%/%%}/${${cur_pwd:t}//\%/%%}"
#     fi

#     print -r -- "$result"
#   }

#   function +vi-git_status {
#     # Check for untracked files or updated submodules since vcs_info does not.
#     if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
#       hook_com[unstaged]='%F{red}•%f'
#     fi

#     ### git: Show ⇡N/⇣N when your local branch is ahead-of or behind remote HEAD.
#     # Make sure you have added misc to your 'formats':  %m
#     local ahead behind
#     local -a gitstatus

#     # Exit early in case the worktree is on a detached HEAD
#     git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

#     local -a ahead_and_behind=(
#       $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
#     )

#     ahead=${ahead_and_behind[1]}
#     behind=${ahead_and_behind[2]}

#     (( $ahead )) && gitstatus+=( "⇡${ahead}" )
#     (( $behind )) && gitstatus+=( "⇣${behind}" )

#     hook_com[misc]+=${(j:/:)gitstatus}
#   }

#   function prompt_z1_precmd {
#     setopt local_options
#     unsetopt xtrace ksh_arrays
#     _prompt_z1_pwd=$(prompt_pwd)
#     vcs_info
#   }

#   function prompt_z1_setup {
#     setopt local_options
#     unsetopt xtrace ksh_arrays
#     prompt_opts=(cr percent sp subst)

#     # Load required functions.
#     autoload -Uz add-zsh-hook
#     autoload -Uz vcs_info

#     # Add hook for calling vcs_info before each command.
#     add-zsh-hook precmd prompt_z1_precmd

#     # Define default prompt colors.
#     typeset -gA _prompt_z1_colors=(
#       black   "000"
#       red     "001"
#       green   "002"
#       yellow  "003"
#       blue    "004"
#       magenta "005"
#       cyan    "006"
#       white   "007"
#     )

#     # Use extended color pallete if available.
#     if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
#       zstyle -s ':z1:prompt:colors' black   '_prompt_z1_colors[black]'   || _prompt_z1_colors[black]="000"
#       zstyle -s ':z1:prompt:colors' red     '_prompt_z1_colors[red]'     || _prompt_z1_colors[red]="160"
#       zstyle -s ':z1:prompt:colors' green   '_prompt_z1_colors[green]'   || _prompt_z1_colors[green]="076"
#       zstyle -s ':z1:prompt:colors' yellow  '_prompt_z1_colors[yellow]'  || _prompt_z1_colors[yellow]="178"
#       zstyle -s ':z1:prompt:colors' blue    '_prompt_z1_colors[blue]'    || _prompt_z1_colors[blue]="039"
#       zstyle -s ':z1:prompt:colors' magenta '_prompt_z1_colors[magenta]' || _prompt_z1_colors[magenta]="168"
#       zstyle -s ':z1:prompt:colors' cyan    '_prompt_z1_colors[cyan]'    || _prompt_z1_colors[cyan]="037"
#       zstyle -s ':z1:prompt:colors' white   '_prompt_z1_colors[white]'   || _prompt_z1_colors[white]="255"
#     fi

#     # Define default prompt symbols.
#     typeset -gA _prompt_z1_chars=(
#       success "%%"
#       error   "%%"
#       vicmd   "V"
#       stash   "="
#       dirty   "*"
#       ahead   "+"
#       behind  "-"
#     )

#     # Use unicode chars if available.
#     if ! zstyle -t ':z1:prompt:unicode' disable; then
#       zstyle -s ':z1:prompt:character' success '_prompt_z1_chars[success]' || _prompt_z1_chars[success]="❱"
#       zstyle -s ':z1:prompt:character' error   '_prompt_z1_chars[error]'   || _prompt_z1_chars[error]="❱"
#       zstyle -s ':z1:prompt:character' vicmd   '_prompt_z1_chars[vicmd]'   || _prompt_z1_chars[vicmd]="❰"
#       zstyle -s ':z1:prompt:character' stash   '_prompt_z1_chars[stash]'   || _prompt_z1_chars[stash]="☰"
#       zstyle -s ':z1:prompt:character' dirty   '_prompt_z1_chars[dirty]'   || _prompt_z1_chars[dirty]="•"  # "✱"
#       zstyle -s ':z1:prompt:character' ahead   '_prompt_z1_chars[ahead]'   || _prompt_z1_chars[ahead]="⇡"
#       zstyle -s ':z1:prompt:character' behind  '_prompt_z1_chars[behind]'  || _prompt_z1_chars[behind]="⇣"
#     fi

#     # Set vcs_info parameters.
#     zstyle ':vcs_info:*' enable git
#     zstyle ':vcs_info:*' check-for-changes true
#     zstyle ':vcs_info:*' stagedstr "%F{${_prompt_z1_colors[green]}}${_prompt_z1_chars[dirty]}%f"
#     zstyle ':vcs_info:*' unstagedstr "%F{${_prompt_z1_colors[yellow]}}${_prompt_z1_chars[dirty]}%f"
#     zstyle ':vcs_info:*' formats '%b%c%u%m'
#     zstyle ':vcs_info:*' actionformats "%b%c%u%m|%F{cyan}%a%f"
#     zstyle ':vcs_info:git*+set-message:*' hooks git_status

#     # Define prompts.
#     PROMPT='%F{${_prompt_z1_colors[blue]}}$_prompt_z1_pwd%f %F{${_prompt_z1_colors[green]}}$_prompt_z1_chars[success]%f '
#     RPROMPT='${vcs_info_msg_0_}'
#   }

#   function prompt_z1_preview {
#     local +h PROMPT=''
#     local +h RPROMPT=''
#     local +h SPROMPT=''

#     editor-info 2> /dev/null
#     prompt_preview_theme 'z1'
#   }

#   prompt_z1_setup "$@"
# }

# z1_prompt: 
# function z1_prompt {
#   # Set prompt options.
#   setopt prompt_subst  # Expand parameters in prompt variables

#   # Initialize built-in prompt system.
#   autoload -Uz promptinit && promptinit

#   # Since we define prompt functions here and not in autoload function files in $fpath,
#   # we need to stick the theme's name into `$prompt_themes' ourselves, since promptinit
#   # does not pick them up otherwise.
#   prompt_themes+=( z1 )
#   # Also, keep the array sorted...
#   prompt_themes=( "${(@on)prompt_themes}" )

#   # Set prompt.
#   local -a prompt_argv
#   zstyle -a ':z1:prompt' theme 'prompt_argv'
#   if [[ $TERM == (dumb|linux|*bsd*) ]]; then
#     prompt 'off'
#   elif (( $#prompt_argv > 0 )); then
#     prompt "$prompt_argv[@]"
#   fi
# }

# endregion --------------------------------------------------------------------

# vim: ft=zsh 