# Taskwarrior + taskwarrior-tui Configuration

- **Taskwarrior docs**: https://taskwarrior.org/docs/
- **taskwarrior-tui docs**: https://github.com/kdheepak/taskwarrior-tui
- **Taskwarrior version**: task 3.4.2 (verified 2026-03-23)
- **taskwarrior-tui version**: 0.26.7 (verified 2026-03-25)

## File Structure

| File                        | Purpose                                            |
| --------------------------- | -------------------------------------------------- |
| `taskrc`                    | Main config (contexts, aliases, display, TUI keys) |
| `themes/catppuccin-mocha.theme` | Catppuccin Mocha color theme (256-color)       |
| `scripts/tui/tag.sh`            | Toggle-tag script for TUI shortcut keys 1-8    |
| `scripts/tui/context-toggle.sh` | Toggle context ↔ none for TUI shortcut key 9   |

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

## Tags (8 with shortcuts, +statml manual)

| Tag         | Typical contexts | Purpose                |
| ----------- | ---------------- | ---------------------- |
| `+errands`  | errands          | Shopping, pickups      |
| `+coding`   | work, study      | Programming tasks      |
| `+calls`    | home, work       | Phone calls            |
| `+emails`   | home, work       | Emails to handle       |
| `+blog`     | blog             | Blog writing, updates  |
| `+reading`  | work, study      | Papers, books          |
| `+ai`       | study            | AI/ML domain           |
| `+math`     | study            | Mathematics            |
| `+statml`   | study            | Statistical ML (no shortcut, use `m` → `+statml`) |

## TUI Shortcut Keys

Keys 1-8 toggle tags on/off (`scripts/tui/tag.sh`).
Key 9 toggles context between current and none (`scripts/tui/context-toggle.sh`).
Previous context is persisted in `~/.local/state/task/prev-context`.

| Key | Action                   |
| --- | ------------------------ |
| 1   | toggle `+errands`        |
| 2   | toggle `+coding`         |
| 3   | toggle `+calls`          |
| 4   | toggle `+emails`         |
| 5   | toggle `+blog`           |
| 6   | toggle `+reading`        |
| 7   | toggle `+ai`             |
| 8   | toggle `+math`           |
| 9   | toggle context ↔ none    |

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

## Theme Management

Taskwarrior has no built-in theme system. Themes are `.theme` files loaded
via the `include` directive in `taskrc`.

- **Set theme**: `include ~/.config/task/themes/<name>.theme` in `taskrc`
- **Add a theme**: place a `.theme` file in `config/task/themes/`
- Themes define `color.*` rules mapping task attributes to 256-color codes
