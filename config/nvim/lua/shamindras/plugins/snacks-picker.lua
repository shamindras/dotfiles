-- Define keymap configurations once
local keymap_configs = {
  { key = '<leader>sf', picker = 'files', desc = '[S]earch [F]iles' },
  { key = '<leader>sg', picker = 'grep', desc = '[S]earch by [G]rep' },
  { key = '<leader>sw', picker = 'grep_string', desc = '[S]earch current [W]ord' },
  { key = '<leader>sb', picker = 'buffers', desc = '[S]earch [B]uffers' },
  { key = '<leader>sh', picker = 'help', desc = '[S]earch [H]elp' },
  { key = '<leader>sk', picker = 'keymaps', desc = '[S]earch [K]eymaps' },
  { key = '<leader>ss', picker = 'pickers', desc = '[S]earch [S]elect Picker' },
  { key = '<leader>sd', picker = 'diagnostics', desc = '[S]earch [D]iagnostics' },
  { key = '<leader>sr', picker = 'resume', desc = '[S]earch [R]esume' },
  { key = '<leader>s.', picker = 'oldfiles', desc = '[S]earch Recent Files' },
  {
    key = '<leader>/',
    picker = 'buffer_lines',
    desc = '[/] Fuzzily search in current buffer',
    opts = { winblend = 10 },
  },
  {
    key = '<leader>s/',
    picker = 'grep',
    desc = '[S]earch [/] in Open Files',
    opts = {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    },
  },
  {
    key = '<leader>sn',
    picker = 'files',
    desc = '[S]earch [N]eovim files',
    opts = function()
      return { cwd = vim.fn.stdpath 'config' }
    end,
  },
}

local M = {
  'folke/snacks.nvim',
  lazy = true,
  cmd = 'Snacks',
  keys = function()
    return vim.tbl_map(function(k)
      return { k.key, mode = 'n', desc = k.desc }
    end, keymap_configs)
  end,
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      enabled = vim.g.have_nerd_font,
      lazy = true,
      module = true,
    },
  },
  init = function()
    vim.g.snacks_ignore_patterns = {
      '.git/',
      'node_modules/',
      '.next/',
      '.yarn/',
      '.venv/',
      '.idea/',
      '.vscode/',
      '.env',
      '.DS_Store',
      'target/',
      'build/',
      'dist/',
      'vendor/',
      'submods/', -- Ensure this is recognized
    }
  end,
  config = function()
    local snacks = require 'snacks'

    snacks.setup {
      defaults = {
        layout = 'ivy', -- Set ivy as the default layout
        previewer = true,
      },
      layouts = {
        ivy = { -- Configure the ivy layout
          height = 0.4,
          preview = {
            side = 'right',
            width = 0.6,
          },
        },
      },
      picker = {
        fd = {
          cmd = {
            'fd',
            '--type',
            'f',
            '--strip-cwd-prefix',
            '--hidden',
            '--no-ignore-vcs',
            '--exclude',
            '.git',
            '--exclude',
            'node_modules',
            '--exclude',
            'submods', -- Explicitly exclude submods here for fd
            '--follow',
          },
        },
        rg = {
          cmd = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!.git/*',
            '--glob=!node_modules/*',
            '--glob=!submods/*', -- Explicitly exclude submods here for rg
            '--no-ignore-vcs',
            '--no-ignore-parent',
            '--follow',
          },
        },
        ignore = vim.g.snacks_ignore_patterns, -- Use ignore patterns defined in init()
        cache = {
          ttl = 3600,
          size = 1000,
        },
      },
    }

    -- Check if the Ivy layout is being applied properly
    print 'Configured Snacks with Ivy layout'

    -- Simplified picker command creation
    local function create_picker_command(picker_type, opts)
      return function()
        local final_opts =
          vim.tbl_deep_extend('force', {}, opts or {}, type(opts) == 'function' and opts() or {})
        snacks.picker[picker_type](final_opts)
      end
    end

    -- Setup keymaps
    for _, k in ipairs(keymap_configs) do
      vim.keymap.set('n', k.key, create_picker_command(k.picker, k.opts), { desc = k.desc })
    end
  end,
}

return M
