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
    eval "$(zoxide init zsh)"
}

# fzf
# source: https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
function z1_brew_app_fzf {
    # Set up fzf key bindings and fuzzy completion
    eval "$(fzf --zsh)"
    # FZF options
    export FZF_DEFAULT_COMMAND='fd -HI -L --exclude .git --color=always'
    export FZF_DEFAULT_OPTS='
    --ansi
    --info inline
    --height 40%
    --reverse
    --border
    --multi
    --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
    --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
    '
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_T_OPTS="--preview '(bat --theme ansi-dark --color always {} 2> /dev/null || eza --tree --color=always {}) 2> /dev/null | head -200'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
    # The following is needed on OSX to enable Alt+C
    # source: https://github.com/junegunn/fzf/issues/164#issuecomment-581837757
    bindkey "ç" fzf-cd-widget
}

# endregion --------------------------------------------------------------------