# Lua Conventions

Shared conventions for all Lua-based configs (wezterm, nvim, sketchybar).

## Formatting (stylua)

Settings from `config/stylua/.stylua.toml`:

| Setting        | Value               |
| -------------- | ------------------- |
| Column width   | 120                 |
| Line endings   | Unix                |
| Indent type    | Spaces              |
| Indent width   | 2                   |
| Quote style    | AutoPreferSingle    |
| Call parentheses | Always            |

Run with: `just stylua_config`

## Fold Markers (Neovim `foldmethod=marker`)

Every Lua file uses fold markers so Neovim can collapse sections.

**Syntax:**
- Open: `-- {{{ Descriptive Label`
- Close: `-- ------------------------------------------------------------------------- }}}`
  (73-char dashed line before `}}}`)

**Rules:**
- Every open must have a matching close
- Sections follow logical order: Boilerplate → Config → Logic → Export

**Good example:**
```lua
-- {{{ Boilerplate & Helpers
local M = {}
local wezterm = require('wezterm')
-- ------------------------------------------------------------------------- }}}

-- {{{ Configuration
local active = { ... }
-- ------------------------------------------------------------------------- }}}

-- {{{ Main Setup Logic
function M.setup(config)
  return config
end
-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export
return M
-- ------------------------------------------------------------------------- }}}
```

**Bad patterns:**
- Missing markers (flat top-level code with no folds)
- Opening a new fold without closing the previous one
- Using `-- }}}` without the dashed separator line

## Module Pattern

- Each module exports `M.setup(config)`, mutates and returns config
- Main entry point chains `.setup(config)` calls
- Export `return M` at bottom of file
