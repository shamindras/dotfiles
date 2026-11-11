# npm Configuration

- **Docs**: https://docs.npmjs.com/cli/
- **Installed version**: npm 11.9.0 (verified 2026-02-26)

## File Structure

| File    | Purpose                          |
| ------- | -------------------------------- |
| `npmrc` | Runtime settings (prefix, cache) |

## Key Settings

- **Prefix**: `$N_PREFIX` (set via environment)
- **Cache**: `$XDG_CACHE_HOME/npm`
- **Init module**: `$XDG_CONFIG_HOME/npm/config/npm-init.js`

## Development Notes

- XDG-compliant; relies on env vars set in zsh `00-z1-env-vars-xdg.zsh`
- No global npm packages: eslint_d and prettier come from Homebrew (`lint` module in `manifest.json`). `N_PREFIX` is exported in `.zshenv`, so the `prefix` here also resolves in scripts and non-interactive shells
