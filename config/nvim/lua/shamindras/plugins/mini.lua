local M = {}

-- {{{ Text editing plugins ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.ai',
  event = 'VeryLazy',
  keys = {
    { 'a', mode = { 'x', 'o' } },
    { 'i', mode = { 'x', 'o' } },
  },
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'main',
      lazy = true, -- Let mini.ai trigger the load when needed
    },
  },
  opts = function()
    local ai = require('mini.ai')
    return {
      n_lines = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),
        f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
        c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
      },
    }
  end,
})

--}}}

--{{{ Operators ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.operators',
  version = '*',
  event = 'VeryLazy', -- Load after startup
  config = function()
    require('mini.operators').setup()
  end,
})

--}}}

--{{{ Surround ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.surround',
  version = '*',
  event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
  config = function()
    require('mini.surround').setup()
  end,
})

--}}}

--{{{ Move ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.move',
  version = '*',
  event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
  config = function()
    require('mini.move').setup({
      mappings = {
        left = 'H',
        right = 'L',
        down = 'J',
        up = 'K',
      },
    })
  end,
})

--}}}

--{{{ Pairs ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.pairs',
  version = '*',
  event = 'InsertEnter', -- Load when entering insert mode
  config = function()
    require('mini.pairs').setup()
  end,
})

--}}}

--{{{ General workflow plugins ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.bracketed',
  version = '*',
  event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
  config = function()
    require('mini.bracketed').setup()
  end,
})

--}}}

--{{{ File Explorer ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.files',
  version = '*',
  cmd = {
    'MiniFiles',
    'MiniFilesBufferDir',
    'MiniFilesCursorFile',
  },
  keys = {
    {
      '<leader>fm',
      '<cmd>lua MiniFiles.open()<cr>',
      desc = 'Open Mini Files',
    },
    {
      '<leader>fa',
      '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>',
      desc = 'Mini Files [A]ctive File',
    },
    {
      '<leader>fh',
      "<cmd>lua MiniFiles.open('~')<cr>",
      desc = 'Mini Files Home Dir',
    },
  },
  config = function()
    local minifiles = require('mini.files')
    minifiles.setup({
      -- Customize windows
      windows = {
        -- Maximum number of windows to show side by side
        max_number = 3,
        -- Whether to show preview of file/directory under cursor
        preview = true,
        -- Width of focused window
        width_focus = 30,
        -- Width of non-focused window
        width_nofocus = 15,
        -- Width of preview window
        width_preview = 60,
        -- Use mini.icons for file icons
        use_icons = true,
      },
      options = {
        -- Whether to delete permanently or move into trash
        permanent_delete = false,
        -- Whether to use for editing directories
        use_as_default_explorer = true,
      },
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        -- Add quit mapping
        vim.keymap.set('n', 'q', MiniFiles.close, { buffer = buf_id, desc = 'Close Mini Files' })
      end,
    })
  end,
})

--}}}

--{{{ Appearance plugins ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.statusline',
  version = '*',
  event = 'VimEnter', -- Load when Vim starts
  config = function()
    -- Simple and easy statusline
    local statusline = require('mini.statusline')
    -- set use_icons to true if you have a Nerd Font
    statusline.setup({ use_icons = vim.g.have_nerd_font })

    -- Configure cursor location section to show LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
})

--}}}

--{{{ Icons plugin ------------------------------------------------------------------------

table.insert(M, {
  'nvim-mini/mini.icons',
  version = '*',
  event = 'VeryLazy',
  config = function()
    require('mini.icons').setup()
  end,
})

--}}}

return M
