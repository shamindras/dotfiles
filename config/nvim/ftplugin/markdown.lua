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

-- Palettes sourced from util/themes.lua (single source of truth for all theme data)
local theme_registry = require('shamindras.util.themes')

local function get_palette(palette_key)
  local scheme = vim.g.colors_name or theme_registry.themes[theme_registry.default].scheme
  local key = theme_registry.scheme_to_key[scheme] or theme_registry.default
  return theme_registry.themes[key][palette_key]
end

-- Apply Headline1-6Bg/Fg and RenderMarkdownCode highlight groups for the active colorscheme
local function set_markdown_highlights()
  local h_palette = get_palette('heading_palette')
  for i = 1, 6 do
    vim.api.nvim_set_hl(0, 'Headline' .. i .. 'Bg', { bg = h_palette.bg[i], fg = h_palette.fg, bold = true })
    vim.api.nvim_set_hl(0, 'Headline' .. i .. 'Fg', { fg = h_palette.bg[i], bold = true })
  end

  local c_palette = get_palette('code_palette')
  vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = c_palette.bg })
end

-- Re-apply on theme change (augroup clear = true prevents duplicates from ftplugin re-entry)
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('MarkdownHighlights', { clear = true }),
  callback = set_markdown_highlights,
})

-- Apply immediately for the current colorscheme
set_markdown_highlights()

-- ------------------------------------------------------------------------- }}}

-- {{{ Heading Operations (section moves + level cycling) ------------------------------------

local md = require('shamindras.util.markdown')

-- Section moves (dot-repeatable via operatorfunc)
_G.md_section_down = function(mode)
  if not mode then
    vim.o.operatorfunc = 'v:lua.md_section_down'
    return 'g@l'
  end
  md.move_section('down')
end

_G.md_section_up = function(mode)
  if not mode then
    vim.o.operatorfunc = 'v:lua.md_section_up'
    return 'g@l'
  end
  md.move_section('up')
end

-- Heading level cycling (dot-repeatable via operatorfunc)
_G.md_heading_promote = function(mode)
  if not mode then
    vim.o.operatorfunc = 'v:lua.md_heading_promote'
    return 'g@l'
  end
  md.cycle_heading_level(-1)
end

_G.md_heading_demote = function(mode)
  if not mode then
    vim.o.operatorfunc = 'v:lua.md_heading_demote'
    return 'g@l'
  end
  md.cycle_heading_level(1)
end

vim.keymap.set(
  'n',
  '<leader>mj',
  _G.md_section_down,
  { buf = 0, expr = true, desc = '[m]arkdown section move down [j]' }
)
vim.keymap.set('n', '<leader>mk', _G.md_section_up, { buf = 0, expr = true, desc = '[m]arkdown section move up [k]' })
vim.keymap.set(
  'n',
  '<leader>mh',
  _G.md_heading_promote,
  { buf = 0, expr = true, desc = '[m]arkdown [h]eading promote' }
)
vim.keymap.set(
  'n',
  '<leader>ml',
  _G.md_heading_demote,
  { buf = 0, expr = true, desc = '[m]arkdown heading demote [l]' }
)

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
