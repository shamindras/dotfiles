# ------------------------------------------------------------------------------
# region: z1_memoize: Cache command output for fast shell startup
# ------------------------------------------------------------------------------

# __memoize_cmd: Evaluate a command, cache its output, and use its cache for 20 hours.
function __memoize_cmd {
  emulate -L zsh; setopt local_options $__z1_opts
  local memofile=$__zsh_cache_dir/memoized/$1; shift
  local -a cached=($memofile(Nmh-20))
  if ! (( $#cached )); then
    mkdir -p ${memofile:h}
    "$@" >| $memofile
  fi
  source $memofile || true
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh
