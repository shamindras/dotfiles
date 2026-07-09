# Custom Scripts (bin)

- **Docs**: N/A (custom scripts)
- **Installed version**: N/A

## File Structure

| File                  | Purpose                                                                |
| --------------------- | ---------------------------------------------------------------------- |
| `brew-update`         | Canonical Homebrew pipeline (Caskroom sweep (*.upgrading + stub dirs) → tri-state mode detect {steady/drift/bootstrap} → dump (steady + drift) → update → upgrade --greedy (tolerant) → bundle install recovery → cleanup + emoji summary); sudo is invoked lazily (only when sweep has orphans or brew escalates for a pkg cask); dispatches to WezTerm popup when invoked without a TTY (e.g., from Hammerspoon's hs.task) |
| `btm-popup`           | Opens bottom (btm) monitor in popup terminal                           |
| `close-notifications` | Dismisses all macOS Notification Center alerts (grouped and individual) |
| `empty-trash`         | Empty Finder trash and switch to aerospace workspace B                 |
| `fastopen`            | Launch macOS apps by short name (centralized path lookup, POSIX sh)    |
| `gc`                  | Git-related utility script                                             |
| `leader-hud`          | Update sketchybar leader key HUD (show/hide with group labels)         |
| `open-nordvpn`        | Launch NordVPN with aerospace workspace integration                    |
| `quit-app`            | Switch workspace first, then lazy-quit app in background with notify   |
| `run-as-user`         | Execute a command as the console user (root→user context switch)       |
| `sesh-dir-picker`     | fzf picker for ad-hoc sesh sessions from `config/sesh/dirs.list`       |
| `tmux-session-picker` | fzf-based tmux session switcher (exact match)                          |
| `yazi-tabs`           | Launch yazi with curated preloaded tabs (Downloads + books library); single source of truth for tab data + name/index resolution, called by zsh `yt`, tmux `prefix O y`, and sesh scripts; feeds `YAZI_STARTUP_TABS`/`YAZI_ACTIVE_TAB` to `config/yazi/init.lua` |

## quit-app

**Default flow** (workspace-first): resolve target workspace → switch
workspace instantly → background { quit app → poll exit → sketchybar
notification (green ✓ success / red ✗ failure, 2s linger) }.

**`--activate-quit` flow** (Finder): quit first (needs app in focus) →
poll exit → animation delay → switch workspace. No background, no
notification.

If the app isn't running, workspace-first mode switches workspace and
exits immediately (idempotent, no notification).

**`--save-check <home-workspace>`** (TextEdit): before switching away,
query the app for documents with unsaved changes
(`count of (documents whose modified is true)` via osascript). If any are
dirty — or the query errors (fail safe) — switch to `<home-workspace>`,
activate the app, and fire the quit there, which presents the native save
dialog on-screen instead of on the destination workspace. A background
watcher then waits (user-paced, ~120s cap) for the dialog to resolve: if
the app exits (Save / Don't Save) it switches to the destination workspace
and posts the green quit notification; if it stays running (Cancel) it
leaves you on `<home-workspace>` with a yellow `⚠ <app> unsaved` notice.
Only an exact count of `0` is treated as clean and proceeds with the normal
workspace-first quit.

### Flags

| Flag                       | Description                                           |
| -------------------------- | ----------------------------------------------------- |
| `--pkill <process>`        | Kill via `pkill -x` instead of osascript              |
| `--pkill-f <pattern>`      | Kill via `pkill -f` for pattern-based matching        |
| `--activate-quit`          | Activate app then send Cmd+Q (quit-first, no bg)      |
| `--delay <seconds>`        | Override POST_EXIT_DELAY (default 0.3, use 0 to skip) |
| `--check <process>`        | If process is running, use primary workspace          |
| `--fallback <workspace>`   | Otherwise switch to this workspace (requires --check) |
| `--save-check <workspace>` | Unsaved docs: quit on its workspace (save dialog)     |

## Development Notes

- Symlinked to `~/.config/bin` during install (`${XDG_CONFIG_HOME}/bin` in
  `install.conf.yaml`) — NOT on `PATH`; callers use absolute paths
- Scripts must have executable permissions (`chmod +x`)
- `fastopen` uses POSIX sh (not zsh) for minimal overhead
- `open-nordvpn` uses POSIX sh with multi-step aerospace integration
