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
1. Kills the tmux session
2. Removes session entries from the resurrect save file
3. Reconnects via `sesh connect` (creates fresh from `startup_command`)

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
| `sesh_window_claude` | Rename window 1 to "claude", run `claude` (inherits cwd from sesh.toml path) |
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
| play     | claude   | nvim    | term    | yazi | —    | nvim     |
| career   | claude   | nvim    | term    | yazi | —    | nvim     |
| blog     | claude   | nvim    | preview | term | yazi | nvim     |
| notes    | claude   | journal | nvim    | term | yazi | journal  |
| feed     | newsboat | term    | yazi    | —    | —    | newsboat |

### Common Window Patterns

| Window     | Setup |
|------------|-------|
| `claude`   | `sesh_window_claude` — renames window 1, runs `claude` |
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

## Adding a New Session

1. Add a `[[session]]` block to `sesh.toml` with name, path, startup_command
2. Create matching script in `scripts/` — source `helpers.sh` and use shared
   functions for standard windows (nvim, claude, term, yazi)
3. Add session-specific windows inline after the shared calls
4. `chmod +x` the new script
5. Run `sesh connect <name>` to test
