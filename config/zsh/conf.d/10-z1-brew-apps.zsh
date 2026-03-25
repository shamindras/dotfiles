#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Configure various brew apps
# ------------------------------------------------------------------------------

# Starship prompt
# source: https://starship.rs/#zsh
function z1_brew_app_starship {
  eval "$(starship init zsh)"
}

# Zoxide
# source: https://github.com/ajeetdsouza/zoxide/tree/d99e9b7d8671946dafe53662c519045f84d1d334#step-2-add-zoxide-to-your-shell
function z1_brew_app_zoxide {
  # Cache the output of `zoxide init zsh` for 20 hours (via __memoize_cmd)
  # instead of running the command on every shell startup.
  __memoize_cmd 'zoxide_init.zsh' zoxide init zsh
}

# fzf
# source: https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
function z1_brew_app_fzf {
  # Cache fzf shell integration for 20 hours (via __memoize_cmd)
  # instead of running `fzf --zsh` on every shell startup.
  __memoize_cmd 'fzf_init.zsh' fzf --zsh
  # FZF options
  export FZF_DEFAULT_COMMAND='fd -HI -L --exclude .git --color=always'
  export FZF_DEFAULT_OPTS='
    --ansi
    --info inline
    --height 40%
    --reverse
    --border
    --multi
    --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8
    --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC
    --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8
    --color=selected-bg:#45475A
    --color=border:#6C7086,label:#CDD6F4
    '
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview '(bat --theme \"Catppuccin Mocha\" --color always {} 2> /dev/null || eza --tree --color=always {}) 2> /dev/null | head -200'"
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  # The following is needed on OSX to enable Alt+C
  # source: https://github.com/junegunn/fzf/issues/164#issuecomment-581837757
  bindkey "ç" fzf-cd-widget
}

# Atuin
# source: https://docs.atuin.sh/guide/installation/#installing-the-shell-plugin
function z1_brew_app_atuin {
  eval "$(atuin init zsh)"
}

# endregion --------------------------------------------------------------------

