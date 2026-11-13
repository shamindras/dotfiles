# Homebrew Configuration

- **Docs**: https://brew.sh/
- **Installed version**: Homebrew 7.0.8 (verified 2026-10-08)

## File Structure

There is no hand-maintained Brewfile any more. Packages are declared in
`manifest.json` (units and module lists); `just manifest_render` writes one
Brewfile per profile:

| File                         | Purpose                                         |
| ---------------------------- | ----------------------------------------------- |
| `generated/home/Brewfile`    | Home profile packages, grouped by module        |
| `generated/work/Brewfile`    | Work profile packages, grouped by module        |
| `config/brew/CLAUDE.md`      | This file                                       |

`./install` installs the profile's Brewfile one module at a time (core
first, per-package fallback). `brew-update` reconciles against the same file
through `~/.config/dotfiles/resolved.json` (transitional fallback:
`generated/home`).

## Key Settings

- **Taps**: felixkratz/formulae, nikitabobko/tap (declared in `manifest.json`, emitted only when used)
- **Formulas and casks**: home 145, work 76 (see `generated/compare.md`)
- **Formatters and linters**: only the copies repo scripts or CI call (prettier, shellcheck, stylua); Mason installs
  nvim's own (decision `adr-16-formatters-mason`)
- **Not from Homebrew**: ttyper (`cargo install`), gh-dash (`gh extension`), yazi and tmux plugins

## Update Strategy

**Policy**: Homebrew originates all updates. In-app update prompts are
closed; upgrades are triggered by running the canonical pipeline
(`config/bin/brew-update`, invoked by the `bu` alias and the Hammerspoon
leader `RCmd → r → b`). `HOMEBREW_UPGRADE_GREEDY=1`
is set in `config/zsh/conf.d/01-z1-env-vars-gen.zsh` to align with
this policy.

**Canonical pipeline** (`config/bin/brew-update`):

1. Sudo bootstrap (one prompt up front, cached for the run).
2. Sweep broken Caskroom state *before* mode detection. Removes
   `*.upgrading` orphans from prior crashed runs, and stub Caskroom
   dirs that contain only `.metadata` (no version subdir — a shape
   that makes `brew list --cask` wrongly report the cask as installed).
3. Tri-state mode detect — checks **set membership** of declared
   entries against `brew list` directly (not `brew bundle check`, which
   conflates "missing" with "outdated"; an outdated package would
   otherwise trigger false drift every routine run):
   - **steady** — every declared formula/cask appears in `brew list`.
     Outdated versions are fine — step 6 handles upgrades.
   - **drift** — some declared entries are absent from `brew list` but
     brew is populated (user ran `brew uninstall foo`, or a prior run
     crashed).
   - **bootstrap** — brew is (near-)empty vs the Brewfile (fresh
     machine). Gated by `installed_count < brewfile_entries / 2`.
4. **Manifest drift report** (read-only; replaces the old dump). Lists
   packages installed on request but not declared (installed by hand)
   and, in drift mode, packages declared but not installed (uninstalled
   by hand), each with the command that records the change. Nothing is
   written: not the Brewfile, not the manifest.
5. `brew update`.
6. `brew upgrade --greedy` — **tolerant** (`|| true`); individual cask
   failures do not abort the run.
7. `brew bundle install` — upgrade-by-default; reconciles toward the
   Brewfile, re-installing anything step 6 silently dropped, but never
   what was uninstalled by hand (those entries are left out of the
   reinstall list). In bootstrap mode it installs everything.
8. `brew cleanup` + emoji summary.

### Known limitation: pkg-shaped auto-updating casks

Three casks in the current Brewfile are `.pkg` installers with
`auto_updates: true`:

| Cask                 | Artifact | Failure mode under `--greedy`          |
| -------------------- | -------- | -------------------------------------- |
| `nordvpn`            | pkg      | uninstall stanza runs; reinstall needs |
| `xquartz`            | pkg      | sudo/TTY and can fail non-interactively |
| `zoom`               | pkg      | — app vanishes until recovered.         |

The script's step 7 (`brew bundle install`) fresh-installs whatever step
6 dropped. After a failed greedy cycle, the cask is reinstalled at the
version Homebrew-cask currently tracks; the app then self-updates to
truly-latest on next launch. This is the best achievable "brew-originated"
story for these four given their upstream cask definitions.

Add or remove `.pkg` auto-updating casks in the table above whenever the
Brewfile changes (grep `auto_updates true` + `pkg` in `brew info --cask
<name> --json=v2` for any new cask you add).

### Known limitation: git-sourced casks under the download sandbox

Homebrew 7 runs cask downloads inside a macOS sandbox that denies reads
of `~/Library/CloudStorage` and `~/Dropbox`. Casks whose `url` is a git
repository (e.g. Google Fonts casks with `version :latest`) invoke git,
which reads `~/.config/git/config`. That path is a dotbot symlink into
Dropbox, so git aborts with "Operation not permitted". Upstream's fix
(Homebrew/brew#24119) only covers a symlinked `~/.gitconfig`, not the
XDG directory. Prefer casks that download an archive (curl); check with
`brew info --cask --json=v2 <name> | jq .casks[0].url` before adding.

### Reinstall recovery — in-run vs between-run

**In-run** (step 6 drops → step 7 recovers): works because step 4 dumps
the Brewfile **before** step 6 runs. If `--greedy` silently drops NordVPN
at step 6, the Brewfile still declares it (dumped from pre-upgrade state),
so step 7's `brew bundle install` reinstalls it. This is automatic.

**Between-run** (prior run crashed mid-pipeline, leaving a cask
uninstalled): drift mode cannot distinguish "user intentionally
uninstalled" from "prior run crashed" — both present as declared-but-
missing. If left unguarded, drift-mode dump would drop the entry from
the Brewfile, and step 7 would have nothing to reinstall.

Mitigation: the **step 2 sweep** first removes any broken Caskroom state
(`.upgrading` orphans and `.metadata`-only stubs) so that `brew list`'s
view matches `brew bundle dump`'s definition of installed. In drift
mode, step 3 then prints the list of declared-but-missing entries
before the step-4 dump runs, e.g.

```
🧭 [3/8] Mode: drift
   Absent from brew — step 4 dump will drop from Brewfile:
       cask "nordvpn"
   If any of these are unintentional, Ctrl-C now, run
   brew install [--cask] <name>, then re-run bu.
```

If the list matches the user's intent (a deliberate uninstall), they let
it proceed and the dump captures the removal. If the list contains
surprises (e.g. NordVPN from a crashed run), they Ctrl-C, `brew install
--cask nordvpn`, re-run `bu` — now bundle check passes → steady → no
drop.

## Adding and Removing Packages

`manifest.json` is the only declaration; `brew-update` reports drift and
never writes it.

- **Add**: add the package to a module list (or a unit) in `manifest.json`,
  `just manifest_render`, then `brew install` it or run `./install`. Or
  `brew install` first and let the next `brew-update` remind you.
- **Remove from one profile**: `just manifest_set <profile> <unit> off`.
  This never uninstalls anything; uninstall by hand if wanted.
- **Remove everywhere**: delete it from `manifest.json`, render, and
  `brew uninstall` it. `brew bundle cleanup` and `brew autoremove` are
  never run automatically.

## Development Notes

- Canonical upgrade entry point: `config/bin/brew-update`.
- Install a profile's Brewfile (without upgrade or cleanup):
  `brew bundle --file=generated/<profile>/Brewfile`.
- Homebrew itself is installed by `./bootstrap` (official installer, then
  `brew shellenv` in the same run).
- Brew env vars set in zsh `01-z1-env-vars-gen.zsh`:
  `HOMEBREW_UPGRADE_GREEDY=1`, `HOMEBREW_NO_ANALYTICS=1`,
  `HOMEBREW_NO_ENV_HINTS=1`, `HOMEBREW_NO_UPDATE_REPORT_NEW=1` (hides
  the "New Formulae" / "New Casks" advertising list that `brew update`
  prints when taps gain entries — display-only, no behavioral change).
  `HOMEBREW_AUTOREMOVE=1` is not set — autoremove is the default;
  setting it emits a deprecation warning.
