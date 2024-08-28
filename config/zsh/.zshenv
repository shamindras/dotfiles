#!/bin/zsh

# The `.zshenv` file will be symlinked into `~/.zshenv`
# This will ensure that the `$ZDOTDIR` variable is correctly loaded.
# All other zsh config files, will be sourced from `$ZDOTDIR`.
# Although this breaks XDG specification for `.zshenv` only, it results
# in a more robust `zsh` config setup overall.
# source: https://www.reddit.com/r/zsh/comments/qtehjs/comment/hkkpzyi/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}
# source -- "$ZDOTDIR"/.zshenv
