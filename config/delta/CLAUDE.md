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

## Development Notes

- Active theme set in `config/git/config` under `[delta]` section
- Also used by **lazygit** and **gh-dash** as pager
