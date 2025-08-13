-- {{{ Colorscheme Configuration -------------------------------------------------------------------

-- Store the cycle function in _G so it's globally accessible
local colorschemes = {
  eldritch = {
    plugin = 'eldritch-theme/eldritch.nvim',
    scheme = 'eldritch',
  },
  tokyonight = {
    plugin = 'folke/tokyonight.nvim',
    scheme = 'tokyonight-night',
  },
  jellybeans = {
    plugin = 'metalelf0/jellybeans-nvim',
    scheme = 'jellybeans-nvim',
  },
}

local color_scheme_order = { 'eldritch', 'tokyonight', 'jellybeans' }

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

-- {{{ Colorscheme Loading Functions -------------------------------------------------------------

local function load_colorscheme(scheme)
  local config = colorschemes[scheme]

  if not config then
    print('Unknown colorscheme: ' .. scheme)
    return
  end

  -- Special handling for eldritch to ensure it's properly configured
  if scheme == 'eldritch' then
    local eldritch_ok, eldritch = pcall(require, 'eldritch')
    if eldritch_ok then
      -- Setup eldritch with default configuration to avoid the nil styles error
      eldritch.setup({
        palette = 'default',
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = 'dark',
          floats = 'dark',
        },
        sidebars = { 'qf', 'help' },
        hide_inactive_statusline = false,
        -- Optional callback functions for color and highlight customization
        on_colors = function(colors)
          -- Override colors here if needed
        end,
        on_highlights = function(highlights, colors)
          -- Override highlight groups here if needed
        end,
      })
    end
  end

  -- Protected call to load the colorscheme
  local ok, err = pcall(vim.cmd.colorscheme, config.scheme)
  if not ok then
    vim.notify('Failed to load colorscheme ' .. config.scheme .. ': ' .. err, vim.log.levels.ERROR)
    return
  end

  -- Save the successfully loaded colorscheme
  save_colorscheme(scheme)

  -- Common settings for all themes
  vim.cmd.hi('Comment gui=none')
end

-- Make the cycle function globally accessible
_G.cycle_colorscheme = function()
  -- Move to the next scheme in the list
  current_scheme_index = (current_scheme_index % #color_scheme_order) + 1
  local next_scheme = color_scheme_order[current_scheme_index]
  load_colorscheme(next_scheme)
end

-- }}}

-- {{{ Plugin Specifications --------------------------------------------------------------------

return {
  -- Lush plugin (required for jellybeans)
  {
    'rktjmp/lush.nvim',
    lazy = true, -- Make lazy since it's only needed for jellybeans
  },

  -- Eldritch colorscheme plugin (initial theme)
  {
    'eldritch-theme/eldritch.nvim',
    priority = 1000,
    lazy = false, -- Ensure it loads immediately
    config = function()
      -- Setup eldritch with proper configuration matching official docs
      require('eldritch').setup({
        palette = 'default', -- Available options: "default" (standard palette), "darker" (darker variant)
        transparent = false, -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = 'dark', -- style for sidebars, see below
          floats = 'dark', -- style for floating windows
        },
        sidebars = { 'qf', 'help' }, -- Set a darker background on sidebar-like windows
        hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead
        -- Optional callback functions for color and highlight customization
        on_colors = function(colors)
          -- Override colors here if needed
          -- Example: colors.hint = colors.orange
        end,
        on_highlights = function(highlights, colors)
          -- Override highlight groups here if needed
          -- Example: highlights.Comment = { fg = colors.grey, italic = true }
        end,
      })
    end,
    init = function()
      -- Set colorscheme to last used or fallback
      vim.cmd.colorscheme(colorschemes[initial_scheme].scheme)
    end,
  },

  -- TokyoNight colorscheme plugin
  {
    'folke/tokyonight.nvim',
    lazy = initial_scheme ~= 'tokyonight', -- Only lazy if not the initial scheme
  },

  -- Jellybeans colorscheme plugin
  {
    'metalelf0/jellybeans-nvim',
    dependencies = { 'rktjmp/lush.nvim' },
    lazy = initial_scheme ~= 'jellybeans', -- Only lazy if not the initial scheme
    config = function()
      -- Empty config function to satisfy the plugin requirement
    end,
  },

  -- Set up keymap
  {
    'eldritch-theme/eldritch.nvim',
    keys = {
      {
        '<leader>ct',
        function()
          _G.cycle_colorscheme()
        end,
        desc = 'Cycle colorscheme',
      },
    },
  },
}

-- }}}
