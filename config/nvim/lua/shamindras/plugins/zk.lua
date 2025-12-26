return {
  'zk-org/zk-nvim',
  dependencies = {
    'folke/snacks.nvim', -- Required: we use snacks pickers and ivy layout
  },
  event = 'VeryLazy',
  keys = {
    -- Pre-define keys for lazy loading with which-key labels
    { '<leader>k', desc = '+[k]asten (zk notes)' },
    { '<leader>kd', desc = '[k]asten [d]aily' },
    { '<leader>kD', desc = '[k]asten [d]aily sync' },
    { '<leader>ki', desc = '[k]asten [i]dea' },
    { '<leader>kI', desc = '[k]asten [I]dea sync' },
    { '<leader>ks', desc = '[k]asten [s]earch' },
    { '<leader>kn', desc = '[k]asten [n]otes' },
    { '<leader>kt', desc = '[k]asten [t]ags' },
    { '<leader>kf', desc = '[k]asten [f]ind files' },
    { '<leader>k/', desc = '[k]asten grep' },
    { '<leader>kN', desc = '[k]asten [N]ew note' },
    { '<leader>kc', desc = '[k]asten [c]onfig' },
    { '<leader>kx', desc = '[k]asten inde[x]' },
    { '<leader>kT', desc = '[k]asten sync [T]emplates' },
  },
  config = function()
    -- {{{ Helper Functions -------------------------------------------------------------------

    -- Sync templates from ~/.config/zk/templates to notebook
    local function sync_templates()
      local source = vim.fn.expand('~/.config/zk/templates/')
      local notebook_dir = vim.fn.getenv('ZK_NOTEBOOK_DIR')

      if notebook_dir == vim.NIL or notebook_dir == '' then
        vim.notify('ZK_NOTEBOOK_DIR environment variable not set', vim.log.levels.ERROR)
        return false
      end

      local dest = notebook_dir .. '/.zk/templates/'
      local cmd = string.format('rsync -au --delete %s %s 2>/dev/null', source, dest)

      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        vim.notify('Templates synced successfully', vim.log.levels.INFO)
        return true
      else
        vim.notify('Failed to sync templates: ' .. result, vim.log.levels.ERROR)
        return false
      end
    end

    -- Create idea note with interactive prompt and validation (replicates ki function)
    local function create_idea_note(sync_first)
      local zk = require('zk')

      -- Optionally sync templates first
      if sync_first then
        if not sync_templates() then
          return
        end
      end

      -- Prompt for title
      local title = vim.fn.input('Idea title: ')

      -- Trim whitespace and convert to lowercase
      title = vim.trim(title):lower()

      -- Validate title is not empty after trimming
      if title == '' then
        vim.notify('Error: Title cannot be empty or only whitespace', vim.log.levels.ERROR)
        return
      end

      -- Create the note
      zk.new({ group = 'ideas', title = title })
    end

    -- Get notebook directory
    local function get_notebook_dir()
      local notebook_dir = vim.fn.getenv('ZK_NOTEBOOK_DIR')
      if notebook_dir == vim.NIL or notebook_dir == '' then
        vim.notify('ZK_NOTEBOOK_DIR environment variable not set', vim.log.levels.WARN)
        return nil
      end
      return notebook_dir
    end

    -- }}}

    -- {{{ Setup zk-nvim ----------------------------------------------------------------------

    local zk = require('zk')
    -- Lazy-load snacks_pickers to avoid circular dependency
    local snacks_pickers = require('shamindras.plugins.snacks.pickers')

    zk.setup({
      picker = 'snacks_picker',
      picker_options = {
        snacks_picker = {
          layout = 'ivy',
          layouts = {
            ivy = snacks_pickers.ivy_layout,
          },
        },
      },
      lsp = {
        config = {
          name = 'zk',
          cmd = { 'zk', 'lsp' },
          filetypes = { 'markdown' },
          -- Ensure LSP provides completions from entire notebook
          root_dir = function(fname)
            return require('zk.util').notebook_root(fname)
          end,
          on_attach = function(client, bufnr)
            -- Setup omnifunc for completion
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
          end,
        },
        auto_attach = {
          enabled = true,
          filetypes = { 'markdown' },
        },
      },
    })

    -- }}}

    -- {{{ Custom Commands --------------------------------------------------------------------

    local commands = require('zk.commands')

    -- Daily journal (uses template with yyyy-mm-dd format)
    commands.add('ZkDaily', function(options)
      local notebook_dir = get_notebook_dir()
      if not notebook_dir then
        return
      end

      options = vim.tbl_extend('force', { dir = notebook_dir .. '/journal' }, options or {})
      zk.new(options)
    end)

    -- Daily journal with template sync
    commands.add('ZkDailySync', function(options)
      if not sync_templates() then
        return
      end

      vim.defer_fn(function()
        require('zk.commands').get('ZkDaily')(options)
      end, 100)
    end)

    -- Idea note with validation
    commands.add('ZkIdea', function(options)
      -- If options with title are provided, use them directly (for programmatic calls)
      if options and options.title then
        options = vim.tbl_extend('force', { group = 'ideas' }, options)
        zk.new(options)
      else
        -- Otherwise, use interactive prompt with validation
        create_idea_note(false)
      end
    end)

    -- Idea note with template sync and validation
    commands.add('ZkIdeaSync', function(options)
      -- If options with title are provided, use them directly
      if options and options.title then
        if not sync_templates() then
          return
        end

        vim.defer_fn(function()
          options = vim.tbl_extend('force', { group = 'ideas' }, options)
          zk.new(options)
        end, 100)
      else
        -- Otherwise, use interactive prompt with validation
        create_idea_note(true)
      end
    end)

    -- Search/edit notes interactively
    commands.add('ZkSearch', function(options)
      zk.edit(options, { title = 'Zk Search' })
    end)

    -- Edit zk config file
    commands.add('ZkConfig', function()
      vim.cmd('edit ' .. vim.fn.expand('~/.config/zk/config.toml'))
    end)

    -- Sync templates manually
    commands.add('ZkSyncTemplates', function()
      sync_templates()
    end)

    -- Grep within notebook directory
    commands.add('ZkNotebookGrep', function(options)
      local notebook_dir = get_notebook_dir()
      if not notebook_dir then
        return
      end

      options = options or {}
      options.cwd = notebook_dir
      snacks_pickers.grep_with_ripgrep(options)
    end)

    -- Find files within notebook directory
    commands.add('ZkNotebookFind', function(options)
      local notebook_dir = get_notebook_dir()
      if not notebook_dir then
        return
      end

      options = options or {}
      options.cwd = notebook_dir
      local Snacks = require('snacks')
      snacks_pickers.picker_with_fd(Snacks.picker.files, options)
    end)

    -- }}}

    -- {{{ Global Keymaps ---------------------------------------------------------------------

    local opts = { noremap = true, silent = true }

    -- High frequency operations (lowercase)
    vim.keymap.set('n', '<leader>kd', '<Cmd>ZkDaily<CR>', vim.tbl_extend('force', opts, { desc = '[k]asten [d]aily' }))
    vim.keymap.set('n', '<leader>ki', '<Cmd>ZkIdea<CR>', vim.tbl_extend('force', opts, { desc = '[k]asten [i]dea' }))
    vim.keymap.set(
      'n',
      '<leader>ks',
      '<Cmd>ZkSearch<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten [s]earch' })
    )
    vim.keymap.set('n', '<leader>kn', '<Cmd>ZkNotes<CR>', vim.tbl_extend('force', opts, { desc = '[k]asten [n]otes' }))
    vim.keymap.set('n', '<leader>kt', '<Cmd>ZkTags<CR>', vim.tbl_extend('force', opts, { desc = '[k]asten [t]ags' }))
    vim.keymap.set(
      'n',
      '<leader>kf',
      '<Cmd>ZkNotebookFind<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten [f]ind files' })
    )
    vim.keymap.set(
      'n',
      '<leader>k/',
      '<Cmd>ZkNotebookGrep<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten grep' })
    )

    -- Medium frequency operations (capitals)
    vim.keymap.set(
      'n',
      '<leader>kN',
      '<Cmd>ZkNew { title = vim.fn.input("Title: ") }<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten [N]ew note' })
    )
    vim.keymap.set(
      'n',
      '<leader>kD',
      '<Cmd>ZkDailySync<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten [d]aily sync' })
    )
    vim.keymap.set(
      'n',
      '<leader>kI',
      '<Cmd>ZkIdeaSync<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten [I]dea sync' })
    )

    -- Low frequency operations (maintenance/config)
    vim.keymap.set(
      'n',
      '<leader>kc',
      '<Cmd>ZkConfig<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten [c]onfig' })
    )
    vim.keymap.set('n', '<leader>kx', '<Cmd>ZkIndex<CR>', vim.tbl_extend('force', opts, { desc = '[k]asten inde[x]' }))
    vim.keymap.set(
      'n',
      '<leader>kT',
      '<Cmd>ZkSyncTemplates<CR>',
      vim.tbl_extend('force', opts, { desc = '[k]asten sync [T]emplates' })
    )

    -- }}}
  end,
}
