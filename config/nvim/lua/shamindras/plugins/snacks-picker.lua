return {
  'folke/snacks.nvim',
  config = function()
    local Snacks = require 'snacks'

    -- Custom fd args for the find files picker
    local fd_args = {
      '--type',
      'f', -- Only files
      '--strip-cwd-prefix', -- Strip the cwd prefix
      '--hidden', -- Include hidden files
      '--no-ignore-vcs', -- Don't respect .gitignore
      '--exclude',
      '.git', -- Exclude .git directory
      '--exclude',
      'node_modules', -- Exclude node_modules directory
      '--exclude',
      'submods', -- Exclude submods directory
      '--follow', -- Follow symlinks
    }

    -- Wrapper function to apply ivy layout to a picker
    local function with_ivy_layout(picker_func, opts)
      opts = opts or {}
      opts.layout = { preset = 'ivy', position = 'bottom' } -- Set Ivy layout by default
      picker_func(opts)
    end

    -- Wrapper for the find files picker using fd with custom args
    local function find_files_with_fd(opts)
      opts = opts or {}
      opts.cmd = 'fd' -- Use fd as the command
      opts.args = fd_args -- Pass custom fd args to override default
      with_ivy_layout(Snacks.picker.files, opts) -- Apply ivy layout to files picker
    end

    -- Set up Snacks with your configuration
    Snacks.setup {
      picker = {},
      explorer = {},
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
  end,
}
