return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  cmd = 'Telescope',
  keys = {
    { '<leader>sh', desc = '[S]earch [H]elp' },
    { '<leader>sk', desc = '[S]earch [K]eymaps' },
    { '<leader>sf', desc = '[S]earch [F]iles' },
    { '<leader>ss', desc = '[S]earch [S]elect Telescope' },
    { '<leader>sw', desc = '[S]earch current [W]ord' },
    { '<leader>sg', desc = '[S]earch by [G]rep' },
    { '<leader>sd', desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', desc = '[S]earch [R]esume' },
    { '<leader>s.', desc = '[S]earch Recent Files' },
    { '<leader>sb', desc = '[S]earch [B]uffers' },
    { '<leader>/',  desc = '[/] Fuzzily search in current buffer' },
    { '<leader>s/', desc = '[S]earch [/] in Open Files' },
    { '<leader>sn', desc = '[S]earch [N]eovim files' },
  },
  dependencies = {
    { 'nvim-lua/plenary.nvim',                   lazy = true },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim', lazy = true },
    {
      'nvim-tree/nvim-web-devicons',
      enabled = vim.g.have_nerd_font,
      lazy = true,
    },
  },
  config = function()
    local telescope = require 'telescope'
    local builtin = require 'telescope.builtin'
    local themes = require 'telescope.themes'

    telescope.setup {
      defaults = {
        -- Respect .gitignore
        file_ignore_patterns = {
          '%.git/',
          'node_modules/',
          '%.next/',
          '%.yarn/',
          '%.venv/',
          '%.idea/',
          '%.vscode/',
          '%.env',
          '%.DS_Store',
          'target/',
          'build/',
          'dist/',
          'vendor/',
          'submods/',
        },
        -- Configure ripgrep specifically
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',               -- Search hidden files
          '--glob=!.git/*',         -- Exclude .git directory
          '--glob=!node_modules/*', -- Exclude node_modules
          '--no-ignore-vcs',        -- Don't respect .gitignore
          '--no-ignore-parent',     -- Don't respect parent directory ignores
          '--follow',               -- Follow symlinks
        },
        set_env = { COLORTERM = 'truecolor' },
        cache_picker = {
          num_pickers = 5,
          limit_entries = 1000,
        },
      },
      pickers = {
        find_files = {
          theme = 'ivy',
          find_command = {
            'fd',
            '--type',
            'f',
            '--strip-cwd-prefix',
            '--hidden',        -- Include hidden files
            '--no-ignore-vcs', -- Don't respect .gitignore
            '--exclude',
            '.git',            -- Exclude .git directory
            '--exclude',
            'node_modules',
            '--follow', -- Follow symlinks
          },
          -- Additional fd flags can be added here
        },
        live_grep = {
          theme = 'ivy',
          previewer = false,
          -- Additional ripgrep configuration
          additional_args = function()
            return {
              '--hidden',
              '--no-ignore-vcs',
              '--glob=!.git/*',
              '--glob=!node_modules/*',
            }
          end,
        },
        help_tags = { theme = 'ivy' },
        keymaps = { theme = 'ivy' },
        builtin = { theme = 'ivy' },
        oldfiles = { theme = 'ivy' },
        diagnostics = { theme = 'ivy' },
        buffers = { theme = 'ivy' },
      },
      extensions = {
        ['ui-select'] = themes.get_ivy(),
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    }

    -- Load extensions lazily
    vim.schedule(function()
      pcall(function()
        telescope.load_extension 'fzf'
      end)
      pcall(function()
        telescope.load_extension 'ui-select'
      end)
    end)

    -- Keymap definitions with lazy loading considerations
    local function map(key, func, desc)
      vim.keymap.set('n', key, function()
        require 'telescope'
        func()
      end, { desc = desc })
    end

    -- Setup keymaps
    map('<leader>sh', builtin.help_tags, '[S]earch [H]elp')
    map('<leader>sk', builtin.keymaps, '[S]earch [K]eymaps')
    map('<leader>sf', builtin.find_files, '[S]earch [F]iles')
    map('<leader>ss', builtin.builtin, '[S]earch [S]elect Telescope')
    map('<leader>sw', builtin.grep_string, '[S]earch current [W]ord')
    map('<leader>sg', builtin.live_grep, '[S]earch by [G]rep')
    map('<leader>sd', builtin.diagnostics, '[S]earch [D]iagnostics')
    map('<leader>sr', builtin.resume, '[S]earch [R]esume')
    map('<leader>s.', builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
    map('<leader>sb', builtin.buffers, '[S]earch [B]uffers')

    -- Advanced mappings
    map('<leader>/', function()
      builtin.current_buffer_fuzzy_find(themes.get_ivy {
        winblend = 10,
        previewer = false,
      })
    end, '[/] Fuzzily search in current buffer')

    map('<leader>s/', function()
      builtin.live_grep(themes.get_ivy {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      })
    end, '[S]earch [/] in Open Files')

    map('<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, '[S]earch [N]eovim files')
  end,
}
