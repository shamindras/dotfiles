local M = {}

-- {{{ Text Editing Plugins

table.insert(M, {
  'nvim-mini/mini.ai',
  version = '*',
  event = 'VeryLazy',
  keys = {
    { 'a', mode = { 'x', 'o' } },
    { 'i', mode = { 'x', 'o' } },
  },
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'main',
      lazy = true,
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

table.insert(M, {
  'nvim-mini/mini.operators',
  version = '*',
  event = 'VeryLazy',
  config = function()
    require('mini.operators').setup()
  end,
})

table.insert(M, {
  'nvim-mini/mini.surround',
  version = '*',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('mini.surround').setup()
  end,
})

table.insert(M, {
  'nvim-mini/mini.move',
  version = '*',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('mini.move').setup()
  end,
})

table.insert(M, {
  'nvim-mini/mini.pairs',
  version = '*',
  event = 'InsertEnter',
  config = function()
    require('mini.pairs').setup()
  end,
})

-- ------------------------------------------------------------------------- }}}

-- {{{ General Workflow Plugins

table.insert(M, {
  'nvim-mini/mini.bracketed',
  version = '*',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('mini.bracketed').setup()
  end,
})

table.insert(M, {
  'nvim-mini/mini.files',
  version = '*',
  cmd = {
    'MiniFiles',
    'MiniFilesBufferDir',
    'MiniFilesCursorFile',
  },
  keys = {
    { '<leader>fm', '<cmd>lua MiniFiles.open()<cr>', desc = '[f]ile [m]ini files' },
    { '<leader>fa', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>', desc = '[f]ile [a]ctive file' },
    { '<leader>fh', "<cmd>lua MiniFiles.open('~')<cr>", desc = '[f]ile [h]ome dir' },
  },
  config = function()
    local minifiles = require('mini.files')
    minifiles.setup({
      windows = {
        max_number = 3,
        preview = true,
        width_focus = 30,
        width_nofocus = 15,
        width_preview = 60,
      },
      options = {
        permanent_delete = false,
        use_as_default_explorer = true,
      },
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        vim.keymap.set('n', 'q', MiniFiles.close, { buffer = buf_id, desc = 'Close Mini Files' })
      end,
    })
  end,
})

-- ------------------------------------------------------------------------- }}}

-- {{{ Appearance Plugins

table.insert(M, {
  'nvim-mini/mini.icons',
  version = '*',
  event = 'VeryLazy',
  config = function()
    require('mini.icons').setup()
  end,
})

table.insert(M, {
  'nvim-mini/mini.statusline',
  version = '*',
  event = 'VimEnter',
  config = function()
    local statusline = require('mini.statusline')
    statusline.setup({ use_icons = vim.g.have_nerd_font })

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    local function git_branch()
      local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
      if vim.v.shell_error == 0 and branch ~= '' then
        return '󰊢 ' .. branch
      end
      return ''
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git = git_branch()
      local filename = statusline.section_filename({ trunc_width = 140 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
      local location = statusline.section_location({ trunc_width = 75 })

      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { location } },
      })
    end
  end,
})

table.insert(M, {
  'nvim-mini/mini.notify',
  version = '*',
  event = 'VeryLazy',
  config = function()
    local mini_notify = require('mini.notify')
    -- Use all defaults - they're already sensible
    mini_notify.setup()
    -- Set as vim.notify handler
    vim.notify = mini_notify.make_notify()
  end,
})

-- ------------------------------------------------------------------------- }}}

-- {{{ Keymap Discovery

table.insert(M, {
  'nvim-mini/mini.clue',
  version = '*',
  event = 'VeryLazy',
  config = function()
    local miniclue = require('mini.clue')
    miniclue.setup({
      triggers = {
        { mode = 'n', keys = '<leader>' },
        { mode = 'x', keys = '<leader>' },
        { mode = 'i', keys = '<C-x>' },
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
        { mode = 'n', keys = '<C-w>' },
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
      },

      clues = {
        { mode = 'n', keys = '<leader>b', desc = '+[b]uffer' },
        { mode = 'n', keys = '<leader>d', desc = '+[d]elete (black hole)' },
        { mode = 'n', keys = '<leader>f', desc = '+[f]ile' },
        { mode = 'n', keys = '<leader>g', desc = '+[g]o/navigate' },
        { mode = 'n', keys = '<leader>i', desc = '+[i]nsert' },
        { mode = 'n', keys = '<leader>l', desc = '+[l]azy' },
        { mode = 'v', keys = '<leader>p', desc = '+[p]aste (register-aware)' },
        { mode = 'n', keys = '<leader>q', desc = '+[q]uit' },
        { mode = 'n', keys = '<leader>t', desc = '+[t]oggle' },
        { mode = 'n', keys = '<leader>w', desc = '+[w]indow' },
        { mode = 'n', keys = '<leader>x', desc = '+e[x]ecute' },
        { mode = 'n', keys = '<leader>y', desc = '+[y]ank (clipboard)' },
        { mode = 'v', keys = '<leader>y', desc = '+[y]ank (clipboard)' },
        { mode = 'n', keys = '<leader>s', desc = '+[s]earch' },
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      },
      window = {
        delay = 0,
        config = {
          width = 40,
          border = 'rounded',
        },
      },
    })
  end,
})

-- ------------------------------------------------------------------------- }}}

return M
