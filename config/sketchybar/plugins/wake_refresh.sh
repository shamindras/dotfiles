#!/usr/bin/env bash
set -Eeuo pipefail

# Only act on actual system wake, not on routine updates — otherwise
# `sketchybar --update` would re-trigger this script in an infinite loop.
[ "${SENDER:-}" = "system_woke" ] || exit 0

# Self-heal a wedged process: if the on-disk sketchybar binary has been
# replaced since our parent PID started (e.g. `brew upgrade` ran), child
# bash spawns can silently fail with TCC EPERM, leaving the bar visible
# but frozen. Detect that case here and restart the brew service so the
# new PID picks up current TCC grants. Otherwise just push a refresh.
SB_BIN="$(readlink -f /opt/homebrew/opt/sketchybar/bin/sketchybar 2>/dev/null || true)"
if [ -n "$SB_BIN" ] && [ -n "${PPID:-}" ] && [ "$PPID" != "1" ]; then
  bin_mtime="$(stat -f %m "$SB_BIN" 2>/dev/null || echo 0)"
  lstart="$(ps -o lstart= -p "$PPID" 2>/dev/null || true)"
  proc_epoch=0
  [ -n "$lstart" ] && proc_epoch="$(date -j -f '%a %b %e %T %Y' "$lstart" '+%s' 2>/dev/null || echo 0)"

  if [ "$bin_mtime" -gt 0 ] && [ "$proc_epoch" -gt 0 ] && [ "$bin_mtime" -gt "$proc_epoch" ]; then
    # Detach so this child exits before the parent receives SIGTERM.
    nohup brew services restart sketchybar >/dev/null 2>&1 </dev/null &
    disown
    exit 0
  fi
fi

sketchybar --update
