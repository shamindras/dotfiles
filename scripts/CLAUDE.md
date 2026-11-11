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
├── ops/                       # ongoing-use scripts (justfile + install)
│   ├── audit-firefox
│   ├── clean-dotfiles
│   ├── doctor                 # read-only health report (just doctor)
│   ├── ensure-dropbox-link    # ~/Dropbox link (just dropbox_finish)
│   ├── manifest               # resolver: render, check, set, why, diff
│   ├── manifest.schema.json   # JSON Schema for manifest.json
│   ├── setup-firefox          # dual-use: firefox unit setup + just firefox_sync
│   ├── setup-nvim-treesitter  # dual-use: nvim unit setup + just treesitter_*
│   ├── sync-notes-config
│   └── treesitter-sync
├── setup/                     # one-time bootstrap scripts (install-only)
│   ├── post-install-hints
│   ├── setup-github-auth
│   ├── setup-hammerspoon
│   ├── setup-macos
│   ├── setup-upgrade-rust-cargo
│   ├── setup-upgrade-ttyper
│   └── setup-zk
└── test/                      # test harness (just test, test_static, test_sandbox; CI)
    ├── lib.sh
    ├── self-test
    ├── manifest_test.py
    ├── check-docs
    ├── check-invariants
    ├── check-paths
    ├── check-parity
    ├── check-hammerspoon
    ├── check-layout
    ├── check-config-load
    ├── sandbox-install
    ├── check-doctor
    ├── check-github-auth
    └── check-dropbox
```

Directories reflect *runtime role*, not install-only status:

- **`setup/`** — scripts invoked only by `./install` (unit setup steps in `manifest.json`) during
  first-time bootstrap or upgrade. Safe to re-run but rarely called directly.
- **`ops/`** — scripts invoked repeatedly via justfile targets *and/or* `./install`.
  Dual-use lands here (directory reflects runtime role, not who calls it).
- **`_lib/`** — internal helpers used only by other repo scripts: sourced bash
  libs (e.g., `step.sh`) and sibling-invoked utilities in any language (e.g.,
  `dropbox-info.py` called from `./bootstrap`). Not for direct user invocation.
- **`test/`** — tests for the repo itself. Run by `just test*` and CI; never
  touch the real `HOME` (sandboxes come from `mktemp`).

Filenames keep the `setup-` / `audit-` prefix for greppability even though
the subdir already provides that context.

## Key scripts

### setup/

| Script                       | Purpose                                                          |
| ---------------------------- | ---------------------------------------------------------------- |
| `setup-macos`                | macOS system defaults configuration                              |
| `setup-upgrade-rust-cargo`   | Stable toolchain via Homebrew's keg-only `rustup` (XDG `CARGO_HOME`/`RUSTUP_HOME`); skips when rustup is missing |
| `setup-hammerspoon`          | Configure Hammerspoon MJConfigFile + hidutil Caps→F18 LaunchAgent |
| `setup-upgrade-ttyper`       | `cargo install --locked ttyper` (the only cargo tool); skips when cargo is missing |
| `setup-github-auth`          | One SSH key per Mac (`~/.ssh/id_ed25519_github`), registered for authentication and signing via `gh`; allowed signers; work email to `~/.config/dotfiles/gitconfig.local`. State table in the header; prints the command and exits 0 when gh is not logged in |
| `setup-zk`                   | zk setup at `$ZK_NOTEBOOK_DIR`: notebook dirs; when under Dropbox, both ignore xattrs on `.zk/` (File Provider + legacy) read back; templates; corrupt-`notebook.db` recovery. Exits 0 with a message when the notes have not synced yet |
| `post-install-hints`         | Print manual post-install steps; suppressed by `DOTFILES_NO_HINTS=1` |

### ops/

| Script                       | Purpose                                                          |
| ---------------------------- | ---------------------------------------------------------------- |
| `audit-firefox`              | Check tracked Firefox prefs against live profile state           |
| `ensure-dropbox-link`        | Ensure `~/Dropbox` symlink points at the canonical CloudStorage path; called by bootstrap (Phase 6) and re-runnable for manual repair |
| `setup-firefox`              | Sync user.js, chrome/, policies.json into active Firefox profile |
| `setup-nvim-treesitter`      | Install/update treesitter parsers (`--status` for read-only table) |
| `doctor`                     | Read-only report (system, clone, Homebrew, apps, links, auth, Dropbox) with a paste block; macOS built-ins only |
| `manifest`                   | Resolver for `manifest.json` (Python 3.9+ stdlib): `render`, `check`, `set`, `why`, `diff` |

`manifest.schema.json` (next to the resolver) is the JSON Schema for
`manifest.json`. The resolver validates against it with a small built-in
validator, so no pip packages are needed. It runs at edit time and in CI only;
a fresh Mac installs from the committed `generated/` files. Model: units own
config, setup, service, `requires` and an `app` block; plain packages are
one-word entries in a module list (each becomes an implicit unit named after
the package). Top-level `roles` (today: `browser`) can own a leader key; each
profile names the unit that fills the role, and `resolved.json` carries the
final `leaders` map (key to unit) per profile. Each profile turns modules on and overrides single units as
`managed`, `external` (on the Mac, installed by someone else: links and app
block kept, no package or setup) or `off`. `requires` pulls units in; a
required unit the profile turned off is an error naming both. Setup steps with
`needs` are wrapped so a missing command skips the step with a reason.

### test/

| Script              | Recipe         | Checks                                                                                    |
| ------------------- | -------------- | ----------------------------------------------------------------------------------------- |
| `self-test`         | `test_static`  | The harness itself, against throwaway fixtures                                            |
| `manifest_test.py`  | `test_static`  | Resolver unit tests: closure, off-but-required, pairs, leaders, render                    |
| `check-docs`        | `test_static`  | Decision-note front matter, relative links under `docs/`, `docs/plan/graph.yaml`          |
| `check-invariants`  | `test_static`  | Runs each `docs/decisions/inv-*.md` `verify` command                                      |
| `check-paths`       | `test_static`  | Grep gates: repo and notes paths via `REPOS_DIR`/`NOTES_DIR`, no `/Users/<name>`          |
| `check-doctor`      | `test_sandbox` | doctor with `PATH=/usr/bin:/bin` changes nothing; paste block parses                      |
| `check-hammerspoon` | `test_static`  | `apps.lua` builder headless with lua: both profiles, off units, baseline tables           |
| `check-dropbox`     | `test_sandbox` | `just dropbox_finish` vs a fake Dropbox: link created/repointed, collision refused, notes |
| `check-layout`      | `test_static`  | Top-level allow-list; no token-shaped value in `config/gh/hosts.yml`                      |
| `check-github-auth` | `test_sandbox` | `setup-github-auth` state table against a stubbed `gh` in a throwaway HOME                |
| `check-parity`      | `test_static`  | `generated/home` vs the baseline install, minus `docs/plan/home-parity.json`              |
| `check-config-load` | `test_sandbox` | zsh syntax, interactive start-up and non-interactive env in a throwaway HOME              |
| `sandbox-install`   | `test_sandbox` | `./install --dry-run --profile <p>` into a throwaway HOME, twice                          |

Results: **PASS**, **FAIL**, **XFAIL** (fails until the named plan node lands),
**XPASS** (passes before its node lands; promote it), **SKIP** (always with a
reason). Only FAIL exits non-zero. A node has landed when a commit with the
trailer `Node: <id>` is in `HEAD`'s history; CI fetches full history for this.
`sandbox-install` never executes `./install` until its source declares
`--dry-run` and `--profile` (node N5), because the current `./install` changes
the real machine. Scripts are bash 3.2 compatible (macOS `/bin/bash`).

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

Two settings come from the profile, read with `plutil` from
`~/.config/dotfiles/resolved.json` (no profile names in the script):
`remote_login` (home: Remote Login on; work: left alone) and
`quarantine_warning` (home: off; work: on). Without the file both are left
as they are.

Applies `defaults write` commands for system preferences, Finder, Dock,
Aerospace, and third-party apps (Skim, Preview, DjView). Manages Login Items
for apps that need to start at login. Requires `sudo` for some settings.
Restarts Dock, Finder, and SystemUIServer at the end.

For TextEdit, sets new documents to open blank and defaults the rich-text
font to Helvetica 36pt via `NSFont`/`NSFontSize` (the keys AppKit's
`[NSFont userFontOfSize:]` reads; verified by round-tripping
`NSFont.setUser` through `NSUserDefaults` on macOS 26.5). A running TextEdit
caches the default at launch, so the size only applies to the next launch.

For Skim and Preview, also sets PDF view defaults and `NSUserKeyEquivalents`
for page navigation (`Ctrl+H/L/N/P`) and layout (`Cmd+1` / `Cmd+2`). Skim
gets full two-up non-continuous + zoom-to-fit via
`SKDefaultPDFDisplaySettings`. Preview is partial on macOS 26.5: sidebar
default closes via `PVSidebarViewModeForNewDocuments = 0`, but
`PVPDFDefaultPageViewModeOption` is inert in Tahoe (verified on fresh
PDFs — no value produces Two Pages on open), so `Cmd+2` is the
per-session workaround. Preview also lacks First/Last-page menu items,
so `Ctrl+H/L` can't be bound there.

For DjView (`org.djvu.DjView`), sets windowed defaults to two-pages-side-by-side,
fit-to-page, sidebar hidden via `forStandalone.options` + `forStandalone.zoom`.
Also sets `NSUserKeyEquivalents`: `Ctrl+H/L/N/P` for first/last/next/previous
page (same scheme as Skim/Preview) plus `Cmd+[`/`Cmd+]` for `Backward`/`Forward`
(matches the macOS-wide back/forward convention used by Preview and Skim
defaults — additive to djview's native `Opt+Left`/`Opt+Right`). Qt's QMenuBar
translates to native NSMenu on macOS so the override works, with the `&`
mnemonic in titles like `&First Page` stripped during translation (match
against `First Page`). The `Cmd+[`/`Cmd+]` values need `'"@["'` shell quoting
to avoid the `defaults` plist mini-language treating `@[` as an array opener.
`forStandalone.remember = 0` stops djview rewriting the options/zoom/state
group at quit (`saveRemembered()` gates on the flag), so session tweaks stay
per-session and every launch starts from the configured defaults. Trade-offs
(same flag in `updateSaved()`): window size is not remembered, and reopened
files still restore their own last page/zoom from the recent-files list
(`restoreRecentDocument()` is unconditional) — only first-time files get the
defaults. `NSUserKeyEquivalents` is independent and persists across launches. The `djview` Homebrew cask is deprecated upstream
(auto-disabled 2026-09-01 — Gatekeeper signature failure); the installed binary
at `/Applications/DjView.app` keeps working past that date, and the existence
guard makes the block a silent no-op if the cask eventually vanishes.
Alternatives surveyed (none drop-in): `ddjvu -format=pdf` → Skim; MacPorts
`okular`; Calibre's transcoding viewer; `mupdf-tools`.

### Login Items

Registers macOS Login Items for apps that don't have their own startup
mechanism. Cleans up redundant login items for apps that do.

| App                  | Startup mechanism          | Managed by          |
| -------------------- | -------------------------- | ------------------- |
| AeroSpace            | Login Item                 | `setup-macos`       |
| borders              | brew service (LaunchAgent) | `manifest.json`     |
| Dropbox              | Login Item                 | `setup-macos`       |
| Espanso              | `espanso service register` | `manifest.json`     |
| Flux                 | Login Item                 | `setup-macos`       |
| Hammerspoon          | Login Item (hs.autoLaunch) | `setup-hammerspoon` |
| noTunes              | Login Item                 | `setup-macos`       |
| Raycast              | Login Item                 | `setup-macos`       |
| Scroll Reverser      | Login Item                 | `setup-macos`       |
| Shottr               | Login Item                 | `setup-macos`       |
| sketchybar           | brew service (LaunchAgent) | `manifest.json`     |

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
