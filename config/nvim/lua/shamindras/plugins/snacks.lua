return {
  'folke/snacks.nvim',
  event = {
    -- Load on specific events for better startup time
    'VeryLazy',   -- Load after other plugins
    'BufReadPre', -- Load before reading a file
  },
  keys = {
    -- Pre-define keymaps so lazy.nvim knows about them
    { '<leader><space>', desc = '[S]mart [F]ind Files' },
    { '<leader>,',       desc = '[F]ind [B]uffers (Ivy Layout)' },
    { '<leader>/',       desc = '[F]ind [G]rep' },
    { '<leader>:',       desc = '[C]ommand [H]istory' },
    { '<leader>n',       desc = '[N]otification [H]istory' },
    { '<leader>e',       desc = '[F]ile [E]xplorer' },
    { '<leader>ff',      desc = '[F]ind [F]iles' },
    { '<leader>fb',      desc = '[F]ind [B]uffers (Ivy Layout)' },
    { '<leader>fc',      desc = '[F]ind [C]onfig file' },
    { '<leader>fg',      desc = '[F]ind [G]it [F]iles' },
    { '<leader>fp',      desc = '[F]ind [P]rojects' },
    { '<leader>fr',      desc = '[F]ind [R]ecent' },
    { '<leader>lg',      desc = '[L]azy[G]it' },
  },
  config = function()
    local Snacks = require 'snacks'

    -- Layout configuration
    local layout_config = {
      height = 0.7,
      preview_width = 0.6,
    }

    -- Custom fd args for the find files picker
    local fd_args = {
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
      'submods',
      '--follow',
    }

    -- Custom ivy layout configuration
    local ivy_layout = {
      layout = {
        box = 'vertical',
        backdrop = false,
        row = -1,
        width = 0,
        height = layout_config.height,
        border = 'top',
        title = ' {title} {live} {flags}',
        title_pos = 'left',
        { win = 'input', height = 1, border = 'bottom' },
        {
          box = 'horizontal',
          { win = 'list', border = 'none' },
          {
            win = 'preview',
            title = '{preview}',
            width = layout_config.preview_width,
            border = 'left',
          },
        },
      },
    }

    -- Wrapper function to apply ivy layout to a picker
    local function with_ivy_layout(picker_func, opts)
      opts = opts or {}
      opts.layouts = {
        ivy = ivy_layout,
      }
      opts.layout = 'ivy'
      opts.matcher = {
        sort_empty = true,
        cwd_bonus = true,
        frecency = true,
        history_bonus = true,
      }
      picker_func(opts)
    end

    -- Wrapper for the find files picker using fd with custom args
    local function find_files_with_fd(opts)
      opts = opts or {}
      opts.cmd = 'fd'
      opts.args = fd_args
      with_ivy_layout(Snacks.picker.files, opts)
    end

    -- Set up Snacks with minimal configuration
    Snacks.setup {
      picker = {
        matcher = {
          sort_empty = true,
          cwd_bonus = true,
          frecency = true,
          history_bonus = true,
        },
      },
      explorer = {},
      lazygit = {
        configure = false,
        win = {
          style = 'lazygit',
          width = 0.99,
          height = 0.99,
          row = 0,
          col = 0,
          border = 'none',
        },
      },
      opts = {
        indent = {},
      },
    }

    -- Enable indent guides
    -- Snacks.indent.enable()

    -- Helper function for key mapping
    local function map_key(key, picker_func, desc)
      vim.keymap.set('n', key, function()
        picker_func()
      end, { noremap = true, silent = true, desc = desc })
    end

    -- Key mappings using the wrapper functions
    map_key('<leader><space>', function()
      with_ivy_layout(Snacks.picker.smart)
    end, '[S]mart [F]ind Files')
    map_key('<leader>,', function()
      with_ivy_layout(Snacks.picker.buffers)
    end, '[F]ind [B]uffers (Ivy Layout)')
    map_key('<leader>/', function()
      with_ivy_layout(Snacks.picker.grep)
    end, '[F]ind [G]rep')
    map_key('<leader>:', function()
      with_ivy_layout(Snacks.picker.command_history)
    end, '[C]ommand [H]istory')
    map_key('<leader>n', function()
      with_ivy_layout(Snacks.picker.notifications)
    end, '[N]otification [H]istory')
    map_key('<leader>e', Snacks.explorer, '[F]ile [E]xplorer')
    map_key('<leader>ff', find_files_with_fd, '[F]ind [F]iles')
    map_key('<leader>fb', function()
      with_ivy_layout(Snacks.picker.buffers)
    end, '[F]ind [B]uffers (Ivy Layout)')
    map_key('<leader>fc', function()
      with_ivy_layout(Snacks.picker.files, { cwd = vim.fn.stdpath 'config' })
    end, '[F]ind [C]onfig file')
    map_key('<leader>fg', function()
      with_ivy_layout(Snacks.picker.git_files)
    end, '[F]ind [G]it [F]iles')
    map_key('<leader>fp', function()
      with_ivy_layout(Snacks.picker.projects)
    end, '[F]ind [P]rojects')
    map_key('<leader>fr', function()
      with_ivy_layout(Snacks.picker.recent)
    end, '[F]ind [R]ecent')
    map_key('<leader>lg', function()
      Snacks.lazygit()
    end, '[L]azy[G]it')
  end,
}
