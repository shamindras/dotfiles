-- {{{ Theme Families Configuration & Data Structures -----------------------------------------------

-- Theme Family Definitions
local theme_families = {
  basic = {
    eldritch = {
      plugin = 'eldritch-theme/eldritch.nvim',
      scheme = 'eldritch',
      name = 'Eldritch',
    },
    tokyonight = {
      plugin = 'folke/tokyonight.nvim',
      scheme = 'tokyonight-night',
      name = 'Tokyo Night',
    },
    jellybeans = {
      plugin = 'metalelf0/jellybeans-nvim',
      scheme = 'jellybeans-nvim',
      name = 'Jellybeans',
    },
  },

  rosepine = {
    plugin = 'rose-pine/neovim',
    variants = {
      main = {
        scheme = 'rose-pine',
        name = 'Rose Pine',
      },
      moon = {
        scheme = 'rose-pine-moon',
        name = 'Rose Pine Moon',
      },
      dawn = {
        scheme = 'rose-pine-dawn',
        name = 'Rose Pine Dawn',
      },
    },
  },

  nightfox = {
    plugin = 'EdenEast/nightfox.nvim',
    variants = {
      night = {
        scheme = 'nightfox',
        name = 'Nightfox',
      },
      day = {
        scheme = 'dayfox',
        name = 'Dayfox',
      },
      dawn = {
        scheme = 'dawnfox',
        name = 'Dawnfox',
      },
      dusk = {
        scheme = 'duskfox',
        name = 'Duskfox',
      },
      nord = {
        scheme = 'nordfox',
        name = 'Nordfox',
      },
      tera = {
        scheme = 'terafox',
        name = 'Terafox',
      },
      carbon = {
        scheme = 'carbonfox',
        name = 'Carbonfox',
      },
    },
  },

  catppuccin = {
    plugin = 'catppuccin/nvim',
    variants = {
      mocha = {
        scheme = 'catppuccin-mocha',
        name = 'Catppuccin Mocha',
      },
      macchiato = {
        scheme = 'catppuccin-macchiato',
        name = 'Catppuccin Macchiato',
      },
      frappe = {
        scheme = 'catppuccin-frappe',
        name = 'Catppuccin Frappe',
      },
      latte = {
        scheme = 'catppuccin-latte',
        name = 'Catppuccin Latte',
      },
    },
  },
}

-- Theme Data Processing
-- Flatten theme families into a lookup table for easy access
local colorschemes = {}
local color_scheme_order = {}

-- Add basic themes
for name, config in pairs(theme_families.basic) do
  colorschemes[name] = config
  table.insert(color_scheme_order, name)
end

-- Add variant themes
for family, family_config in pairs(theme_families) do
  if family ~= 'basic' and family_config.variants then
    for variant, variant_config in pairs(family_config.variants) do
      local scheme_key = family .. '_' .. variant
      colorschemes[scheme_key] = {
        plugin = family_config.plugin,
        scheme = variant_config.scheme,
        name = variant_config.name,
      }
      table.insert(color_scheme_order, scheme_key)
    end
  end
end

-- }}}

-- {{{ State Management Functions -----------------------------------------------------------------

-- Function to get the state file path
local function get_state_file()
  return vim.fn.stdpath('state') .. '/colorscheme_state.txt'
end

-- Function to save current colorscheme
local function save_colorscheme(scheme_name)
  local file = io.open(get_state_file(), 'w')
  if file then
    file:write(scheme_name)
    file:close()
  end
end

-- Function to load last used colorscheme
local function get_last_colorscheme()
  local file = io.open(get_state_file(), 'r')
  if file then
    local scheme = file:read('*all')
    file:close()
    -- Verify the scheme exists in our list
    for i, name in ipairs(color_scheme_order) do
      if name == scheme then
        return scheme, i
      end
    end
  end
  return 'eldritch', 1 -- fallback to eldritch
end

-- Initialize current scheme from saved state
local initial_scheme, initial_index = get_last_colorscheme()
local current_scheme_index = initial_index

-- }}}

-- {{{ Colorscheme Loading Functions ------------------------------------------------------------

local function load_colorscheme(scheme)
  local config = colorschemes[scheme]

  if not config then
    print('Unknown colorscheme: ' .. scheme)
    return
  end

  -- Protected call to load the colorscheme
  local ok, err = pcall(vim.cmd.colorscheme, config.scheme)
  if not ok then
    vim.notify('Failed to load colorscheme ' .. config.scheme .. ': ' .. err, vim.log.levels.ERROR)
    return
  end

  -- Save the successfully loaded colorscheme
  save_colorscheme(scheme)

  -- Print the theme name if available
  if config.name then
    print('Switched to ' .. config.name)
  end

  -- Common settings for all themes
  vim.cmd.hi('Comment gui=none')
  vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'None', fg = 'white' })
end

-- Make the cycle functions globally accessible
_G.cycle_colorscheme_forward = function()
  -- Move to the next scheme in the list
  current_scheme_index = (current_scheme_index % #color_scheme_order) + 1
  local next_scheme = color_scheme_order[current_scheme_index]
  load_colorscheme(next_scheme)
end

_G.cycle_colorscheme_backward = function()
  -- Move to the previous scheme in the list
  current_scheme_index = current_scheme_index - 1
  if current_scheme_index < 1 then
    current_scheme_index = #color_scheme_order
  end
  local prev_scheme = color_scheme_order[current_scheme_index]
  load_colorscheme(prev_scheme)
end

-- }}}

-- {{{ Plugin Specifications -------------------------------------------------------------------

-- Helper function for family scheme detection
local function is_family_scheme(family, scheme)
  return string.match(scheme or '', '^' .. family .. '_') ~= nil
end

return {
  -- Lush plugin (required for jellybeans)
  {
    'rktjmp/lush.nvim',
    lazy = true,
    priority = 1000,
  },

  -- Basic theme plugins
  {
    'eldritch-theme/eldritch.nvim',
    event = initial_scheme == 'eldritch' and 'VimEnter' or nil,
    priority = 1000,
    config = function()
      if initial_scheme == 'eldritch' then
        vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
      end
    end,
  },

  {
    'folke/tokyonight.nvim',
    event = initial_scheme == 'tokyonight' and 'VimEnter' or nil,
    priority = 1000,
    config = function()
      if initial_scheme == 'tokyonight' then
        vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
      end
    end,
  },

  {
    'metalelf0/jellybeans-nvim',
    dependencies = { 'rktjmp/lush.nvim' },
    event = initial_scheme == 'jellybeans' and 'VimEnter' or nil,
    priority = 1000,
    config = function()
      if initial_scheme == 'jellybeans' then
        vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
      end
    end,
  },

  -- Rose Pine theme plugin
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    event = is_family_scheme('rosepine', initial_scheme) and 'VimEnter' or nil,
    priority = 1000,
    config = function()
      if is_family_scheme('rosepine', initial_scheme) then
        require('rose-pine').setup({
          variant = 'auto',
          dark_variant = 'main',
          dim_inactive_windows = false,
          extend_background_behind_borders = true,

          enable = {
            terminal = true,
            legacy_highlights = true,
            migrations = true,
          },

          styles = {
            bold = true,
            italic = true,
            transparency = false,
          },

          groups = {
            border = 'muted',
            link = 'iris',
            panel = 'surface',

            error = 'love',
            hint = 'iris',
            info = 'foam',
            note = 'pine',
            todo = 'rose',
            warn = 'gold',

            git_add = 'foam',
            git_change = 'rose',
            git_delete = 'love',
            git_dirty = 'rose',
            git_ignore = 'muted',
            git_merge = 'iris',
            git_rename = 'pine',
            git_stage = 'iris',
            git_text = 'rose',
            git_untracked = 'subtle',

            h1 = 'iris',
            h2 = 'foam',
            h3 = 'rose',
            h4 = 'gold',
            h5 = 'pine',
            h6 = 'foam',
          },

          highlight_groups = {},
          palette = {},
          before_highlight = function() end,
        })
        vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
      end
    end,
  },

  -- Nightfox theme plugin
  {
    'EdenEast/nightfox.nvim',
    event = is_family_scheme('nightfox', initial_scheme) and 'VimEnter' or nil,
    priority = 1000,
    config = function()
      if is_family_scheme('nightfox', initial_scheme) then
        require('nightfox').setup({})
        vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
      end
    end,
  },

  -- Catppuccin theme plugin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    event = is_family_scheme('catppuccin', initial_scheme) and 'VimEnter' or nil,
    priority = 1000,
    config = function()
      if is_family_scheme('catppuccin', initial_scheme) then
        local variant = string.match(initial_scheme, '_(%w+)$')
        require('catppuccin').setup({
          flavour = variant,
        })
        vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
      end
    end,
  },

  -- Set up keymaps for cycling colorschemes
  {
    'eldritch-theme/eldritch.nvim',
    keys = {
      {
        '<leader>cf',
        function()
          _G.cycle_colorscheme_forward()
        end,
        desc = 'Cycle colorscheme forward',
      },
      {
        '<leader>cb',
        function()
          _G.cycle_colorscheme_backward()
        end,
        desc = 'Cycle colorscheme backward',
      },
    },
  },
}

-- }}}
