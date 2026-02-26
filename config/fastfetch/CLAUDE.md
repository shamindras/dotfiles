# Fastfetch Configuration

- **Docs**: https://github.com/fastfetch-cli/fastfetch
- **Installed version**: fastfetch 2.59.0 (verified 2026-02-26)

## File Structure

| File           | Purpose                     |
| -------------- | --------------------------- |
| `config.jsonc` | Module list and display     |

## Key Settings

- **32 modules**: OS, host, kernel, uptime, packages, shell, display,
  DE, WM, CPU, GPU, memory, disk, battery, and more
- **Format**: JSONC (JSON with comments)
- **Schema**: available for IDE validation

## Development Notes

- Used by zsh `ffc` function (fastfetch + clipboard)
- Pure module-list config — no custom formatting
