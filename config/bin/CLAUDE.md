# Custom Scripts (bin)

- **Docs**: N/A (custom scripts)
- **Installed version**: N/A

## File Structure

| File                  | Purpose                                                                |
| --------------------- | ---------------------------------------------------------------------- |
| `brew-update`         | Canonical Homebrew pipeline (sudo bootstrap → Caskroom sweep (*.upgrading + stub dirs) → tri-state mode detect {steady/drift/bootstrap} → dump (steady + drift) → update → upgrade --greedy (tolerant) → bundle install recovery → cleanup + emoji summary); dispatches to WezTerm popup when invoked as root via kanata |
| `btm-popup`           | Opens bottom (btm) monitor in popup terminal                           |
| `close-notifications` | Dismisses all macOS Notification Center alerts (grouped and individual) |
| `empty-trash`         | Empty Finder trash and switch to aerospace workspace B                 |
| `fastopen`            | Launch macOS apps by short name (centralized path lookup, POSIX sh)    |
| `gc`                  | Git-related utility script                                             |
| `leader-hud`          | Update sketchybar leader key HUD (show/hide with group labels)         |
| `open-nordvpn`        | Launch NordVPN with aerospace workspace integration                    |
| `quit-app`            | Switch workspace first, then lazy-quit app in background with notify   |
| `run-as-user`         | Execute a command as the console user (root→user context switch)       |
| `tmux-session-picker` | fzf-based tmux session switcher (exact match)                          |

## quit-app

**Default flow** (workspace-first): resolve target workspace → switch
workspace instantly → background { quit app → poll exit → sketchybar
notification (green ✓ success / red ✗ failure, 2s linger) }.

**`--activate-quit` flow** (Finder): quit first (needs app in focus) →
poll exit → animation delay → switch workspace. No background, no
notification.

If the app isn't running, workspace-first mode switches workspace and
exits immediately (idempotent, no notification).

### Flags

| Flag                        | Description                                            |
| --------------------------- | ------------------------------------------------------ |
| `--pkill <process>`         | Kill via `pkill -x` instead of osascript               |
| `--pkill-f <pattern>`       | Kill via `pkill -f` for pattern-based matching          |
| `--activate-quit`           | Activate app then send Cmd+Q (quit-first, no bg)       |
| `--delay <seconds>`         | Override POST_EXIT_DELAY (default 0.3, use 0 to skip)  |
| `--check <process>`         | If process is running, use primary workspace            |
| `--fallback <workspace>`    | Otherwise switch to this workspace (requires --check)   |

## Development Notes

- Symlinked to `~/.local/bin` during install (XDG_BIN_HOME)
- Scripts must have executable permissions (`chmod +x`)
- `fastopen` uses POSIX sh (not zsh) for minimal overhead
- `open-nordvpn` uses POSIX sh with multi-step aerospace integration
