# btop Configuration

- **Docs**: https://github.com/aristocratos/btop
- **Installed version**: btop 1.4.6 (verified 2026-02-26)

## File Structure

| File          | Purpose                              |
| ------------- | ------------------------------------ |
| `btop.conf`   | Main config (~234 lines)             |
| `themes/`     | Custom themes (linkarzu-btop active) |

## Key Settings

- **Color theme**: `linkarzu-btop.theme`
- **Background**: disabled (transparency)
- **Vim keys**: enabled (hjkl navigation)
- **CPU graph**: braille symbols
- **Process sorting**: by memory, tree mode off
- **Truecolor**: enabled

## Theme Management

btop ships built-in themes at `/opt/homebrew/share/btop/themes/`. Custom
themes go in `config/btop/themes/`.

- **Set theme**: edit `color_theme` in `btop.conf` (filename without path
  for custom themes, or full path for built-in)
- **Add custom theme**: place `.theme` file in `config/btop/themes/`
- **List built-in**: `ls /opt/homebrew/share/btop/themes/`

## Development Notes

- Config is mutated by runtime UI interactions — btop rewrites `btop.conf`
  on changes (unlike bottom). Use bottom (`btm`) for VCS-safe monitoring.
