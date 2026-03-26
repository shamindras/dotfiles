# Firefox Post-Install Checklist

After signing into Firefox Sync on a new machine, all extensions will be installed and most settings will sync
automatically (`storage.sync`).

The extensions marked with `storage.local` need manual configuration.

## Manual setup required (storage.local)

### Default Bookmark Folder

Open extension settings:

| Setting                         | Value   |
| ------------------------------- | ------- |
| Quick bookmark icon: folder     | none    |
| Quick bookmark icon: position   | **top** |
| Shortcut/context menu: folder   | none    |
| Shortcut/context menu: position | **top** |
| Inbox                           | enabled |
| Prevent removal                 | on      |
| Color                           | red     |

### New Tab Override

| Setting | Value                  |
| ------- | ---------------------- |
| URL     | `https://example.com/` |

### Improve YouTube!

| Setting | Value  |
| ------- | ------ |
| Theme   | black  |
| Style   | custom |

### Download Cleaner Lite

| Setting            | Value |
| ------------------ | ----- |
| Auto-clean files   | on    |
| Auto-clean history | on    |
| Auto-clean list    | on    |

### Harper (Grammar Checker)

| Setting      | Value     |
| ------------ | --------- |
| Lint context | page/main |

Re-add custom dictionary entries manually as needed.

### uBlock Origin

Restore from a backup file (Settings > Restore from file). Periodically export your config via Settings > Backup to
file.

## No action needed (auto-sync)

All extensions below sync settings automatically via Firefox Sync (`storage.sync`), their own account service, or
dotfiles.

| Extension                         | Sync method                                |
| --------------------------------- | ------------------------------------------ |
| 1Password                         | 1Password account                          |
| Adblock Plus                      | `storage.sync`                             |
| Better Netflix                    | `storage.sync`                             |
| Firefox Color                     | `storage.sync`                             |
| Improve Crunchyroll               | `storage.sync`                             |
| LeechBlock NG                     | `storage.sync`                             |
| LinkedIn Feed Blocker             | `storage.sync`                             |
| Mute Youtube ads                  | `storage.sync`                             |
| MyJDownloader Browser Extension   | `storage.sync`                             |
| Netflix Extended                  | `storage.sync`                             |
| Streaming Enhanced (Netflix/etc.) | `storage.sync`                             |
| Surfingkeys                       | Config in dotfiles (`config/surfingkeys/`) |
| Unhook (YouTube)                  | `storage.sync`                             |
| Video Hotkeys                     | `storage.sync`                             |
| YouTube Ad Auto-skipper           | `storage.sync`                             |
