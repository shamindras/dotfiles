-- ~/.config/nvim/lua/plugins/snacks/pickers.lua
local M = {}

-- Layout configuration
M.layout_config = {
  height = 0.7,
  preview_width = 0.6,
}

-- Custom fd args for the find files picker
M.fd_args = {
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

-- Custom ripgrep args for the grep picker (escaped glob patterns for zsh)
M.ripgrep_args = {
  'rg',                       -- Command to run ripgrep
  '--color=never',            -- Disable color output
  '--no-heading',             -- Don't show headings (file names) before results
  '--with-filename',          -- Show the filename for each match
  '--line-number',            -- Show line numbers in results
  '--column',                 -- Show column numbers for matches
  '--smart-case',             -- Enable smart case (case-insensitive if no uppercase letters)
  '--hidden',                 -- Include hidden files
  "--glob='!.git/*'",         -- Exclude .git directory (escaped)
  "--glob='!node_modules/*'", -- Exclude node_modules directory (escaped)
  '--no-ignore-vcs',          -- Don't respect version control ignores like .gitignore
  '--no-ignore-parent',       -- Don't respect parent directory ignore files
  '--follow',                 -- Follow symlinks
}

-- Custom ivy layout configuration
M.ivy_layout = {
  layout = {
    box = 'vertical',
    backdrop = false,
    row = -1,
    width = 0,
    height = M.layout_config.height,
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
        width = M.layout_config.preview_width,
        border = 'left',
      },
    },
  },
}

-- Wrapper function to apply ivy layout to a picker
function M.with_ivy_layout(picker_func, opts)
  opts = opts or {}
  opts.layouts = {
    ivy = M.ivy_layout,
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

-- Wrapper for the grep picker using ripgrep with custom args
function M.grep_with_ripgrep(opts)
  opts = opts or {}
  opts.query = opts.query or vim.fn.input 'Grep for: '

  -- Ensure a query is provided for ripgrep
  if opts.query == '' then
    print 'No search term provided. Exiting.'
    return
  end

  opts.cmd = 'rg'
  opts.args = vim.list_extend(M.ripgrep_args, { opts.query })

  -- Debugging: Print the arguments to be executed
  print('Running ripgrep with arguments: ' .. vim.inspect(opts.args))

  M.with_ivy_layout(require('snacks').picker.grep, opts)
end

-- Wrapper for the find files picker using fd with custom args
function M.find_files_with_fd(opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = M.fd_args
  M.with_ivy_layout(require('snacks').picker.files, opts)
end

-- Function to set up all picker-related keymaps
function M.setup_keymaps()
  local Snacks = require 'snacks'

  -- Helper function for key mapping
  local function map_key(key, picker_func, desc)
    vim.keymap.set('n', key, function()
      picker_func()
    end, { noremap = true, silent = true, desc = desc })
  end

  -- Key mappings using the wrapper functions
  map_key('<leader><space>', function()
    M.with_ivy_layout(Snacks.picker.smart)
  end, '[S]mart [F]ind Files')

  map_key('<leader>,', function()
    M.with_ivy_layout(Snacks.picker.buffers)
  end, '[F]ind [B]uffers (Ivy Layout)')

  map_key('<leader>/', function()
    M.with_ivy_layout(Snacks.picker.grep)
  end, '[F]ind [G]rep')

  map_key('<leader>:', function()
    M.with_ivy_layout(Snacks.picker.command_history)
  end, '[C]ommand [H]istory')

  map_key('<leader>n', function()
    M.with_ivy_layout(Snacks.picker.notifications)
  end, '[N]otification [H]istory')

  map_key('<leader>e', Snacks.explorer, '[F]ile [E]xplorer')

  map_key('<leader>ff', M.find_files_with_fd, '[F]ind [F]iles')

  map_key('<leader>fb', function()
    M.with_ivy_layout(Snacks.picker.buffers)
  end, '[F]ind [B]uffers (Ivy Layout)')

  map_key('<leader>fc', function()
    M.with_ivy_layout(Snacks.picker.files, { cwd = vim.fn.stdpath 'config' })
  end, '[F]ind [C]onfig file')

  map_key('<leader>fg', function()
    M.with_ivy_layout(Snacks.picker.git_files)
  end, '[F]ind [G]it [F]iles')

  map_key('<leader>fp', function()
    M.with_ivy_layout(Snacks.picker.projects)
  end, '[F]ind [P]rojects')

  map_key('<leader>fr', function()
    M.with_ivy_layout(Snacks.picker.recent)
  end, '[F]ind [R]ecent')

  map_key('<leader>fi', function()
    M.with_ivy_layout(Snacks.picker.icons)
  end, '[F]ind [I]cons')

  map_key('<leader>lg', function()
    Snacks.lazygit()
  end, '[L]azy[G]it')
end

return M

