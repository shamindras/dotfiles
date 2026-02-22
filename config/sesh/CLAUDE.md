# sesh Configuration

## Overview
sesh (by Josh Medeski) is a tmux session manager that discovers sessions from
active tmux sessions, zoxide records, and `sesh.toml` config. It complements
resurrect/continuum: sesh handles intentional session creation with layouts,
while resurrect/continuum handles crash recovery.

Docs: https://github.com/joshmedeski/sesh

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
| `scripts/*.sh` | Per-session startup scripts (window layouts) |
| `CLAUDE.md` | This documentation file |

## Startup Script Conventions

All scripts use:
- `#!/usr/bin/env bash` shebang
- `set -Eeuo pipefail` strict mode
- `SESSION` var matching the session name in `sesh.toml`
- `WORK_DIR` with `${DROPBOX_DIR:-$HOME/DROPBOX}` fallback
- `tmux rename-window` for window 1, `tmux new-window` for subsequent windows

### Common Window Patterns

| Window | Setup |
|--------|-------|
| `nvim` | `nvim +'lua Snacks.picker.smart()'` |
| `claude-term` | Vertical split: `claude` left (zoomed) + terminal right |
| `yazi` | `z $WORK_DIR && y` (zoxide frecency + yazi) |
| `preview` | `quarto preview` (blog session only) |
| `zk` | `kds` (daily session only — syncs templates + opens daily note) |
| `newsboat` | `newsboat` (newsboat session only) |

## tmux / WezTerm Integration

- `prefix+s` (or CMD+K via WezTerm) opens sesh fzf picker popup
- Filter keys in picker: `ctrl-a` all, `ctrl-t` tmux, `ctrl-g` config,
  `ctrl-x` zoxide, `ctrl-d` kill session
- CMD+K already sends `C-a s` via WezTerm — no WezTerm changes needed

## Adding a New Session

1. Add a `[[session]]` block to `sesh.toml` with name, path, startup_command
2. Create matching script in `scripts/` (copy an existing one as template)
3. `chmod +x` the new script
4. Run `sesh connect <name>` to test
