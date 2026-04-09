-- {{{ Colorscheme Configuration
--
-- Generates lazy.nvim plugin specs from the theme registry (util/themes.lua).
-- Only the active theme's plugin loads eagerly; all others are lazy until cycled to.
-- Multiple variants of the same plugin produce one deduplicated spec.
-- State persists to ~/.local/state/nvim/colorscheme_state.txt (XDG-compliant).

local themes = require('shamindras.util.themes')

-- }}}

-- {{{ State Management

local function get_state_file()
  return vim.fn.stdpath('state') .. '/colorscheme_state.txt'
end

local function save_colorscheme(key)
  local file = io.open(get_state_file(), 'w')
  if file then
    file:write(key)
    file:close()
  end
end

-- Returns (key, index) of the active theme from saved state, or default.
local function get_active_theme()
  local file = io.open(get_state_file(), 'r')
  if file then
    local key = file:read('*all')
    file:close()
    for i, name in ipairs(themes.order) do
      if name == key then
        return key, i
      end
    end
  end
  -- Fallback: find the default in the order list
  for i, name in ipairs(themes.order) do
    if name == themes.default then
      return themes.default, i
    end
  end
  return themes.default, 1
end

local active_key, current_index = get_active_theme()

-- }}}

-- {{{ Colorscheme Loading

local function load_colorscheme(key)
  local theme = themes.themes[key]
  if not theme then
    vim.notify('Unknown colorscheme: ' .. key, vim.log.levels.ERROR)
    return
  end

  -- Ensure lazy plugin is loaded
  local short_name = theme.plugin:match('[^/]+$')
  require('lazy').load({ plugins = { short_name } })

  -- Apply colorscheme
  local ok, err = pcall(vim.cmd.colorscheme, theme.scheme)
  if not ok then
    vim.notify('Failed to load colorscheme ' .. theme.scheme .. ': ' .. err, vim.log.levels.ERROR)
    return
  end

  -- Track intended scheme so ColorScheme guard can revert unauthorized resets
  vim.g._colorscheme_intended = theme.scheme

  save_colorscheme(key)
  vim.cmd.hi('Comment gui=none')

  -- Set render-markdown code highlight early (before plugin re-caches derived highlights)
  if theme.code_palette then
    vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = theme.code_palette.bg })
  end
end

-- Cycle to the next theme in order
local function cycle_colorscheme()
  current_index = (current_index % #themes.order) + 1
  local next_key = themes.order[current_index]
  load_colorscheme(next_key)
end

-- Guard against unauthorized colorscheme resets (e.g., OSC 11 background detection
-- after tmux session switch). Any colorscheme change that doesn't match the intended
-- scheme is immediately reverted. Uses vim.schedule to avoid recursion.
local restoring_colorscheme = false
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('ColorschemeGuard', { clear = true }),
  callback = function()
    if restoring_colorscheme then
      return
    end
    local intended = vim.g._colorscheme_intended
    if not intended or vim.g.colors_name == intended then
      return
    end
    restoring_colorscheme = true
    vim.schedule(function()
      pcall(vim.cmd.colorscheme, intended)
      vim.cmd.hi('Comment gui=none')
      restoring_colorscheme = false
    end)
  end,
})

-- }}}

-- {{{ Spec Generation

-- Deduplicate: one lazy.nvim spec per plugin, not per variant.
-- The active variant's plugin is eager; all other plugins are lazy.
local function generate_specs()
  local specs = {}
  local seen = {}
  local active_theme = themes.themes[active_key]
  local active_plugin = active_theme.plugin

  for _, key in ipairs(themes.order) do
    local theme = themes.themes[key]
    if not seen[theme.plugin] then
      seen[theme.plugin] = true

      local spec = { theme.plugin }
      local is_active_plugin = (theme.plugin == active_plugin)

      if is_active_plugin then
        spec.lazy = false
        spec.priority = 1000
        spec.init = function()
          vim.cmd.colorscheme(active_theme.scheme)
          vim.g._colorscheme_intended = active_theme.scheme
          -- Set render-markdown code highlight early (before plugin caches derived highlights)
          if active_theme.code_palette then
            vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = active_theme.code_palette.bg })
          end
        end
      else
        spec.lazy = true
      end

      if theme.setup and theme.mod then
        spec.config = function()
          require(theme.mod).setup(theme.setup)
        end
      end

      specs[#specs + 1] = spec
    end
  end

  -- Attach cycle keymap to the active plugin's spec
  specs[#specs + 1] = {
    active_plugin,
    keys = {
      {
        '<leader>tc',
        cycle_colorscheme,
        desc = '[t]oggle [c]olorscheme cycle',
      },
    },
  }

  return specs
end

-- }}}

return generate_specs()
