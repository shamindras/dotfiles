# sesh Configuration

## Overview
sesh (by Josh Medeski) is a tmux session manager that discovers sessions from
active tmux sessions, zoxide records, and `sesh.toml` config. It complements
resurrect/continuum: sesh handles intentional session creation with layouts,
while resurrect/continuum handles crash recovery.

Docs: https://github.com/joshmedeski/sesh
Installed version: sesh 2.24.1 (verified 2026-02-22)

## Persistence Layers — No Conflict

| Tool | Responsibility | When it runs |
|------|---------------|--------------|
| sesh | Create sessions with predefined window layouts | `sesh connect` for **new** sessions only |
| resurrect | Snapshot all session/window/pane state to disk | Every 2 min (continuum) or `prefix+Ctrl-s` |
| continuum | Auto-trigger resurrect saves; auto-restore on tmux start | Server start + periodic |

Startup scripts only run when sesh creates a NEW session. After that,
resurrect tracks state. On reconnect, sesh just switches — no re-run.

## File Structure

| File | Purpose |
|------|---------|
| `sesh.toml` | Session definitions (name, path, startup_command) |
| `scripts/helpers.sh` | Shared helper functions (sourceable library, not executable) |
| `scripts/*.sh` | Per-session startup scripts (window layouts) |
| `CLAUDE.md` | This documentation file |

## Helper Library (`scripts/helpers.sh`)

Sourceable library providing DRY window-creation functions. Every function
takes `session` and `work_dir` as positional args (except `sesh_focus_window`
which takes `session` and `window_name`).

| Function | What it does |
|----------|-------------|
| `sesh_window_nvim` | Rename window 1 to "nvim", launch nvim with Snacks file picker |
| `sesh_window_claude` | New window "claude", run `claude` (single pane) |
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
- `tmux rename-window` for window 1, `tmux new-window` for subsequent windows

### Window Layout by Session

| Session | W1 | W2 | W3 | W4 | W5 | Focus |
|---------|----|----|----|----|----|----|
| dotfiles | nvim | claude | term | yazi | — | nvim |
| codebox | nvim | claude | term | yazi | — | nvim |
| ss_applications | nvim | claude | term | yazi | — | nvim |
| ss_personal_quarto_blog | nvim | claude | term | yazi | preview | nvim |
| zk | zk | claude | term | yazi | — | zk |
| rss | newsboat | term | — | — | — | *(implicit)* |

### Common Window Patterns

| Window | Setup |
|--------|-------|
| `nvim` | `sesh_window_nvim` — nvim with Snacks file picker |
| `claude` | `sesh_window_claude` — single pane running `claude` |
| `term` | `sesh_window_term` — plain terminal |
| `yazi` | `sesh_window_yazi` — direct command for correct PTY sizing |
| `preview` | `quarto preview` (blog session only, inline) |
| `zk` | `kds` (zk session only — syncs templates + opens daily note, inline) |
| `newsboat` | `newsboat` (rss session only, inline) |

## tmux / WezTerm Integration

- `prefix+s` (or CMD+K via WezTerm) opens sesh fzf picker popup
- Filter keys in picker: `ctrl-a` all, `ctrl-t` tmux, `ctrl-g` config,
  `ctrl-x` zoxide, `ctrl-d` kill session
- CMD+K already sends `C-a s` via WezTerm — no WezTerm changes needed

## Adding a New Session

1. Add a `[[session]]` block to `sesh.toml` with name, path, startup_command
2. Create matching script in `scripts/` — source `helpers.sh` and use shared
   functions for standard windows (nvim, claude, term, yazi)
3. Add session-specific windows inline after the shared calls
4. `chmod +x` the new script
5. Run `sesh connect <name>` to test
