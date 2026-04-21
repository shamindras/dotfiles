# shellcheck shell=bash
#
# step.sh — two-tier progress helper for dotfiles scripts.
#
# Source this file; do NOT execute directly. The parent script owns strict
# mode (set -Eeuo pipefail). No local state is introduced.
#
# Functions:
#   step_outer X Y <emoji> <verb phrase>   — outer-tier progress across sub-targets
#   step_inner n total <verb phrase>       — inner-tier progress within one script
#   step_done  <emoji> <noun past-tense>   — universal completion line
#
# ANSI colour is enabled only when stdout is a TTY and NO_COLOR is unset.

_step_colour_on() { [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; }

step_outer() {
    local x=$1 y=$2 emoji=$3
    shift 3
    if _step_colour_on; then
        printf '\033[1m▶ %s/%s %s %s\033[0m\n' "$x" "$y" "$emoji" "$*"
    else
        printf '▶ %s/%s %s %s\n' "$x" "$y" "$emoji" "$*"
    fi
}

step_inner() {
    local n=$1 total=$2
    shift 2
    if _step_colour_on; then
        printf '  \033[2m├─ %s/%s %s\033[0m\n' "$n" "$total" "$*"
    else
        printf '  ├─ %s/%s %s\n' "$n" "$total" "$*"
    fi
}

step_done() {
    local emoji=$1
    shift
    printf '✅ %s\n' "$*"
}
