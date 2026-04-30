# scripts/

## Docs

- macOS defaults reference: <https://macos-defaults.com>
- Skim PDF viewer: <https://skim-app.sourceforge.io>
- `defaults` man page: `man defaults`
- `PlistBuddy` man page: `man PlistBuddy`

## Installed version

- macOS 26.3 (build 25D125)

## Layout

```
scripts/
├── CLAUDE.md                  # this file
├── _lib/                      # internal helpers (sourced libs + sibling-invoked utilities)
│   ├── dropbox-info.py        # prints synced Dropbox root from ~/.dropbox/info.json
│   └── step.sh                # two-tier progress helper
├── step                       # thin wrapper for inline recipes
├── migrate/                   # one-off migration utilities
├── ops/                       # ongoing-use scripts (justfile + install)
│   ├── audit-firefox
│   ├── setup-firefox          # dual-use: install.conf.yaml + just firefox_sync
│   └── setup-nvim-treesitter  # dual-use: install.conf.yaml + just treesitter_*
└── setup/                     # one-time bootstrap scripts (install-only)
    ├── post-install-hints
    ├── setup-dropbox
    ├── setup-macos
    ├── setup-upgrade-homebrew
    ├── setup-upgrade-kanata
    ├── setup-upgrade-rust-cargo
    ├── setup-upgrade-ttyper
    └── setup-zk
```

Directories reflect *runtime role*, not install-only status:

- **`setup/`** — scripts invoked only by `./install` / `install.conf.yaml` during
  first-time bootstrap or upgrade. Safe to re-run but rarely called directly.
- **`ops/`** — scripts invoked repeatedly via justfile targets *and/or* `./install`.
  Dual-use lands here (directory reflects runtime role, not who calls it).
- **`_lib/`** — internal helpers used only by other repo scripts: sourced bash
  libs (e.g., `step.sh`) and sibling-invoked utilities in any language (e.g.,
  `dropbox-info.py` called from `./bootstrap`). Not for direct user invocation.
- **`migrate/`** — one-off migration helpers. Unchanged.

Filenames keep the `setup-` / `audit-` prefix for greppability even though
the subdir already provides that context.

## Key scripts

### setup/

| Script                       | Purpose                                                          |
| ---------------------------- | ---------------------------------------------------------------- |
| `setup-macos`                | macOS system defaults configuration                              |
| `setup-dropbox`              | Wrapper around `./bootstrap --setup-only`                        |
| `setup-upgrade-homebrew`     | Homebrew installation/upgrade                                    |
| `setup-upgrade-rust-cargo`   | Rust toolchain management                                        |
| `setup-upgrade-kanata`       | Build kanata from source with cmd feature                        |
| `setup-upgrade-ttyper`       | Install/upgrade ttyper                                           |
| `setup-zk`                   | Zettelkasten (zk) setup                                          |
| `post-install-hints`         | Print manual post-install steps; suppressed by `DOTFILES_NO_HINTS=1` |

### ops/

| Script                       | Purpose                                                          |
| ---------------------------- | ---------------------------------------------------------------- |
| `audit-firefox`              | Check tracked Firefox prefs against live profile state           |
| `setup-firefox`              | Sync user.js, chrome/, policies.json into active Firefox profile |
| `setup-nvim-treesitter`      | Install/update treesitter parsers (`--status` for read-only table) |

## step.sh — progress helper

`_lib/step.sh` exposes three functions for scripts that want two-tier
progress indicators. Source it from any standalone script that emits
inner-tier progress; invoke it via the `scripts/step` wrapper from
inline justfile recipes that emit outer-tier progress.

```bash
# In a standalone script:
source "$(dirname "$0")/../_lib/step.sh"
step_inner 1 3 "Installing parsers"

# In a justfile recipe:
@scripts/step outer 1 8 🧹 "Cleaning artifacts"
@scripts/step inner 2 3 "Formatting configs"
@scripts/step done  🎨 "Lua configs formatted"
```

### Tier contract

- **Outer** (`▶ X/Y <emoji> <verb>`) — progress *across* sub-targets in a
  composite justfile recipe. Emitted by the justfile, not the sub-scripts.
- **Inner** (`  ├─ n/total <verb>`, dimmed) — progress *within* one script,
  interleaved with tool output. Emitted by the script itself.
- **Done** (`✅ <noun past-tense>`) — universal completion line. No tier prefix.

### ANSI colour

Colour is enabled only when stdout is a TTY and `NO_COLOR` is unset.
Pipes, redirects, and CI environments fall back to plain text.

### Strict mode

`_lib/step.sh` does **not** set `set -Eeuo pipefail` — the parent script
owns strict mode. The `scripts/step` wrapper does set strict mode (it's a
standalone entry point).

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
