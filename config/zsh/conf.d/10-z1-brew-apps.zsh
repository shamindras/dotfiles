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

# endregion --------------------------------------------------------------------