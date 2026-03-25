# ------------------------------------------------------------------------------
# region: Plugin management (based on zsh_unplugged)
# source: https://github.com/mattmc3/zsh_unplugged
# ------------------------------------------------------------------------------

# Plugin directory: XDG_DATA_HOME for intentional installations.
# Override by setting ZPLUGINDIR before conf.d files are sourced.
: ${ZPLUGINDIR:=$__zsh_user_data_dir/plugins}

# plugin-load: Clone, compile, and source Zsh plugins.
# Accepts user/repo or user/repo@sha entries.
# Usage: plugin-load zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting
function plugin-load {
  emulate -L zsh; setopt local_options $__z1_opts

  local plugin repo commitsha plugdir initfile clone_args
  local -a initfiles
  for plugin in $@; do
    repo=$plugin
    clone_args=(--quiet --depth 1 --recursive --shallow-submodules)
    commitsha=""

    # Pin to a specific commit sha if provided (user/repo@sha).
    if [[ $plugin == *'@'* ]]; then
      repo=${plugin%@*}
      commitsha=${plugin#*@}
      clone_args+=(--no-checkout)
    fi

    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh

    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      command git clone "${clone_args[@]}" https://github.com/$repo $plugdir
      if [[ -n $commitsha ]]; then
        command git -C $plugdir fetch -q origin $commitsha
        command git -C $plugdir checkout -q $commitsha
      fi
      plugin-compile $plugdir
    fi

    # Symlink the init file to a standard name for fast subsequent loads.
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf $initfiles[1] $initfile
    fi

    fpath+=$plugdir
    . $initfile
  done
}

# plugin-update: Pull updates for all plugins in parallel, then recompile.
# Usage: plugin-update
function plugin-update {
  emulate -L zsh; setopt local_options $__z1_opts

  local plugdir oldsha newsha
  for plugdir in $ZPLUGINDIR/*/.git(N/); do
    plugdir=${plugdir:A:h}
    echo "Updating ${plugdir:t}..."
    (
      oldsha=$(command git -C $plugdir rev-parse --short HEAD)
      command git -C $plugdir pull --quiet --ff --depth 1 --rebase --autostash
      newsha=$(command git -C $plugdir rev-parse --short HEAD)
      [[ $oldsha == $newsha ]] || echo "Plugin updated: ${plugdir:t} ($oldsha -> $newsha)"
    ) &
  done
  wait
  plugin-compile
  echo "Update complete."
}

# plugin-compile: Compile plugin .zsh files to .zwc bytecode.
# Removes stale .zwc.old backups left by zrecompile.
# Usage: plugin-compile [dir]
function plugin-compile {
  emulate -L zsh; setopt local_options $__z1_opts
  autoload -Uz zrecompile
  local compile_dir=${1:-$ZPLUGINDIR}
  local zfile
  for zfile in $compile_dir/**/*.zsh{,-theme}(N); do
    [[ $zfile != */test-data/* ]] || continue
    zrecompile -pq "$zfile"
  done
  # Clean up .zwc.old backups left by zrecompile.
  local oldfile
  for oldfile in $compile_dir/**/*.zwc.old(N); do
    command rm -f "$oldfile"
  done
}

# plugin-list: List installed plugins.
# Usage: plugin-list
function plugin-list {
  emulate -L zsh; setopt local_options $__z1_opts
  local plugdir
  for plugdir in $ZPLUGINDIR/*/.git(N/); do
    print -r -- ${plugdir:A:h:t}
  done
}

# plugin-home: Print the plugin directory path.
# Usage: plugin-home
function plugin-home {
  emulate -L zsh; setopt local_options $__z1_opts
  print -r -- $ZPLUGINDIR
}

# z1_plugins: Load configured plugins with performance settings.
function z1_plugins {
  emulate -L zsh; setopt local_options $__z1_opts

  # Ensure plugin directory exists.
  [[ -d $ZPLUGINDIR ]] || mkdir -p $ZPLUGINDIR

  # Performance: skip per-precmd widget rebinding (autosuggestions).
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
  # Performance: skip suggestions on large pastes.
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

  # Plugin list: autosuggestions first, syntax-highlighting last.
  # syntax-highlighting must be sourced after all ZLE widgets are created.
  local -a plugins=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
  )

  plugin-load $plugins
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh
