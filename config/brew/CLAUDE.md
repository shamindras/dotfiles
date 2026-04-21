# Homebrew Configuration

- **Docs**: https://brew.sh/
- **Installed version**: Homebrew 5.1.7 (verified 2026-04-21)

## File Structure

| File       | Purpose                                 |
| ---------- | --------------------------------------- |
| `Brewfile` | Package manifest (100+ formulas/casks)  |

## Key Settings

- **Taps**: felixkratz/formulae, nikitabobko/tap
- **Formulas**: 100+ CLI tools and libraries
- **Casks**: GUI apps (aerospace, karabiner, wezterm, etc.)

## Update Strategy

**Policy**: Homebrew originates all updates. In-app update prompts are
closed; upgrades are triggered by running the canonical pipeline
(`config/bin/brew-update`, invoked by `./install`, the `bu` alias, and
kanata leader `r b`). `HOMEBREW_UPGRADE_GREEDY=1` is set in
`config/zsh/conf.d/01-z1-env-vars-gen.zsh` to align with this policy.

**Canonical pipeline** (`config/bin/brew-update`):

1. Sudo bootstrap (one prompt up front, cached for the run).
2. Sweep broken Caskroom state *before* mode detection. Removes
   `*.upgrading` orphans from prior crashed runs, and stub Caskroom
   dirs that contain only `.metadata` (no version subdir — a shape
   that makes `brew list --cask` wrongly report the cask as installed
   while `brew bundle dump` skips it, which otherwise causes step 3
   to silently drop the entry from the Brewfile).
3. Tri-state mode detect — checks **set membership** of declared
   entries against `brew list` directly (not `brew bundle check`, which
   conflates "missing" with "outdated"; an outdated package would
   otherwise trigger false drift every routine run):
   - **steady** — every declared formula/cask appears in `brew list`.
     Outdated versions are fine — step 6 handles upgrades.
   - **drift** — some declared entries are absent from `brew list` but
     brew is populated (user ran `brew uninstall foo`, or a prior run
     crashed). Step 3 prints the pending-removal list before step 4 so
     unintentional losses can be caught with Ctrl-C.
   - **bootstrap** — brew is (near-)empty vs the Brewfile (fresh
     machine). Gated by `installed_count < brewfile_entries / 2`.
4. `brew bundle dump --describe --force` in **steady + drift** — both
   directions of change flow through (ad-hoc installs AND uninstalls
   end up reflected in the Brewfile). Skipped in bootstrap so a fresh
   machine doesn't overwrite the canonical Brewfile.
5. `brew update`.
6. `brew upgrade --greedy` — **tolerant** (`|| true`); individual cask
   failures do not abort the run.
7. `brew bundle install` — upgrade-by-default; reconciles toward the
   Brewfile, re-installing anything step 6 silently dropped. Doubles as
   the install step on a fresh machine.
8. `brew cleanup` + emoji summary.

### Known limitation: pkg-shaped auto-updating casks

Four casks in the current Brewfile are `.pkg` installers with
`auto_updates: true`:

| Cask                 | Artifact | Failure mode under `--greedy`          |
| -------------------- | -------- | -------------------------------------- |
| `karabiner-elements` | pkg      | uninstall stanza runs; reinstall needs |
| `nordvpn`            | pkg      | sudo/TTY and can fail non-interactively |
| `xquartz`            | pkg      | — app vanishes until recovered.         |
| `zoom`               | pkg      |                                        |

The script's step 7 (`brew bundle install`) fresh-installs whatever step
6 dropped. After a failed greedy cycle, the cask is reinstalled at the
version Homebrew-cask currently tracks; the app then self-updates to
truly-latest on next launch. This is the best achievable "brew-originated"
story for these four given their upstream cask definitions.

Add or remove `.pkg` auto-updating casks in the table above whenever the
Brewfile changes (grep `auto_updates true` + `pkg` in `brew info --cask
<name> --json=v2` for any new cask you add).

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

## Dump scope: brew-only

`brew-update` calls `brew bundle dump` with `--formula --cask --tap` so
only brew's native package types land in the Brewfile. Brew's default
dump also covers cargo/npm/go/vscode/uv/flatpak/krew; those are left to
their own setup scripts (e.g. `setup-upgrade-kanata` installs kanata
with `cargo install kanata --features "default,cmd"` — a default
`cargo "kanata"` Brewfile entry would silently reinstall it without the
`cmd` feature and break every leader sequence that shells out).

## Adding and Removing Packages

Brewfile is never edited by hand — state flows *from* brew *to* Brewfile.
Adds and removes are **symmetric**: both propagate through the next
`brew-update` run via the dump step (which runs in steady + drift modes).

- **Add a formula**: `brew install <name>`; next `brew-update` runs in
  steady mode and the dump captures the new entry.
- **Add a cask**: `brew install --cask <name>`; same.
- **Remove a formula/cask**: `brew uninstall [--cask] <name>`; next
  `brew-update` runs in **drift mode** (bundle check fails because the
  entry is declared-but-missing, but brew is populated → not a fresh
  machine). The dump captures the removal and writes a Brewfile without
  it, so step 7 (`brew bundle install`) has nothing to reinstall.
- **Verify the pending change before the run** (optional):
  `just update_brewfile` performs only the dump; inspect
  `git diff config/brew/Brewfile` before running `bu`.
- Intentional pruning of entries installed outside the Brewfile:
  `brew bundle cleanup --file=config/brew/Brewfile --force` (manual;
  not part of the canonical pipeline). Use this only when you want
  brew to *remove* packages that exist on the machine but are missing
  from the Brewfile — e.g., if you previously hand-edited the Brewfile
  to drop an entry but never ran `brew uninstall`.

## Development Notes

- Canonical upgrade entry point: `config/bin/brew-update`.
- Manual Brewfile refresh (without upgrade pass): `just update_brewfile`.
- Install from Brewfile (without upgrade or cleanup):
  `brew bundle --file=config/brew/Brewfile`.
- Homebrew init handled by `scripts/setup-upgrade-homebrew`.
- Brew env vars set in zsh `01-z1-env-vars-gen.zsh`:
  `HOMEBREW_UPGRADE_GREEDY=1`, `HOMEBREW_NO_ANALYTICS=1`,
  `HOMEBREW_NO_ENV_HINTS=1`. `HOMEBREW_AUTOREMOVE=1` is not set —
  autoremove is the default; setting it emits a deprecation warning.
