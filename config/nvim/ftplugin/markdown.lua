-- Buffer-local settings for all markdown files, plus zk-specific keymaps

-- {{{ Buffer Settings (all markdown files) ------------------------------------------------

-- Auto-enable spell check
vim.wo.spell = true
vim.opt_local.spelllang = { 'en_au', 'en_gb' }

-- Fold by heading level using Treesitter
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldlevel = 99 -- Start with all folds open

-- Section text object: select heading + content (daS, diS, vaS, viS, etc.)
local ai = require('mini.ai')
vim.b.miniai_config = {
  custom_textobjects = {
    h = ai.gen_spec.treesitter({ a = '@section.outer', i = '@section.inner' }),
  },
}

-- ------------------------------------------------------------------------- }}}

-- {{{ zk Notebook Keymaps -----------------------------------------------------------------

-- Check if we're in a zk notebook
if require('zk.util').notebook_root(vim.fn.expand('%:p')) ~= nil then
  -- Helper function for setting buffer-local keymaps
  local function map(mode, lhs, rhs, desc)
    vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
  end

  -- {{{ Current Buffer Operations ----------------------------------------------------------

  -- Show backlinks to current note
  map('n', '<leader>kb', '<Cmd>ZkBacklinks<CR>', '[k]asten [b]acklinks')

  -- View outbound links from current note (low frequency - capital L)
  map('n', '<leader>kL', '<Cmd>ZkLinks<CR>', '[k]asten view [L]inks')

  -- }}}

  -- {{{ Link Insertion ---------------------------------------------------------------------

  -- Insert link at cursor (high frequency - lowercase l)
  map('n', '<leader>kl', '<Cmd>ZkInsertLink<CR>', '[k]asten insert [l]ink')

  -- Insert link around visual selection
  map('v', '<leader>kl', ":'<,'>ZkInsertLinkAtSelection<CR>", '[k]asten insert [l]ink')

  -- }}}

  -- {{{ Visual Mode - Create Notes from Selection -----------------------------------------

  -- Create note using selection as title
  map('v', '<leader>kv', ":'<,'>ZkNewFromTitleSelection<CR>", '[k]asten note from [v]isual title')

  -- Create note using selection as content
  map('v', '<leader>kV', ":'<,'>ZkNewFromContentSelection<CR>", '[k]asten note from [V]isual content')

  -- Match notes similar to selection
  map('v', '<leader>km', ":'<,'>ZkMatch<CR>", '[k]asten [m]atch selection')

  -- }}}
end

-- ------------------------------------------------------------------------- }}}
