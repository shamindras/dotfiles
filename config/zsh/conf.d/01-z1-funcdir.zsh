#!/bin/zsh

# ------------------------------------------------------------------------------
# region: Helper functions
# ------------------------------------------------------------------------------

# z1_funcdir: Setup the autoload directory for Zsh functions.
function z1_funcdir {
  emulate -L zsh; setopt local_options $__z1_opts
  local fndir zfuncdir
  zstyle -s ':z1:functions' dir 'zfuncdir' || zfuncdir=$__zsh_config_dir/functions
  for fndir in $zfuncdir(-/FN) $zfuncdir/*(-/FN); do
    fpath=($fndir $fpath)
    autoload -Uz $fndir/*~*/_*(N.:t)
  done
}

# endregion --------------------------------------------------------------------