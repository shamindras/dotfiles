# Taskwarrior + taskwarrior-tui Configuration

- **Taskwarrior docs**: https://taskwarrior.org/docs/
- **taskwarrior-tui docs**: https://github.com/kdheepak/taskwarrior-tui
- **Taskwarrior version**: task 3.4.2 (verified 2026-03-23)
- **taskwarrior-tui version**: 0.26.5 (verified 2026-03-23)

## File Structure

| File                        | Purpose                                            |
| --------------------------- | -------------------------------------------------- |
| `taskrc`                    | Main config (contexts, aliases, display, TUI keys) |
| `themes/catppuccin-mocha.theme` | Catppuccin Mocha color theme (256-color)       |
| `scripts/tui/tag.sh`       | Quick-tag script for TUI shortcut keys 1-9         |

## Contexts (6)

All contexts have both `.read` (filter view) and `.write` (auto-tag new tasks) filters.

| Context    | Tag        | Mode                              |
| ---------- | ---------- | --------------------------------- |
| `home`     | `+home`    | Household, personal admin, calls  |
| `work`     | `+work`    | Professional tasks                |
| `study`    | `+study`   | Deep work: AI, math, stat-ML      |
| `reading`  | `+reading` | Dedicated reading sessions        |
| `blog`     | `+blog`    | Blog writing and updates          |
| `errands`  | `+errands` | Out and about: shopping, pickups  |

## Tags (9, flat, combinable)

| Tag        | Typical contexts | Purpose                |
| ---------- | ---------------- | ---------------------- |
| `+ai`      | study            | AI/ML domain           |
| `+math`    | study            | Mathematics            |
| `+statml`  | study            | Statistical ML         |
| `+coding`  | work, study      | Programming tasks      |
| `+writing` | work, study      | Docs, papers, prose    |
| `+reading` | work, study      | Papers, books          |
| `+calls`   | home, work       | Phone calls            |
| `+emails`  | home, work       | Emails to handle       |
| `+quick`   | any              | Can be done in <15 min |

## TUI Shortcut Keys (quick-tag)

All shortcuts call `scripts/tui/tag.sh` with a tag argument.

| Key | Tag        |
| --- | ---------- |
| 1   | `+ai`      |
| 2   | `+math`    |
| 3   | `+statml`  |
| 4   | `+coding`  |
| 5   | `+writing` |
| 6   | `+reading` |
| 7   | `+calls`   |
| 8   | `+emails`  |
| 9   | `+quick`   |

## Key Design Decisions

- **Tags are flat** — Taskwarrior tags do not support hierarchy (only projects do)
- **No taskwarrior aliases for contexts** — aliases matching context names cause
  recursive expansion (e.g., `alias.work=context work` loops); use `task context <name>`
  directly or press `c` in the TUI instead
- **taskwarrior-tui has no separate config file** — all TUI settings live in
  `taskrc` under `uda.taskwarrior-tui.*` keys
- **No fzf tag picker** — taskwarrior-tui does not support it; use tab completion
  (`Tab`/`Ctrl+n` after `+`) or shortcut keys 1-9 instead
- **Theme uses 256-color palette** — mapped from Catppuccin Mocha hex values
