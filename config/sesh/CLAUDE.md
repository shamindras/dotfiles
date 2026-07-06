# sesh Configuration

## Overview
sesh (by Josh Medeski) is a tmux session manager that discovers sessions from
active tmux sessions, zoxide records, and `sesh.toml` config. It is the
**single source of truth** for session persistence: layouts are declared in
`sesh.toml` + startup scripts, so any session can be recreated from scratch.
tmux-resurrect/continuum were removed 2026-07 — snapshot restores were never
exercised (auto-restore off, real programs not whitelisted) and the plugins
only added stale-state failure modes.

Docs: https://github.com/joshmedeski/sesh
Installed version: sesh 2.26.2 (verified 2026-07-04)

## Persistence Model

The tmux **server** is a daemon independent of WezTerm: quitting the
terminal app kills only the tmux *client* (the viewer), never the sessions
or the processes inside them. Attaching to any one session reaches the
whole server — every other session is one picker away.

| Layer | Owns | Survives |
|-------|------|----------|
| tmux server | Live sessions + running processes | WezTerm quits, client detaches |
| sesh (`sesh.toml` + scripts) | Declarative layouts for (re)creation | Everything, incl. reboots |

Startup scripts only run when sesh creates a **new** session. On reconnect
to a live session, sesh just attaches/switches — no re-run.

**Session tiers:**

| Tier    | Source                              | Layout                        | Reboot recovery              |
|---------|-------------------------------------|-------------------------------|------------------------------|
| sra     | `sesh.toml` `[[session]]`           | per-session script            | `sra`                        |
| ad-hoc  | `dirs.list` (exact paths + globs)   | `default.sh` via `[default_session]` | re-pick (`Cmd-Ctrl-K` / `sn`) |
| promote | `/sesh-promote` skill (ad-hoc → sra)| custom generated script       | joins `sra` automatically    |

**Recovery for a broken session:** `sesh-reset <name>` (zsh function):
1. Kills the tmux session(s)
2. Creates detached tmux sessions + runs startup scripts (bypasses `sesh connect`
   to avoid blocking on attach)
3. Attaches/switches to the first session

## File Structure

| File | Purpose |
|------|---------|
| `sesh.toml` | Session definitions + `[default_session]` fallback layout |
| `dirs.list` | Ad-hoc launchable directories (read by `sesh-dir-picker`) |
| `scripts/helpers.sh` | Shared helper functions (sourceable library, not executable) |
| `scripts/default.sh` | Generic ad-hoc layout (`[default_session]` startup) |
| `scripts/*.sh` | Per-session startup scripts (window layouts) |
| `CLAUDE.md` | This documentation file |

## Helper Library (`scripts/helpers.sh`)

Sourceable library providing DRY window-creation functions. Most functions
take `session` and `work_dir` as positional args. Exception:
`sesh_focus_window` takes `session` and `window_name`.

| Function                 | What it does                                                                       |
|--------------------------|------------------------------------------------------------------------------------|
| `sesh_window_items`      | Rename window 1 to "items", run `taskwarrior-tui;clear`                            |
| `sesh_window_claude`     | Rename window 1 to "claude", clear screen + run `claude` (inherits cwd)            |
| `sesh_window_claude_new` | New window "claude", clear + run `claude` (use when another window owns W1)        |
| `sesh_window_nvim`       | New window "nvim", launch nvim with Snacks file picker                             |
| `sesh_window_term`       | New window "term", plain shell                                                     |
| `sesh_window_yazi_tabs`  | New window "yazi" w/ preloaded tabs via `YAZI_STARTUP_TABS`/`YAZI_ACTIVE_TAB` env  |
| `sesh_focus_window`      | Select/focus a named window                                                        |

Two arrays at the top of `helpers.sh` drive the yazi tab layout:

| Array                    | Contents                                                            | Used by             |
|--------------------------|---------------------------------------------------------------------|---------------------|
| `SESH_BOOKS_TABS`        | reference_books, 00_now_reading, 01_next_up, 02_on_deck, 03_backlog | feed.sh             |
| `SESH_DEFAULT_YAZI_TABS` | `~/Downloads` + `SESH_BOOKS_TABS`                                   | every other session |

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
- `WORK_DIR` with `${DROPBOX_DIR:-$HOME/Dropbox}` fallback
- `sesh_window_claude` renames window 1, all other windows use `tmux new-window` or inline rename

### Window Layout by Session

| Session  | W1       | W2      | W3      | W4     | W5     | Focus    |
|----------|----------|---------|---------|--------|--------|----------|
| (ad-hoc) | claude   | yazi    | nvim    | term   | —      | claude   |
| dots     | claude   | yazi    | nvim    | term   | —      | claude   |
| play     | claude   | yazi    | nvim    | term (uv venv) | — | claude   |
| career   | claude   | yazi    | nvim    | term   | —      | nvim     |
| blog     | claude   | yazi    | nvim    | preview| term   | nvim     |
| notes    | journal  | yazi    | ideas   | term   | claude | journal  |
| feed     | newsboat | yazi    | term    | —      | —      | newsboat |

Every `yazi` window opens with these tabs (left → right):
WORK_DIR · Downloads (active) · books/reference_books · 00_now_reading · 01_next_up · 02_on_deck · 03_backlog.
The `feed` session collapses WORK_DIR with Downloads (they're the same dir)
so its yazi has 6 tabs instead of 7.

### Common Window Patterns

| Window     | Setup |
|------------|-------|
| `items`    | `sesh_window_items` — renames window 1, runs `taskwarrior-tui;clear`                   |
| `claude`   | `sesh_window_claude` (renames W1) or `sesh_window_claude_new` (new window)              |
| `nvim`     | `sesh_window_nvim` — nvim with Snacks file picker                                       |
| `term`     | `sesh_window_term` — plain terminal                                                     |
| `yazi`     | `sesh_window_yazi` — direct command for correct PTY sizing                               |
| `preview`  | `quarto preview` (`blog` session only, inline)                                           |
| `journal`  | Explicit cd + rsync + `zk daily` (`notes` session only, inline — avoids alias race)      |
| `newsboat` | `newsboat` (`feed` session only, inline)                                                 |

## tmux / WezTerm Integration

- `prefix+N s` (or CMD+Shift+K via WezTerm) opens sesh fzf picker popup
- Filter keys in picker: `ctrl-a` all, `ctrl-t` tmux, `ctrl-g` config,
  `ctrl-x` zoxide, `ctrl-d` kill session
- `prefix+N d` (or CMD+Ctrl+K) opens the ad-hoc directory picker
  (`~/.config/bin/sesh-dir-picker`)
- WezTerm K-column: CMD+K = `N w` tree, CMD+Shift+K = `N s` existing
  sessions, CMD+Ctrl+K = `N d` new session from directory

## Workflow Guide (tldr)

Four scenarios, four commands. Mental model: you attach to the tmux
*server*, not a session — landing anywhere makes every session reachable.

| Situation                          | Command             | Effect                                          |
| ---------------------------------- | ------------------- | ----------------------------------------------- |
| Quit WezTerm, back to work         | `sc` (or `tmux attach`) | Reattach — everything intact, nothing re-run |
| Work in a non-sra directory        | `Cmd-Ctrl-K` / `sn` | Pick from dirs.list → session w/ default layout |
| After a reboot, stand up all       | `sra`               | Recreate all sesh.toml sessions fresh           |
| One session is broken              | `sesh-reset <name>` | Kill + recreate just that session               |

### Closed WezTerm but tmux is still running (the common case)

The server and all processes are still alive. Reopen WezTerm and run:
```
sc                          # fzf-pick a session, attach (nothing killed)
tmux attach                 # or: name-free, lands in most-recent session
```
Do NOT run `sra` here — it kills the live sessions and rebuilds defaults.

`sc` is a zsh autoloaded function (`config/zsh/functions/sc`): bare `sc`
fzf-picks a session, `sc <name>` connects directly — attaches if the
session is alive, creates it from sesh.toml if not. Note `sesh connect`
requires a session name — there is no built-in name-free mode.

### Computer restart / cold start

A reboot kills the tmux server and every process in it — running programs
are not recoverable, by any tool. Recreate fresh:

```
sesh-reset --all            # alias sra: every sesh.toml session (derived
                            # via `sesh list -c`; lands in the first entry)
```

Or connect one at a time: `sc`, `sesh connect notes`, or the picker.

### Reset a broken session

```
sesh-reset notes            # kill + recreate from sesh.toml
sesh-reset notes feed       # multiple sessions
```

### Day-to-day

- Switch sessions: `prefix+s` (or `CMD+Shift+K`)
- Connect to config session: `sesh connect <name>` or `sc`

## Ad-hoc Sessions (dirs.list + default layout)

`~/.config/bin/sesh-dir-picker` (bound to `Cmd-Ctrl-K` / `prefix N d`;
zsh function `sn` from a bare shell) fzf-picks a directory from
`dirs.list` and `sesh connect`s it. Because the directory has no
`[[session]]` entry, sesh applies `[default_session].startup_command` →
`scripts/default.sh` (self-derives session/path; per-session
startup_commands always win).

`dirs.list` format — env-var literals (`${DROPBOX_DIR}`, `${HOME}`)
expanded at read time, `#` comments:

| Pattern     | Meaning                                              |
|-------------|------------------------------------------------------|
| `<path>`    | exact entry (auto-appended on first launch)          |
| `<path>/*`  | every child dir launchable (`/*/*` for grandchildren) |
| `<path>/**` | recursive fd scan (depth ≤6, hidden/.git excluded)   |

Behaviors to know:

- Paths owned by `[[session]]` entries are auto-excluded from the picker.
- Picking an untracked dir appends it to dirs.list (graduation) —
  append-only, `${DROPBOX_DIR}`-normalized, deduped.
- `[default_session]` also furnishes plain `sesh connect <dir>` and the
  old picker's `ctrl-x` zoxide connects — intended consistency. Opt a
  session out with `disable_startup_command = true` in its `[[session]]`.
- Ad-hoc sessions survive WezTerm quits (tmux server owns them) but die
  on reboot and are NOT part of `sra` — recovery is one re-pick.

## Adding a New Session

Run `/sesh-promote <dir>` to graduate an ad-hoc directory interactively
(generates the block, script, and doc updates). Manual steps:

1. Add a `[[session]]` block to `sesh.toml` with name, path,
   startup_command — **before** the `[default_session]` table
2. Create matching script in `scripts/` — source `helpers.sh` and use shared
   functions for standard windows (nvim, claude, term, yazi)
3. Add session-specific windows inline after the shared calls
4. `chmod +x` the new script
5. Run `sesh connect <name>` to test

Promoted/added sessions join `sesh-reset --all` automatically (derived
from `sesh list -c`).
