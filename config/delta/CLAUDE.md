# delta Configuration

- **Docs**: https://dandavison.github.io/delta/
- **Installed version**: delta 0.18.2 (verified 2026-02-26)

## File Structure

| File               | Purpose                                   |
| ------------------ | ----------------------------------------- |
| `themes.gitconfig` | 27+ color themes (git-includable format)  |

## Key Settings

- **Themes**: catppuccin, tokyonight, gruvbox, and more
- **Line numbers**: enabled in most themes
- **Side-by-side**: supported via `--side-by-side` flag
- **Included by**: `config/git/config` via `[include]` directive

## Theme Management

delta uses a built-in feature system — themes are defined as `[delta "<name>"]`
sections in `themes.gitconfig`, included by git config.

- **Set theme**: edit `features = <name>` under `[delta]` in `config/git/config`
- **List syntax themes**: `delta --list-syntax-themes`
- **Add a theme**: add a new `[delta "<name>"]` section in `themes.gitconfig`

## Development Notes

- Active theme set in `config/git/config` under `[delta]` section
- Also used by **lazygit** and **gh-dash** as pager
