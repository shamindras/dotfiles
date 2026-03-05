# sesh Configuration

## Overview
sesh (by Josh Medeski) is a tmux session manager that discovers sessions from
active tmux sessions, zoxide records, and `sesh.toml` config. It complements
resurrect/continuum: sesh handles intentional session creation with layouts,
while resurrect/continuum handles crash recovery.

Docs: https://github.com/joshmedeski/sesh
Installed version: sesh 2.24.1 (verified 2026-02-22)

## Persistence Layers

| Tool | Owns | When it runs |
|------|------|--------------|
| sesh | **New** session creation (layouts from `startup_command`) | `sesh connect` when no matching session exists |
| resurrect | **Existing** session snapshots (window/pane state to disk) | Every 2 min (continuum) or `prefix+Ctrl-s` |
| continuum | Auto-trigger resurrect saves; auto-restore on tmux start | Server start + periodic |

### Interaction

Startup scripts only run when sesh creates a **new** session. After that,
resurrect owns state: continuum snapshots the session periodically, and
auto-restores it on the next cold start (`tmux kill-server` → reopen
terminal). On reconnect to a live session, sesh just switches — no re-run.

**Bug scenario:** if a startup script is broken, sesh creates a malformed
session → resurrect faithfully snapshots it → continuum auto-restores the
broken state on every cold start, preventing sesh from ever recreating it.

**Recovery:** use `sesh-reset <name>` (zsh function) to break the cycle:
1. Kills the tmux session(s)
2. Removes session entries from the resurrect save file
3. Creates detached tmux sessions + runs startup scripts (bypasses `sesh connect`
   to avoid blocking on attach)
4. Attaches/switches to the first session

## File Structure

| File | Purpose |
|------|---------|
| `sesh.toml` | Session definitions (name, path, startup_command) |
| `scripts/helpers.sh` | Shared helper functions (sourceable library, not executable) |
| `scripts/*.sh` | Per-session startup scripts (window layouts) |
| `CLAUDE.md` | This documentation file |

## Helper Library (`scripts/helpers.sh`)

Sourceable library providing DRY window-creation functions. Most functions
take `session` and `work_dir` as positional args. Exception:
`sesh_focus_window` takes `session` and `window_name`.

| Function | What it does |
|----------|-------------|
| `sesh_window_claude` | Rename window 1 to "claude", clear screen + run `claude` (inherits cwd from sesh.toml path) |
| `sesh_window_nvim` | New window "nvim", launch nvim with Snacks file picker |
| `sesh_window_term` | New window "term", plain shell |
| `sesh_window_yazi` | New window "yazi", run yazi as direct command (PTY sizing) |
| `sesh_focus_window` | Select/focus a named window |

Per-session scripts source helpers via:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"
```

## Startup Script Conventions

All scripts use:
- `#!/usr/bin/env bash` shebang
- `set -Eeuo pipefail` strict mode
- `SESSION` var matching the session name in `sesh.toml`
- `WORK_DIR` with `${DROPBOX_DIR:-$HOME/DROPBOX}` fallback
- `sesh_window_claude` renames window 1, all other windows use `tmux new-window`

### Window Layout by Session

| Session  | W1       | W2      | W3      | W4   | W5   | Focus    |
|----------|----------|---------|---------|------|------|----------|
| dots     | claude   | nvim    | term    | yazi | —    | claude   |
| play     | claude   | nvim    | term (uv venv) | yazi | —    | claude   |
| career   | claude   | nvim    | term    | yazi | —    | nvim     |
| blog     | claude   | nvim    | preview | term | yazi | nvim     |
| notes    | claude   | journal | nvim    | term | yazi | journal  |
| feed     | newsboat | term    | yazi    | —    | —    | newsboat |

### Common Window Patterns

| Window     | Setup |
|------------|-------|
| `claude`   | `sesh_window_claude` — renames window 1, clears + runs `claude` |
| `nvim`     | `sesh_window_nvim` — nvim with Snacks file picker |
| `term`     | `sesh_window_term` — plain terminal |
| `yazi`     | `sesh_window_yazi` — direct command for correct PTY sizing |
| `preview`  | `quarto preview` (`blog` session only, inline) |
| `journal`  | Explicit cd + rsync + `zk daily` (`notes` session only, inline — avoids alias race) |
| `newsboat` | `newsboat` (`feed` session only, inline) |

## tmux / WezTerm Integration

- `prefix+s` (or CMD+Shift+K via WezTerm) opens sesh fzf picker popup
- Filter keys in picker: `ctrl-a` all, `ctrl-t` tmux, `ctrl-g` config,
  `ctrl-x` zoxide, `ctrl-d` kill session
- CMD+Shift+K sends `C-a s` via WezTerm; CMD+K sends `C-a w` (session/window tree)

## Workflow Guide (tldr)

Sesh is the **single source of truth** for session creation.
Resurrect/continuum is a background safety net, not part of the normal workflow.

### Computer restart / cold start

Continuum auto-restore is OFF. Sesh recreates sessions fresh from sesh.toml.

```
sesh-reset --common         # notes, dots, play, blog, feed
sesh-reset --all            # common + career
```

Or connect one at a time: `sesh connect notes`, or use `prefix+s` picker.

### Reset a broken session

```
sesh-reset notes            # kill + prune resurrect + recreate from sesh.toml
sesh-reset notes feed       # multiple sessions
```

### Closed WezTerm but tmux is still running

tmux runs as a server independent of WezTerm. Just reopen WezTerm and run:
```
tmux attach                 # reattach to last session
```
All sessions and processes are still alive — no sesh-reset needed.

### Day-to-day

- Switch sessions: `prefix+s` (or `CMD+Shift+K`)
- Connect to config session: `sesh connect <name>`

### About resurrect/continuum

Continuum auto-saves every 2 min (keeps 10 snapshots). This is a background
safety net. Since auto-restore is OFF, snapshots are not used on cold start.
After a restart, continuum will overwrite the `last` snapshot within ~2 min
with the current (empty) state, so manual `prefix+Ctrl-r` is unreliable.
Stick with `sesh-reset` for all recovery.

## Adding a New Session

1. Add a `[[session]]` block to `sesh.toml` with name, path, startup_command
2. Create matching script in `scripts/` — source `helpers.sh` and use shared
   functions for standard windows (nvim, claude, term, yazi)
3. Add session-specific windows inline after the shared calls
4. `chmod +x` the new script
5. Run `sesh connect <name>` to test
