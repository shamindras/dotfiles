# scripts/

## Docs

- macOS defaults reference: <https://macos-defaults.com>
- Skim PDF viewer: <https://skim-app.sourceforge.io>
- `defaults` man page: `man defaults`
- `PlistBuddy` man page: `man PlistBuddy`

## Installed version

- macOS 26.3 (build 25D125)

## Key scripts

| Script                    | Purpose                              |
| ------------------------- | ------------------------------------ |
| `setup-macos`             | macOS system defaults configuration  |
| `setup-dropbox`           | Dropbox installation and setup       |
| `setup-upgrade-homebrew`  | Homebrew installation/upgrade        |
| `setup-upgrade-rust-cargo`| Rust toolchain management            |
| `setup-upgrade-kanata`   | Build kanata from source with cmd feature |
| `setup-firefox`           | Firefox user.js and userChrome.css   |
| `setup-zk`               | Zettelkasten (zk) setup             |
| `setup-nvim-treesitter`  | Install/update treesitter parsers (`--status` for read-only table) |
| `post-install-hints`     | Print manual post-install steps (Firefox, Raycast); suppressed by `DOTFILES_NO_HINTS=1` |

## setup-macos

Applies `defaults write` commands for system preferences, Finder, Dock,
Aerospace, and third-party apps (Skim, Preview). Manages Login Items for
apps that need to start at login. Requires `sudo` for some settings.
Restarts Dock, Finder, and SystemUIServer at the end.

### Login Items

Registers macOS Login Items for apps that don't have their own startup
mechanism. Cleans up redundant login items for apps that do.

| App                  | Startup mechanism          | Managed by          |
| -------------------- | -------------------------- | ------------------- |
| AeroSpace            | Login Item                 | `setup-macos`       |
| borders              | brew service (LaunchAgent) | `install.conf.yaml` |
| Dropbox              | Login Item                 | `setup-macos`       |
| Espanso              | `espanso service register` | `install.conf.yaml` |
| Flux                 | Login Item                 | `setup-macos`       |
| Kanata               | LaunchDaemon               | `com.jtroo.kanata.plist` |
| noTunes              | Login Item                 | `setup-macos`       |
| Raycast              | Login Item                 | `setup-macos`       |
| Scroll Reverser      | Login Item                 | `setup-macos`       |
| Shottr               | Login Item                 | `setup-macos`       |
| sketchybar           | brew service (LaunchAgent) | `install.conf.yaml` |

To add a new login item, append its path to the `login_items` array in
`setup-macos`. For apps with their own startup mechanism (brew services,
LaunchAgent, in-app config), do NOT add a login item — use the app's
native mechanism instead.

### Version sensitivity

macOS and third-party apps can rename, deprecate, or change the type of
`defaults` keys across releases. Before adding or modifying a setting:

1. **Check the current macOS version**: `sw_vers`
2. **Read the current value first**: `defaults read <domain> <key>`
3. **Verify after writing**: `defaults read <domain> <key>` to confirm
   the value and type were accepted
4. **Test the behaviour**: open the affected app and confirm the setting
   took effect

For **NSToolbar** nested dictionaries (e.g., Skim toolbar config), use
`defaults write -dict` with the full dictionary rather than `-dict-add`,
which mishandles keys containing spaces. See the Skim toolbar entry in
`setup-macos` for the pattern.
