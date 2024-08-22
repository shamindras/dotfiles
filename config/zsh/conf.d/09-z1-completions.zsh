#!/bin/zsh

# ------------------------------------------------------------------------------
# region: zfunctions
# ------------------------------------------------------------------------------

# Init Fish-like functions directory.
() {
  # Which autoload functions directory to use? Use glob_subst to support '~'.
  if [[ -z "$ZFUNCDIR" ]]; then
    local ZFUNCDIR
    zstyle -s ':zephyr:plugin:zfunctions' directory 'ZFUNCDIR' || ZFUNCDIR=$__zsh_config_dir/functions
    ZFUNCDIR=${~ZFUNCDIR}
  fi

  # Autoload a user functions directory.
  local fndir
  for fndir in $ZFUNCDIR(-/FN) $ZFUNCDIR/*(-/FN); do
    fpath=($fndir $fpath)
    autoload -Uz $fndir/*~*/_*(N.:t)
  done
}

# endregion --------------------------------------------------------------------