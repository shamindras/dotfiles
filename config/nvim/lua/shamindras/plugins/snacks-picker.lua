return {
  'folke/snacks.nvim',
  config = function()
    local Snacks = require 'snacks'

    -- Layout configuration
    local layout_config = {
      height = 0.6,        -- Height as a percentage of the screen (0.0 to 1.0)
      preview_width = 0.6, -- Preview width as a percentage of the screen
    }

    -- Custom fd args for the find files picker
    local fd_args = {
      '--type',
      'f',                  -- Only files
      '--strip-cwd-prefix', -- Strip the cwd prefix
      '--hidden',           -- Include hidden files
      '--no-ignore-vcs',    -- Don't respect .gitignore
      '--exclude',
      '.git',               -- Exclude .git directory
      '--exclude',
      'node_modules',       -- Exclude node_modules directory
      '--exclude',
      'submods',            -- Exclude submods directory
      '--follow',           -- Follow symlinks
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
      -- Add the matcher configuration for frecency
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
      opts.cmd = 'fd'                            -- Use fd as the command
      opts.args = fd_args                        -- Pass custom fd args to override default
      with_ivy_layout(Snacks.picker.files, opts) -- Apply ivy layout to files picker
    end

    -- Set up Snacks with minimal configuration
    Snacks.setup {
      picker = {
        matcher = {
          sort_empty = true,    -- Default: false
          cwd_bonus = true,     -- Default: false
          frecency = true,      -- Default: false
          history_bonus = true, -- Default: false
        },
      },
      explorer = {},
      -- Minimal lazygit configuration
      lazygit = {
        configure = false, -- Disable automatic configuration
        win = {
          style = 'lazygit',
          width = 0.99,
          height = 0.99,
          row = 0,
          col = 0,
          border = 'none',
        },
      },
    }

    -- Helper function for key mapping
    local function map_key(key, picker_func, desc)
      vim.keymap.set('n', key, function()
        picker_func()
      end, { noremap = true, silent = true, desc = desc })
    end

    -- Key mappings using the wrapper functions with meaningful mnemonics
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

    -- Key mapping for custom find files with fd and ivy layout
    map_key('<leader>ff', find_files_with_fd, '[F]ind [F]iles')

    -- More key mappings with ivy layout and better mnemonics
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
    -- Add this with your other key mappings
    map_key('<leader>lg', function()
      Snacks.lazygit()
    end, '[L]azy[G]it')
  end,
}
