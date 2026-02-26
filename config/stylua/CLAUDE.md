# StyLua Configuration

- **Docs**: https://github.com/JohnnyMorganz/StyLua
- **Installed version**: stylua 2.3.1 (verified 2026-02-26)

## File Structure

| File            | Purpose                   |
| --------------- | ------------------------- |
| `.stylua.toml`  | Formatter settings        |

## Key Settings

- **Column width**: 120
- **Line endings**: Unix
- **Indent**: 2 spaces
- **Quote style**: AutoPreferSingle
- **Call parentheses**: Always

## Development Notes

- Run: `just stylua_config` (formats all Lua configs)
- Full conventions: `.claude/conventions/lua.md`
- Used by nvim conform.nvim for Lua format-on-save
