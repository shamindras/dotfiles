# shellcheck shell=bash
#
# lib.sh — shared result bookkeeping for scripts/test/*.
#
# Source this file; do NOT execute it. The parent script owns strict mode.
# Bash 3.2 compatible (macOS /bin/bash): no associative arrays, no mapfile.
#
# Result kinds:
#   PASS   check passed
#   FAIL   check failed (makes the run exit 1)
#   XFAIL  check failed, but the node that makes it pass has not landed yet
#   XPASS  check passed before its node landed (reported, not a failure)
#   SKIP   check not applicable here (platform, missing tool); always has a reason
#
# A node has "landed" when HEAD's history has a commit with the trailer
# `Node: <id>`. N1 (this harness) counts as landed from the start.
# DOTFILES_TEST_LANDED="N1 N2 ..." overrides the git lookup (self-test only).

TEST_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
_t_pass=0 _t_fail=0 _t_xfail=0 _t_xpass=0 _t_skip=0
_t_report=""

_t_colour_on() { [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; }

_t_line() {
    local kind=$1 colour=$2
    shift 2
    if _t_colour_on; then
        printf '  \033[%sm%-5s\033[0m %s\n' "$colour" "$kind" "$*"
    else
        printf '  %-5s %s\n' "$kind" "$*"
    fi
    _t_report="${_t_report}| ${kind} | $* |"$'\n'
}

t_pass() {
    _t_pass=$((_t_pass + 1))
    _t_line PASS 32 "$*"
}
t_fail() {
    _t_fail=$((_t_fail + 1))
    _t_line FAIL 31 "$*"
}
t_xfail() {
    _t_xfail=$((_t_xfail + 1))
    _t_line XFAIL 33 "$*"
}
t_xpass() {
    _t_xpass=$((_t_xpass + 1))
    _t_line XPASS 36 "$*"
}
t_skip() {
    _t_skip=$((_t_skip + 1))
    _t_line SKIP 2 "$*"
}

# node_landed <id> — true when the node's commit is in HEAD's history.
node_landed() {
    local node=$1
    [[ "$node" == "N1" ]] && return 0
    if [[ -n "${DOTFILES_TEST_LANDED+x}" ]]; then
        case " $DOTFILES_TEST_LANDED " in *" $node "*) return 0 ;; esac
        return 1
    fi
    # No pipe into grep -q: the writer dies of SIGPIPE when grep exits early,
    # and pipefail turns that into a false "not landed".
    local log
    log="$(git -C "$TEST_REPO" log --format=%B HEAD 2>/dev/null)" || return 1
    grep -qx "Node: $node" <<<"$log"
}

# t_expect <node> <name> <command...> — run a command and classify the result.
# Before <node> lands a failure is XFAIL; after, it is FAIL.
t_expect() {
    local node=$1 name=$2 out rc
    shift 2
    out="$("$@" 2>&1)" && rc=0 || rc=$?
    if [[ $rc -eq 0 ]]; then
        if node_landed "$node"; then
            t_pass "$name"
        else
            t_xpass "$name (passes before $node landed: promote it)"
        fi
    else
        if node_landed "$node"; then
            t_fail "$name (exit $rc)"
            [[ -n "$out" ]] && printf '%s\n' "$out" | sed 's/^/        /' | head -20
        else
            t_xfail "$name (expected until $node lands)"
        fi
    fi
    return 0
}

# t_header <title> — print a section header.
t_header() { printf '%s\n' "── $* ──"; }

# t_summary <suite> — print counts, append to the CI step summary, return 1 on FAIL.
t_summary() {
    local suite=$1
    printf '%s: %d pass, %d fail, %d xfail, %d xpass, %d skip\n' \
        "$suite" "$_t_pass" "$_t_fail" "$_t_xfail" "$_t_xpass" "$_t_skip"
    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        {
            printf '### %s\n\n' "$suite"
            printf '| Result | Check |\n| ------ | ----- |\n%s\n' "$_t_report"
        } >>"$GITHUB_STEP_SUMMARY"
    fi
    [[ $_t_fail -eq 0 ]]
}
