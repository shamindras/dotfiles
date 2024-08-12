#!/bin/zsh

# ------------------------------------------------------------------------------
# region: aliases
# ------------------------------------------------------------------------------

alias -- -='z -' # note we need -- since command begins with -
alias b='bat --style=grid,numbers'
alias bat='bat --style=grid,numbers'
alias ..='z ..'
alias ...='z ../..'
alias ....='z ../../..'
alias .....='z ../../../..'
alias ......='z ../../../../..'
alias .......='z ../../../../../..'
alias cp='cp -r'
alias cpi='cp -iv'
alias df='df -kH'
alias dus='du -sckx * | sort -nr'
alias ls='eza --color=always --group-directories-first --icons'
alias l='eza -l --color=always --group-directories-first --icons'
alias ll='eza -la --color=always --group-directories-first --icons'
alias lh='eza -lah --color=always --group-directories-first --icons'
alias lg='lazygit;clear;'
alias less='less -R'
alias md='mkdir -p'
alias rmi='rm -i'
alias rmf='rm -rf'
alias sc="source $HOME/.config/zsh/.zshrc" # source ~/.zshrc
alias tree="eza --tree --all --group-directories-first -I '.git|.svn|.hg|.idea|.vscode|.Rproj.user|.pytest_cache'"
alias t1="tree --level=1"
alias tl1="t1 --long"
alias t2="tree --level=2"
alias tl2="t2 --long"

# subversion alias 
# source: running `xdg-ninja` in `$HOME` gave this suggestion
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"

# Additional clean/wash aliases --
# Source: https://github.com/ameensol/shell/blob/master/.zshenv#L29-L30
# clean up current directory
# TODO use `fd` instead of `find` to speed this up
alias clean="find . -maxdepth 1 -name '*.DS_Store' -o -name '*~' -o -name '.*~' -o -name '*.swo' -o -name '*.swp' -o -name '.*.swo' | xargs rm"

# clean up current directory AND all subdirectories
# TODO use `fd` instead of `find` to speed this up
alias wash="find . -name '*.DS_Store' -o -name '*~' -o -name '.*~' -o -name '*.swo' -o -name '*.swp' -o -name '.*.swo' | xargs rm"

# Application open suffix alias --
# Source:
# https://github.com/sdaschner/dotfiles/blob/91f9578b6cf926efb06bb3b1ebbd1ccd0715e06d/.aliases#L327-L336
# Note: For macOS we use `open -gj` to open the application in the background
alias -s {pdf,PDF}='open -gja Skim.app'
alias -s {jpg,JPG,png,PNG}='open -gja Preview.app'
alias -s {ods,ODS,odt,ODT,odp,ODP,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,xlsm,XLSM,ppt,PPT,pptx,PPTX,csv,CSV}='open -gja LibreOffice.app'
alias -s {html,HTML}='open -gja Google\ Chrome.app' # TODO use `firefox` instead of `Chrome`
alias -s {mp4,MP4,mov,MOV,mkv,MKV}='open -gja VLC.app'
alias -s {zip,ZIP,war,WAR}="unzip -l"
alias -s gz="tar -tf"
alias -s {tgz,TGZ}="tar -tf"



# endregion --------------------------------------------------------------------