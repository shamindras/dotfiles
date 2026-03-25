# bat Configuration

- **Docs**: https://github.com/sharkdp/bat
- **Installed version**: bat 0.26.1 (verified 2026-02-26)

## File Structure

| File     | Purpose                             |
| -------- | ----------------------------------- |
| `config` | Runtime flags (theme, style, pager) |

## Key Settings

- **Theme**: `Catppuccin Mocha` (built-in)
- **Style**: `grid,numbers` (line numbers + grid)
- **Pager**: `less -FRS` with italic support

## Theme Management

bat ships built-in themes — no vendored files needed.

- **List themes**: `bat --list-themes`
- **Set theme**: edit `--theme="<name>"` in `config`
- **Rebuild cache**: `bat cache --build` (only needed if adding custom
  `.tmTheme` files to `~/.config/bat/themes/`)

## Development Notes

- Used as pager by **gh**, **fzf** (Ctrl-T preview), and **zk**
