# Homebrew Configuration

- **Docs**: https://brew.sh/
- **Installed version**: N/A (check via `brew --version`)

## File Structure

| File       | Purpose                                 |
| ---------- | --------------------------------------- |
| `Brewfile` | Package manifest (100+ formulas/casks)  |

## Key Settings

- **Taps**: felixkratz/formulae, nikitabobko/tap
- **Formulas**: 100+ CLI tools and libraries
- **Casks**: GUI apps (aerospace, karabiner, wezterm, etc.)

## Greedy Upgrades for Auto-Updating Casks

Casks with `auto_updates true` (Signal, Firefox, Chrome, Slack, etc.) are
skipped by plain `brew upgrade`. Three mechanisms ensure they get upgraded:

| Context               | Mechanism                                                    |
| --------------------- | ------------------------------------------------------------ |
| `./install` (dotbot)  | `brew upgrade --greedy` in `install.conf.yaml`        |
| `bu` alias            | `brew upgrade --greedy` in alias definition              |
| Leader Key `r b`      | `brew upgrade --greedy` in `leader-key/config.json`   |
| Manual `brew upgrade` | `HOMEBREW_UPGRADE_GREEDY=1` env var (full greedy)     |

- `--greedy` upgrades both `auto_updates true` and `version :latest` casks
- `HOMEBREW_UPGRADE_GREEDY=1` maps to full `--greedy` — the explicit flag
  is kept in dotbot and leader-key as a belt-and-suspenders safeguard
- The dotbot `./install` script runs under bash and does NOT source zsh
  config, so the explicit flag is needed there

## Adding and Removing Packages

Always modify the live brew state first, then regenerate the Brewfile.
Never edit the Brewfile directly.

- **Add a formula**: `brew install <name>` then `just update_brewfile`
- **Add a cask**: `brew install --cask <name>` then `just update_brewfile`
- **Remove a formula**: `brew uninstall <name>` then `just update_brewfile`
- **Remove a cask**: `brew uninstall --cask <name>` then `just update_brewfile`

## Development Notes

- Update Brewfile from current packages: `just update_brewfile`
- Install from Brewfile: `brew bundle --file=config/brew/Brewfile`
- Homebrew init handled by `scripts/setup-upgrade-homebrew`
- Brew env vars (prefix, analytics, greedy) set in zsh `01-z1-env-vars-gen.zsh`
