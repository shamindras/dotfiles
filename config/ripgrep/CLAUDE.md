# ripgrep Configuration

- **Docs**: https://github.com/BurntSushi/ripgrep
- **Installed version**: ripgrep 15.1.0 (verified 2026-02-26)

## File Structure

| File        | Purpose                        |
| ----------- | ------------------------------ |
| `ripgreprc` | Runtime flags and settings     |

## Key Settings

- **Max columns**: 150 with preview
- **Hidden files**: enabled by default
- **Smart case**: enabled
- **Exclude**: `.git/*`, `submods/*`
- **Line color**: custom styling

## Development Notes

- Used by nvim (snacks/pickers.lua), fzf, and zsh global alias `G`
- Config path set via `RIPGREP_CONFIG_PATH` in zsh env
