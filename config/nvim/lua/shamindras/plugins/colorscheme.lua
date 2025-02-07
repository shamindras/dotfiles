-- Store the toggle function in _G so it's globally accessible
local colorschemes = {
  eldritch = {
    plugin = 'eldritch-theme/eldritch.nvim',
    scheme = 'eldritch',
  },
  tokyonight = {
    plugin = 'folke/tokyonight.nvim',
    scheme = 'tokyonight-night',
  },
}

local current_scheme = 'eldritch' -- Initial color scheme

local function load_colorscheme(scheme)
  local config = colorschemes[scheme]

  if not config then
    print('Unknown colorscheme: ' .. scheme)
    return
  end

  -- Load the colorscheme
  vim.cmd.colorscheme(config.scheme)

  -- Common settings for both themes
  vim.cmd.hi 'Comment gui=none'
  vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'None', fg = 'white' })
end

-- Make the toggle function globally accessible
_G.toggle_colorscheme = function()
  current_scheme = (current_scheme == 'eldritch') and 'tokyonight' or 'eldritch'
  load_colorscheme(current_scheme)
end

return {
  -- Eldritch colorscheme plugin
  {
    'eldritch-theme/eldritch.nvim',
    priority = 1000,
    config = function()
      load_colorscheme(current_scheme)
    end,
  },

  -- TokyoNight colorscheme plugin
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      load_colorscheme(current_scheme)
    end,
  },

  -- snacks.nvim plugin
  {
    'folke/snacks.nvim',
    opts = {
      toggle = {
        icon = {
          enabled = ' ',
          disabled = ' ',
        },
        color = {
          enabled = 'green',
          disabled = 'yellow',
        },
        which_key = true,
        notify = true,
        map = function(mode, lhs, rhs, opts)
          vim.keymap.set(mode, lhs, rhs, opts)
        end,
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)
    end,
  },

  -- Set up keymap after everything is loaded
  {
    'eldritch-theme/eldritch.nvim',
    event = 'VimEnter',
    config = function()
      vim.keymap.set(
        'n',
        '<leader>ct',
        _G.toggle_colorscheme,
        { noremap = true, silent = true, desc = 'Toggle colorscheme' }
      )
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
