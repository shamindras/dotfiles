# Taskwarrior Configuration

- **Docs**: https://taskwarrior.org/docs/
- **Installed version**: task 3.4.2 (verified 2026-02-26)

## File Structure

| File       | Purpose                                |
| ---------- | -------------------------------------- |
| `taskrc`   | Main config (contexts, aliases, theme) |
| `themes/`  | 11 theme files (solarized, dark, light)|

## Key Settings

- **Data location**: `~/.local/share/task` (XDG)
- **Contexts**: 10+ (reading, ai, math, blog, home, work, etc.)
- **Aliases**: quick context switching
- **Theme files**: multiple options in `themes/`

## Development Notes

- Contexts are domain-specific; extend by adding new context definitions
