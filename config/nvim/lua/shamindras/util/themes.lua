-- {{{ Theme Registry
--
-- Single source of truth for all colorscheme data. Both plugins/colorscheme.lua
-- (spec generation, cycling) and ftplugin/markdown.lua (heading palettes)
-- import from this module.
--
-- To add a variant: add an entry to the relevant `variants` table and include
-- its key in M.order. To add a new plugin family: add a `plugins` entry, a
-- `variants` block, and wire into M.order.

local M = {}

M.default = 'eldritch'

-- Centralized separator / border / inactive-statusline fg.
-- Per-theme `separator_fg` (inside each variant) overrides these when set.
-- Tweak these two values to re-tune separator brightness globally.
M.SEPARATOR_DARK_FG = '#a5adbf'
M.SEPARATOR_LIGHT_FG = '#4b5563'

-- Cycle/display order: dark-to-light gradient
M.order = {
  'eldritch',
  'teide-dark',
  'teide-dimmed',
  'catppuccin-mocha',
  'catppuccin-macchiato',
  'nightfox',
  'terafox',
  'dracula',
  'cyberdream',
  'tokyonight-night',
  'catppuccin-latte',
  'dayfox',
  'teide-light',
}

-- }}}

-- {{{ Plugin Configurations

local plugins = {
  eldritch = {
    plugin = 'eldritch-theme/eldritch.nvim',
    mod = 'eldritch',
    setup = {
      styles = { sidebars = 'dark', floats = 'dark' },
    },
  },
  tokyonight = {
    plugin = 'folke/tokyonight.nvim',
    mod = 'tokyonight',
  },
  catppuccin = {
    plugin = 'catppuccin/nvim',
    mod = 'catppuccin',
  },
  nightfox = {
    plugin = 'EdenEast/nightfox.nvim',
    mod = 'nightfox',
    setup = {
      options = {
        styles = { comments = 'italic', keywords = 'italic' },
      },
    },
  },
  teide = {
    plugin = 'serhez/teide.nvim',
    mod = 'teide',
  },
  cyberdream = {
    plugin = 'scottmckendry/cyberdream.nvim',
    mod = 'cyberdream',
    setup = {
      italic_comments = true,
    },
  },
  dracula = {
    plugin = 'Mofiqul/dracula.nvim',
    mod = 'dracula',
    setup = {
      italic_comment = true,
    },
  },
}

-- }}}

-- {{{ Variant Definitions

-- Helper: merge shared plugin config with variant-specific fields
local function variant(base, fields)
  local t = {}
  for k, v in pairs(base) do
    t[k] = v
  end
  for k, v in pairs(fields) do
    t[k] = v
  end
  return t
end

-- stylua: ignore start
M.themes = {
  -- Dark themes
  eldritch = variant(plugins.eldritch, {
    scheme = 'eldritch',
    background = 'dark',
    heading_palette = {
      bg = { '#987afb', '#37f499', '#04d1f9', '#fca6ff', '#9ad900', '#e58f2a' },
      fg = '#0D1116',
    },
    code_palette = { bg = '#1a1a2e' },
  }),

  ['tokyonight-night'] = variant(plugins.tokyonight, {
    scheme = 'tokyonight-night',
    background = 'dark',
    heading_palette = {
      bg = { '#bb9af7', '#7aa2f7', '#7dcfff', '#9ece6a', '#ff9e64', '#e0af68' },
      fg = '#1a1b26',
    },
    code_palette = { bg = '#1a1a2a' },
  }),

  ['catppuccin-mocha'] = variant(plugins.catppuccin, {
    scheme = 'catppuccin-mocha',
    background = 'dark',
    heading_palette = {
      bg = { '#cba6f7', '#89b4fa', '#74c7ec', '#a6e3a1', '#fab387', '#f9e2af' },
      fg = '#1e1e2e',
    },
    code_palette = { bg = '#252536' },
  }),

  cyberdream = variant(plugins.cyberdream, {
    scheme = 'cyberdream',
    background = 'dark',
    heading_palette = {
      bg = { '#ff5ef1', '#5ea1ff', '#5ef1ff', '#5eff6c', '#ffbd5e', '#f1ff5e' },
      fg = '#16181a',
    },
    code_palette = { bg = '#1e2124' },
  }),

  nightfox = variant(plugins.nightfox, {
    scheme = 'nightfox',
    background = 'dark',
    heading_palette = {
      bg = { '#9d79d6', '#719cd6', '#63cdcf', '#81b29a', '#f4a261', '#dbc074' },
      fg = '#192330',
    },
    code_palette = { bg = '#212e3f' },
  }),

  terafox = variant(plugins.nightfox, {
    scheme = 'terafox',
    background = 'dark',
    heading_palette = {
      bg = { '#ad5c7c', '#5a93aa', '#a1cdd8', '#7aa4a1', '#ff8349', '#fda47f' },
      fg = '#152528',
    },
    code_palette = { bg = '#1d3337' },
  }),

  dracula = variant(plugins.dracula, {
    scheme = 'dracula',
    background = 'dark',
    heading_palette = {
      bg = { '#BD93F9', '#50FA7B', '#8BE9FD', '#FF79C6', '#FFB86C', '#F1FA8C' },
      fg = '#282A36',
    },
    code_palette = { bg = '#2d2f3d' },
  }),

  ['teide-dark'] = variant(plugins.teide, {
    scheme = 'teide-dark',
    background = 'dark',
    heading_palette = {
      bg = { '#FFB3EC', '#5CCEFF', '#0AE7FF', '#38FFA5', '#FFA064', '#FFE77A' },
      fg = '#1D2228',
    },
    code_palette = { bg = '#2C313A' },
  }),

  ['teide-dimmed'] = variant(plugins.teide, {
    scheme = 'teide-dimmed',
    background = 'dark',
    heading_palette = {
      bg = { '#A592FF', '#5CCEFF', '#38FFA5', '#FFE77A', '#FFA064', '#F97791' },
      fg = '#1e2228',
    },
    code_palette = { bg = '#282e36' },
  }),

  -- Medium themes
  ['catppuccin-macchiato'] = variant(plugins.catppuccin, {
    scheme = 'catppuccin-macchiato',
    background = 'dark',
    heading_palette = {
      bg = { '#c6a0f6', '#8aadf4', '#7dc4e4', '#a6da95', '#f5a97f', '#eed49f' },
      fg = '#24273a',
    },
    code_palette = { bg = '#363a4f' },
  }),

  -- Light themes
  ['catppuccin-latte'] = variant(plugins.catppuccin, {
    scheme = 'catppuccin-latte',
    background = 'light',
    heading_palette = {
      bg = { '#8839ef', '#1e66f5', '#209fb5', '#40a02b', '#fe640b', '#df8e1d' },
      fg = '#eff1f5',
    },
    code_palette = { bg = '#ccd0da' },
  }),

  dayfox = variant(plugins.nightfox, {
    scheme = 'dayfox',
    background = 'light',
    heading_palette = {
      bg = { '#6e33ce', '#2848a9', '#287980', '#396847', '#955f61', '#AC5402' },
      fg = '#f6f2ee',
    },
    code_palette = { bg = '#dbd1dd' },
  }),

  ['teide-light'] = variant(plugins.teide, {
    scheme = 'teide-light',
    background = 'light',
    heading_palette = {
      bg = { '#7A00B3', '#005FAA', '#007A8A', '#006B3A', '#A04000', '#8A6000' },
      fg = '#E1DDD2',
    },
    code_palette = { bg = '#D4D0C5' },
  }),
}
-- stylua: ignore end

-- }}}

-- {{{ Reverse Lookup

-- Map vim.g.colors_name → registry key (e.g. 'catppuccin-mocha' → 'catppuccin-mocha')
M.scheme_to_key = {}
for key, theme in pairs(M.themes) do
  M.scheme_to_key[theme.scheme] = key
end

-- }}}

-- {{{ Helpers

-- Resolve the effective separator fg for a theme key.
-- Precedence: explicit theme.separator_fg > background-based global > white fallback.
function M.resolve_separator_fg(key)
  local theme = M.themes[key]
  if not theme then
    return 'white'
  end
  if theme.separator_fg then
    return theme.separator_fg
  end
  if theme.background == 'light' then
    return M.SEPARATOR_LIGHT_FG
  end
  return M.SEPARATOR_DARK_FG
end

-- }}}

return M
