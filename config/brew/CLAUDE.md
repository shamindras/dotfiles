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

## Development Notes

- Update Brewfile from current packages: `just update_brewfile`
- Install from Brewfile: `brew bundle --file=config/brew/Brewfile`
- Homebrew init handled by `scripts/setup-upgrade-homebrew`
- Brew env vars (prefix, analytics) set in zsh `01-z1-env-vars-gen.zsh`
