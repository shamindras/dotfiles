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
| `setup-zk`               | Zettelkasten (zk) setup             |

## setup-macos

Applies `defaults write` commands for system preferences, Finder, Dock,
Aerospace, and third-party apps (Skim, Preview). Requires `sudo` for
some settings. Restarts Dock, Finder, and SystemUIServer at the end.

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
