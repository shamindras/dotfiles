-- Buffer-local settings for all markdown files, plus zk-specific keymaps

-- {{{ Buffer Settings (all markdown files) ------------------------------------------------

-- Auto-enable spell check
vim.wo.spell = true
vim.opt_local.spelllang = { 'en_au', 'en_gb' }

-- Fold by heading level using Treesitter
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldlevel = 99 -- Start with all folds open
vim.wo.foldtext = '' -- Show first line with extmarks (render-markdown decorations)

-- Section text object: select heading + content (daS, diS, vaS, viS, etc.)
local ai = require('mini.ai')
vim.b.miniai_config = {
  custom_textobjects = {
    h = ai.gen_spec.treesitter({ a = '@section.outer', i = '@section.inner' }),
  },
}

-- ------------------------------------------------------------------------- }}}

-- {{{ Heading Highlights (theme-aware) --------------------------------------------------

-- Per-theme heading palettes: { bg = { H1..H6 }, fg = dark text color }
local heading_palettes = {
  eldritch = {
    bg = { '#987afb', '#37f499', '#04d1f9', '#fca6ff', '#9ad900', '#e58f2a' },
    fg = '#0D1116',
  },
  ['tokyonight-night'] = {
    bg = { '#bb9af7', '#7aa2f7', '#7dcfff', '#9ece6a', '#ff9e64', '#e0af68' },
    fg = '#1a1b26',
  },
  ['jellybeans-nvim'] = {
    bg = { '#8197bf', '#70b950', '#8fbfdc', '#f0a0c0', '#ffb964', '#b888e2' },
    fg = '#151515',
  },
}

-- Apply Headline1-6Bg/Fg highlight groups for the active colorscheme
local function set_heading_highlights()
  local scheme = vim.g.colors_name or 'eldritch'
  local palette = heading_palettes[scheme] or heading_palettes.eldritch
  for i = 1, 6 do
    vim.api.nvim_set_hl(0, 'Headline' .. i .. 'Bg', { bg = palette.bg[i], fg = palette.fg, bold = true })
    vim.api.nvim_set_hl(0, 'Headline' .. i .. 'Fg', { fg = palette.bg[i], bold = true })
  end
end

-- Re-apply on theme change (augroup clear = true prevents duplicates from ftplugin re-entry)
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('MarkdownHeadingHighlights', { clear = true }),
  callback = set_heading_highlights,
})

-- Apply immediately for the current colorscheme
set_heading_highlights()

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
