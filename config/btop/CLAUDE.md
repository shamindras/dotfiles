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

## Development Notes

- Config is mutated by runtime UI interactions — btop rewrites `btop.conf`
  on changes (unlike bottom). Use bottom (`btm`) for VCS-safe monitoring.
