# bat Configuration

- **Docs**: https://github.com/sharkdp/bat
- **Installed version**: bat 0.26.1 (verified 2026-02-26)

## File Structure

| File      | Purpose                                     |
| --------- | ------------------------------------------- |
| `config`  | Runtime flags (theme, style, pager)         |
| `themes/` | Custom .tmTheme files (Catppuccin, Tokyo Night) |

## Key Settings

- **Theme**: `tokyonight_night`
- **Style**: `grid,numbers` (line numbers + grid)
- **Pager**: `less -FRS` with italic support
- Custom theme files in `themes/` — rebuild cache after changes

## Development Notes

- Rebuild theme cache: `bat cache --build`
- Used as pager by **gh**, **fzf** (Ctrl-T preview), and **zk**
