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

    -- Get notebook directory
    local function get_notebook_dir()
      local notebook_dir = vim.fn.getenv('ZK_NOTEBOOK_DIR')
      if notebook_dir == vim.NIL or notebook_dir == '' then
        vim.notify('ZK_NOTEBOOK_DIR environment variable not set', vim.log.levels.WARN)
        return nil
      end
      return notebook_dir
    end

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

    -- Convert slug to human-readable Title Case (e.g., "deep-learning" → "Deep Learning")
    local function slugify_to_title(slug)
      local with_spaces = slug:gsub('-', ' ')
      local title = with_spaces:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
      end)
      return title
    end

    -- }}}

    -- {{{ Notification Helpers ---------------------------------------------------------------

    -- Create note with automatic notification
    local function create_note_with_notification(options, note_type)
      local zk_api = require('zk.api')

      zk_api.new(nil, options, function(err, res)
        if err then
          vim.notify(string.format('Failed to create %s: %s', note_type, tostring(err)), vim.log.levels.ERROR)
          return
        end

        if res and res.path then
          -- Open the file first
          vim.cmd.edit(res.path)

          -- Then show notification (with slight delay so it appears after buffer loads)
          vim.defer_fn(function()
            local filename = vim.fn.fnamemodify(res.path, ':t')
            vim.notify(
              string.format('Created %s: %s', note_type, filename),
              vim.log.levels.INFO,
              { timeout = 2000 } -- Linger for 2 seconds
            )
          end, 100)
        end
      end)
    end

    -- Sync templates with callback on success
    local function sync_templates_with_callback(on_success)
      if not sync_templates() then
        return false
      end

      if on_success then
        vim.defer_fn(on_success, 100)
      end
      return true
    end

    -- Create note in specified directory with notification
    local function create_note_in_dir(dir_name, note_type, options)
      local notebook_dir = get_notebook_dir()
      if not notebook_dir then
        return
      end

      local full_options = vim.tbl_extend('force', {
        dir = notebook_dir .. '/' .. dir_name,
      }, options or {})

      create_note_with_notification(full_options, note_type)
    end

    -- Generic wrapper: create note with optional template sync
    local function create_note_with_sync(dir_name, note_type, sync_first, options)
      local function do_create()
        create_note_in_dir(dir_name, note_type, options)
      end

      if sync_first then
        sync_templates_with_callback(do_create)
      else
        do_create()
      end
    end

    -- }}}

    -- {{{ Interactive Note Creation ----------------------------------------------------------

    -- Create idea note with interactive prompt and validation
    local function create_idea_note(sync_first)
      local function do_create()
        local title = vim.fn.input('Idea title: ')
        title = vim.trim(title):lower()

        if title == '' then
          vim.notify('Error: Title cannot be empty or only whitespace', vim.log.levels.ERROR)
          return
        end

        -- Generate human-readable display title
        local display_title = slugify_to_title(title)

        create_note_in_dir('ideas', 'idea', {
          title = title, -- Slug for filename
          extra = { display_title = display_title }, -- Human-readable for content
        })
      end

      if sync_first then
        sync_templates_with_callback(do_create)
      else
        do_create()
      end
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
      create_note_with_sync('journal', 'daily journal', false, options)
    end)

    -- Daily journal with template sync
    commands.add('ZkDailySync', function(options)
      create_note_with_sync('journal', 'daily journal', true, options)
    end)

    -- Idea note with validation
    commands.add('ZkIdea', function(options)
      -- If options with title are provided, use them directly (for programmatic calls)
      if options and options.title then
        local display_title = slugify_to_title(options.title)
        options.extra = { display_title = display_title }
        create_note_with_sync('ideas', 'idea', false, options)
      else
        -- Otherwise, use interactive prompt with validation
        create_idea_note(false)
      end
    end)

    -- Idea note with template sync and validation
    commands.add('ZkIdeaSync', function(options)
      -- If options with title are provided, use them directly
      if options and options.title then
        local display_title = slugify_to_title(options.title)
        options.extra = { display_title = display_title }
        create_note_with_sync('ideas', 'idea', true, options)
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
