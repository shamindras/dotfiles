#!/usr/env/bin zsh

# ------------------------------------------------------------------------------
# region: Plugin utilities
# ------------------------------------------------------------------------------

# plugin-clone: Use git to clone Zsh plugins in parallel.
function plugin-clone {
  emulate -L zsh; setopt local_options $__z1_opts

  local repo_dir git_url
  zstyle -s ':z1:plugins:repos' dir     'repo_dir' || repo_dir=$__zsh_cache_dir/repos
  zstyle -s ':z1:plugins:repos' git_url 'git_url'  || git_url="https://github.com"

  local repo repo_url plugin_dir
  local -Ua repos=($@)
  for repo in $repos; do
    if [[ $repo == (http(|s)://|git@)* ]]; then
      repo_url=$repo
    else
      repo_url=$git_url/$repo
    fi

    plugin_dir=$repo_dir/${${repo_url:t}%.git}
    if [[ ! -d $plugin_dir ]]; then
      echo "Cloning $repo..."
      (
        command git clone --quiet --depth 1 --recursive --shallow-submodules $repo_url $plugin_dir
        plugin-compile $plugin_dir
      ) &
    fi
  done
  wait
}

# plugin-home: Show the plugin home directory
function plugin-home {
  emulate -L zsh; setopt local_options $__z1_opts
  local repo_dir
  zstyle -s ':z1:plugins:repos' dir 'repo_dir' || repo_dir=$__zsh_cache_dir/repos
  print -r -- $repo_dir
}

# plugin-list: List cloned plugins.
function plugin-list {
  emulate -L zsh; setopt local_options $__z1_opts
  local repo_dir plugin_dir
  zstyle -s ':z1:plugins:repos' dir 'repo_dir' || repo_dir=$__zsh_cache_dir/repos
  for plugin_dir in $repo_dir/*/.git(N/); do
    print -r -- ${plugin_dir:A:h:t}
  done
}

# plugin-update: Use git to pull updates to Zsh plugins.
function plugin-update {
  emulate -L zsh; setopt local_options $__z1_opts
  local repo_dir
  zstyle -s ':z1:plugins:repos' dir 'repo_dir' || repo_dir=$__zsh_cache_dir/repos

  local plugin_dir oldsha newsha
  for plugin_dir in $repo_dir/*/.git(N/); do
    plugin_dir=${plugin_dir:A:h}
    echo "Updating ${plugin_dir:t}..."
    (
      oldsha=$(command git -C $plugin_dir rev-parse --short HEAD)
      command git -C $plugin_dir pull --quiet --ff --depth 1 --rebase --autostash
      newsha=$(command git -C $plugin_dir rev-parse --short HEAD)
      [[ $oldsha == $newsha ]] || echo "Plugin updated: $plugin_dir:t ($oldsha -> $newsha)"
    ) &
  done
  wait
  plugin-compile
  echo "Update complete."
}

# plugin-compile: Compile plugins.
function plugin-compile {
  emulate -L zsh; setopt local_options $__z1_opts
  local repo_dir
  zstyle -s ':z1:plugins:repos' dir 'repo_dir' || repo_dir=$__zsh_cache_dir/repos
  autoload -Uz zrecompile
  local zfile
  for zfile in ${1:-$repo_dir}/**/*.zsh{,-theme}(N); do
    [[ $zfile != */test-data/* ]] || continue
    zrecompile -pq "$zfile"
  done
}

# z1_plugins: Setup Zsh plugins.
function z1_plugins {
  emulate -L zsh; setopt local_options $__z1_opts

  local repo_dir giturl
  zstyle -s ':z1:repos' repo_dir 'repo_dir' || repo_dir=$__zsh_cache_dir/repos
  zstyle -s ':z1:plugins' git_url  'git_url'  || git_url="https://github.com"

  # Get all the different plugin types.
  local -a {clone,path,fpath,zsh,defer}_plugins
  zstyle -a ':z1:plugins:load:kind' clone 'clone_plugins'
  zstyle -a ':z1:plugins:load:kind' path  'path_plugins'
  zstyle -a ':z1:plugins:load:kind' fpath 'fpath_plugins'
  zstyle -a ':z1:plugins:load:kind' zsh   'zsh_plugins'
  zstyle -a ':z1:plugins:load:kind' defer 'defer_plugins'

  # Combine for cloning missing ones.
  local -a plugins=($clone_plugins $path_plugins $fpath_plugins $zsh_plugins $defer_plugins)

  # Remove bare words ${(M)plugins:#*/*} and paths with leading slash ${plugins:#/*}.
  # Then split/join to keep the 2-part user/repo form to bulk-clone repos.
  local repo; local -aU repos
  for repo in ${${(M)plugins:#*/*}:#/*}; do
    repo=${(@j:/:)${(@s:/:)repo}[1,2]}
    if [[ ! -d $ZSH_REPO_HOME/$repo ]]; then
      (
        command git clone -q --depth 1 --recursive --shallow-submodules \
          $git_url/$repo $ZSH_REPO_HOME/$repo
          plugin-compile $ZSH_REPO_HOME/$repo
      ) &
    fi
  done
  wait
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh 