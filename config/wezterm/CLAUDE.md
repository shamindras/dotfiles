# WezTerm Configuration

## Overview
WezTerm terminal emulator config using Lua. Modular architecture with
registry-based theme/font selection.

Docs: https://wezfurlong.org/wezterm/config/files.html

## Architecture

### Files
- `wezterm.lua` — Entry point. Chains module `.setup(config)` calls.
- `utils/appearance.lua` — Fonts, themes, opacity, window decorations.
  Contains `active` registry table and `font_library`/`theme_library` lookups.
- `utils/core.lua` — Shell, PATH (for direct command spawns), pane behavior.
- `utils/keybindings.lua` — All key/mouse bindings. Contains vim-aware
  `nav_key()` helper for Neovim-compatible pane navigation.

### Key Patterns
- **Module pattern**: Each module exports `M.setup(config)`, mutates and
  returns config. Main file chains them.
- **Registry pattern** (appearance.lua): The `active` table is the single
  source of truth. Libraries below define options. To change theme/font,
  edit ONLY the `active` table.
- **Vim-aware navigation**: `nav_key()` checks `IS_NVIM` user var to
  decide whether to forward keys to Neovim or handle natively.
- **Dark/light detection**: `depending_on_appearance()` handles both string
  and boolean API returns from `wezterm.gui.get_appearance()`.

### Conventions

#### Fold markers (Neovim `foldmethod=marker`)

Every Lua file uses `-- {{{ Label` / `-- ---...--- }}}` pairs so Neovim
can collapse sections. Preserve this structure when adding or moving code.

**Good** (from `utils/appearance.lua`):
```lua
-- {{{ Boilerplate & Helpers

local M = {}
local wezterm = require('wezterm')

local function depending_on_appearance(arg)
  -- ...
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Configuration Registry

local active = { ... }
local font_library = { ... }
local theme_library = { ... }

-- ------------------------------------------------------------------------- }}}

-- {{{ Main Setup Logic

function M.setup(config)
  -- ...
  return config
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return M

-- ------------------------------------------------------------------------- }}}
```

**Bad** — missing markers, or markers that don't match:
```lua
-- DON'T: dump everything at top level with no fold structure
local M = {}
local wezterm = require('wezterm')
local function depending_on_appearance(arg) ... end
local active = { ... }
function M.setup(config) ... end
return M

-- DON'T: use only opening markers without closing
-- {{{ Helpers
local function foo() end
-- {{{ Setup        <-- opens a new fold without closing the previous one

-- DON'T: use non-standard closing syntax
-- {{{ Helpers
local function foo() end
-- }}}              <-- missing the dashed separator line
```

Rules:
- Open: `-- {{{ Descriptive Label`
- Close: `-- ------------------------------------------------------------------------- }}}`
  (73-char dashed line before `}}}`)
- Every open must have a matching close
- Sections should follow a logical order: Boilerplate → Config → Logic → Export

#### Other conventions
- Formatting: stylua (2-space indent, single quotes)
- Tab bar: intentionally disabled
- Modifier convention: CMD for primary actions, CMD+SHIFT for secondary

## Development Notes
- Changes apply on save (no restart needed)
- Debug with `wezterm.log_info()`, view in debug overlay (CTRL+SHIFT+L)
- Format with: `just stylua_config`
- Test in isolation: `wezterm --config-file /path/to/wezterm.lua`
