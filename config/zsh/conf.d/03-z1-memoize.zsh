# ------------------------------------------------------------------------------
# region: z1_memoize: Cache command output for fast shell startup
# ------------------------------------------------------------------------------

# __memoize_cmd: Evaluate a command, cache its output, and use its cache for 20 hours.
# The `L` glob qualifier requires a non-empty file; write to a tmp file and only
# promote on success + non-empty output. Prevents poisoning the cache with an
# empty file when the command isn't yet on PATH (e.g. during a fresh install).
function __memoize_cmd {
  emulate -L zsh; setopt local_options $__z1_opts
  local memofile=$__zsh_cache_dir/memoized/$1; shift
  local -a cached=($memofile(NL+0mh-20))
  if ! (( $#cached )); then
    mkdir -p ${memofile:h}
    local tmp=$memofile.tmp.$$
    if "$@" >| $tmp 2>/dev/null && [[ -s $tmp ]]; then
      mv -f $tmp $memofile
    else
      rm -f $tmp
      return 1
    fi
  fi
  source $memofile || true
}

# endregion --------------------------------------------------------------------

# vim: ft=zsh
