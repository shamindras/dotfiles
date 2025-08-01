#!/bin/zsh

# ------------------------------------------------------------------------------
# region: aliases
# ------------------------------------------------------------------------------

function z1_aliases {
  alias -- -='z -;clear;' # note we need -- since command begins with -
  alias ~='z ~'           # Go Home
  alias ..='z ..'
  alias ...='z ../..'
  alias ....='z ../../..'
  alias .2='z ../../'             # Go up 2 dirs
  alias .3='z ../../../'          # Go up 3 dirs
  alias .4='z ../../../../'       # Go up 4 dirs
  alias .5='z ../../../../../'    # Go up 5 dirs
  alias .6='z ../../../../../../' # Go up 6 dirs
  alias asl='aerospace list-apps'
  alias asr='aerospace reload-config;clear;'
  alias asf='(killall AeroSpace || true) && open -a AeroSpace;clear;' # [a]eroSpace [f]orced [r]estart
  alias b='bat --style=grid,numbers'
  alias bat='bat --style=grid,numbers'
  alias bu='brew update && brew upgrade && brew cleanup'
  alias brewinfo='brew leaves | xargs brew desc --eval-all'
  alias c='clear'
  alias cat='bat --paging=never'
  alias cd='z'
  alias cp='cp -r'
  alias cpi='cp -iv'
  alias da='deactivate'
  alias df='df -kH'
  alias dus='du -sckx * | sort -nr'
  alias er='espanso restart'
  alias ghd='gh dash;clear;'
  alias ghup='gh extension upgrade --all'
  alias kl='launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server'
  alias ls='eza --color=always --group-directories-first --icons'
  alias l='ls -la'
  alias lg='lazygit;clear;'
  alias less='less -R'
  alias md='mkdir -p'
  alias man='batman'
  alias n='nvim;clear'
  alias nn='nvim .;clear'
  alias nb='newsboat;clear;'
  alias paths='echo -e ${PATH//:/\\n}' # Echo all executable Paths
  alias rcp='rsync -ah --info=progress2'
  alias rmi='rm -i'
  alias rmf='rm -rf'
  alias rq='R -q --no-save'
  alias sc="source ${XDG_CONFIG_HOME}/zsh/.zshrc" # source ~/.zshrc
  alias top='btop;clear;'
  alias tree='eza --tree --all --group-directories-first -I ".git|.svn|.hg|.idea|.vscode|.Rproj.user|.pytest_cache"'
  alias t1='tree --level=1'
  alias tl1='t1 --long'
  alias t2='tree --level=2'
  alias tl2='t2 --long'
  alias t3='tree --level=3'
  alias tl3='t3 --long'
  alias tzsh="hyperfine --warmup=20 '/usr/bin/time zsh -i -c exit'"
  alias uac="ua;clear" # run `ua` function and clear screen

  # change directory and launch yazi
  alias yd="z ~/Downloads;y"
  alias yr="z ~/DROPBOX/RESOURCES/BOOKS/REFERENCE_BOOKS;y"
  alias yo="z ~/DROPBOX/RESOURCES/BOOKS/CURRENT_READING/books/ongoing;y"
  alias yu="z ~/DROPBOX/RESOURCES/BOOKS/CURRENT_READING/books/upcoming;y"

  # bat-extras
  # source: https://github.com/eth-p/bat-extras/tree/master
  alias bdf='batdiff'
  alias bmn='batman'
  alias brg='batgrep --smart-case --no-snip --no-separator --color --context=1'
  alias brga='brg --rga' # batgrep with ripgrep-all
  alias bpe='batpipe'
  alias bwt='batwatch'
  alias bpy='prettybat'

  # git
  # source: https://github.com/dlvhdr/dotfiles/blob/main/.config/zsh/aliases.zsh
  alias g='git'
  alias gaa='git add --all'
  alias gcb='git checkout -b'
  alias glg="git log --graph --abbrev-commit --decorate --format=format:'%C(yellow)%h%C(reset) %C(white)%s%C(reset) %C(dim white)-%C(reset) %ar %C(dim white)<%an>%C(reset)%C(auto)%d%C(reset)' --all"
  alias glg2="git log --graph --abbrev-commit --decorate --format=format:'%C(yellow)%h%C(reset) %C(white)%s%C(reset) %C(dim white)-%C(reset) %ar %C(dim white)<%an>%C(reset)%C(auto)%d%C(reset)%n' --all --stat"
  alias gsc='git switch -c'
  alias gsm='git switch main'
  alias gsmp='git switch main && git pull origin main'
  alias gst='git status -v'

  # directory aliases
  alias conf="z ${XDG_CONFIG_HOME};clear;"
  alias dots='z ~/DROPBOX/REPOS/dotfiles;clear;'
  alias down='z ~/Downloads;clear;'
  alias reps='z ~/DROPBOX/REPOS;clear;'
  alias refs='z ~/DROPBOX/RESOURCES/BOOKS/REFERENCE_BOOKS;clear;'
  alias play='z ~/DROPBOX/REPOS/codebox/notebooks;ua;clear;' # Also activates uv

  # source: running `xdg-ninja` in `$HOME` gave these suggestion
  # subversion
  alias svn="svn --config-dir ${XDG_CONFIG_HOME}/subversion"
  alias gpg='${aliases[gpg]:-gpg} --homedir \"\$GNUPGHOME\"'
  alias wget='wget --hsts-file=\"$XDG_DATA_HOME/wget-hsts\"'

  # Additional clean/wash aliases --
  # Source: https://github.com/sharkdp/fd/discussions/1615
  # Adapted from: https://github.com/ameensol/shell/blob/master/.zshenv#L29-L30

  # clean up current directory
  alias clean="fd '\.(DS_Store|swo|swp)$|~$' -d1 -tf -u -X rm"

  # clean up current directory AND all subdirectories
  alias wash="fd '\.(DS_Store|swo|swp)$|~$' -tf -u -X rm"
}

# Application open suffix alias --
# Source:
# https://github.com/sdaschner/dotfiles/blob/91f9578b6cf926efb06bb3b1ebbd1ccd0715e06d/.aliases#L327-L336
# For macOS we use `open -gj` to open the application in the background
function z1_suffix_aliases {
  alias -s {pdf,PDF}='open -gja Skim.app'
  alias -s {jpg,JPG,png,PNG}='open -gja Preview.app'
  alias -s {ods,ODS,odt,ODT,odp,ODP,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,xlsm,XLSM,ppt,PPT,pptx,PPTX,csv,CSV}='open -gja LibreOffice.app'
  alias -s {html,HTML}='open -gja /Applications/Firefox.app'
  alias -s {mp4,MP4,mov,MOV,mkv,MKV}='open -gja VLC.app'
  alias -s {zip,ZIP,war,WAR}='unzip -l'
  alias -s gz="tar -tf"
  alias -s {tgz,TGZ}="tar -tf"
}

# Global zsh git aliases.
# Can be used in the middle, not just at the start of the commands.
# Source: https://justingarrison.com/blog/2023-06-05-zsh-global-aliases/
function z1_global_aliases {
  # Use bat to display help pages in color
  # https://github.com/sharkdp/bat#highlighting---help-messages
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

  alias -g H='| head'
  # TODO fix this bat alias coloring
  alias -g L='| bat --pager="less -FRS" --color=always'
  alias -g G='| rg -p'
  alias -g W='| wc -l'
  alias -g J='| jq .'
  alias -g T="| tr -d '\n' "
  alias -g C="| pbcopy"
}
# endregion --------------------------------------------------------------------
