# Custom Scripts (bin)

- **Docs**: N/A (custom scripts)
- **Installed version**: N/A

## File Structure

| File                  | Purpose                                                                |
| --------------------- | ---------------------------------------------------------------------- |
| `book-librarian`      | Library pipeline CLI (rename to `author-year-title`, DjVu→PDF conversion, books.bib generation, manifest-driven incremental sweeps); thin launcher over `config/booklib/` — see `config/booklib/CLAUDE.md` |
| `brew-update`         | Canonical Homebrew pipeline (Caskroom sweep (*.upgrading + stub dirs) → tri-state mode detect {steady/drift/bootstrap} → dump (steady + drift) → update → upgrade --greedy (tolerant) → bundle install recovery → cleanup + emoji summary); sudo is invoked lazily (only when sweep has orphans or brew escalates for a pkg cask); dispatches to WezTerm popup when invoked without a TTY (e.g., from Hammerspoon's hs.task) |
| `btm-popup`           | Opens bottom (btm) monitor in popup terminal                           |
| `close-notifications` | Dismisses all macOS Notification Center alerts (grouped and individual) |
| `empty-trash`         | Empty Finder trash and switch to aerospace workspace B                 |
| `fastopen`            | Launch macOS apps by short name (centralized path lookup, POSIX sh); Finder is special-cased via AppleScript `reopen` (always running, often windowless — plain `open` activates without creating a window, so no aerospace switch) |
| `gc`                  | Git-related utility script                                             |
| `ipad-mirror`         | Open QuickTime straight into a movie-recording window (bypasses the launch file picker, where Cancel quits the app); live view of a USB-connected iPad for Zoom screen sharing, routed to aerospace workspace 9 with focus following; leader `RCmd → o → 9` opens, `RCmd → q → 9` quits back to workspace W; `ipad-mirror` zsh alias |
| `leader-hud`          | Update sketchybar leader key HUD (show/hide with group labels)         |
| `move-books`          | Wipe `.DS_Store` FIRST (`wipe-ds-store`, same sweep as leader `RCmd → r → w`), rename epubs in Downloads (`rename-ebooks`, rename precedes move by user preference), then sweep Downloads → books library (pdf/djvu → reference_books, epub → ebooks, misfiled ref epubs → ebooks), then detach a silent `book-librarian sweep --async --apply` (converts/renames new arrivals, updates manifest + books.bib; no notification — check `book-librarian status`); leader `RCmd → r → m` + `mvb` alias; dirs env-overridable (`MOVE_BOOKS_{DOWNLOADS,REF,EBOOKS}`) for testing |
| `rename-ebooks`       | Normalize epub filenames to `author-year-title.epub` (`[a-z0-9-]`, edition year, ≤6 title words) from embedded OPF metadata; python3 stdlib only, slug rules + OPF parsing imported from `config/booklib/` (single source of truth); skips + reports files with unusable metadata or collisions; appends undo pairs to `$XDG_STATE_HOME/rename-ebooks/rename-log.tsv`; `--dry-run` + optional dir arg; pdfs ignored by design |
| `nordvpn-pause`       | `on\|off\|toggle\|status` — pause NordVPN for 15 min / resume early without a CLI: `hs -c` into `config/hammerspoon/nordvpn.lua`, which presses the connection card's AX-identified buttons (no focus change); re-creates the window with `open -g` if it was closed; TTY → stdout, else sketchybar leader label (⏸ / ▶ / ✗, 2s linger); leader `RCmd → r → n` (toggle) + `nordvpn-pause` zsh alias |
| `quit-app`            | Switch workspace first, then lazy-quit app in background with notify   |
| `run-as-user`         | Execute a command as the console user (root→user context switch)       |
| `sesh-dir-picker`     | fzf picker for ad-hoc sesh sessions from `config/sesh/dirs.list`       |
| `tmux-session-picker` | fzf-based tmux session switcher (exact match)                          |
| `wipe-ds-store`       | Remove `.DS_Store`: recursive in books library + Downloads + Documents, depth-1 in `$HOME`; single source of truth for leader `RCmd → r → w` and the `move-books` preamble |
| `yazi-tabs`           | Launch yazi with curated preloaded tabs (Documents, Downloads + books library incl. ebooks); single source of truth for tab data + name/index resolution, called by zsh `yt`, tmux `prefix O y`, and sesh scripts; feeds `YAZI_STARTUP_TABS`/`YAZI_ACTIVE_TAB` to `config/yazi/init.lua` |

## quit-app

**Default flow** (workspace-first): resolve target workspace → switch
workspace instantly → show pending `… <app> quitting` label (lavender,
instant feedback) → background { settle delay → quit app → poll exit →
sketchybar notification (green ✓ success / red ✗ failure, 2s linger) }.

The settle delay between workspace switch and quit signal is per-app
(`SETTLE_DELAY` lookup): 1.0s default, 1.5s for non-native apps whose
shutdown steals focus (DjView, JDownloader2), 0.3s for menu-bar-centric
apps whose quit never touches window focus (NordVPN). The ✓ label only
appears once the exit is verified, so the pending label covers the
settle + app-teardown gap that was previously silent.

**`--activate-quit` flow**: quit first (activate app, then Cmd+Q) →
poll exit → animation delay → switch workspace. No background, no
notification. Escape hatch for apps that ignore the quit Apple Event —
no current callers (Finder was thought to need it, but it responds to
the plain quit event, so it now uses the default workspace-first flow).

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
- `nordvpn-pause` needs Hammerspoon running with `hs.ipc` loaded (it is the
  AX bridge); without it the script fails fast with `✗ Hammerspoon unreachable`
