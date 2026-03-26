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

-- {{{ Heading Fold Cycling (buffer-local zv/zj/zk) ------------------------------------------

-- Collect all ATX heading lines + levels via treesitter
-- Returns sorted list of { line = <1-indexed>, level = <1-6> }
local function get_heading_lines()
  local headings = {}
  local parser = vim.treesitter.get_parser(0, 'markdown')
  if not parser then
    return headings
  end
  local tree = parser:parse()[1]
  if not tree then
    return headings
  end
  local query = vim.treesitter.query.parse('markdown', '(atx_heading) @heading')
  for _, node in query:iter_captures(tree:root(), 0) do
    local start_row = node:range()
    local lnum = start_row + 1
    local text = vim.fn.getline(lnum)
    local level = #(text:match('^(#+)') or '#')
    table.insert(headings, { line = lnum, level = level })
  end
  return headings
end

-- Open all folds from line `from` to line `to` (inclusive)
local function open_folds_in_range(from, to)
  local saved = vim.api.nvim_win_get_cursor(0)
  for lnum = from, to do
    if vim.fn.foldclosed(lnum) ~= -1 then
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      vim.cmd('normal! zO')
    end
  end
  vim.api.nvim_win_set_cursor(0, saved)
end

-- Focus a heading: close all folds, open ancestor chain one level at a time,
-- then open the target section recursively. Keeps preamble (YAML/TOC) visible.
local function focus_heading(target_line)
  local headings = get_heading_lines()

  -- Find target heading level
  local target_level = 1
  for _, h in ipairs(headings) do
    if h.line == target_line then
      target_level = h.level
      break
    end
  end

  -- Build ancestor chain: for each level above target, find the nearest heading before it
  local ancestors = {}
  local need_level = target_level - 1
  for i = #headings, 1, -1 do
    if headings[i].line < target_line and headings[i].level == need_level then
      table.insert(ancestors, 1, headings[i].line)
      need_level = need_level - 1
      if need_level == 0 then
        break
      end
    end
  end

  -- Close all folds
  vim.cmd('normal! zM')

  -- Open ancestor folds one level at a time (outermost to innermost)
  for _, ancestor_line in ipairs(ancestors) do
    vim.api.nvim_win_set_cursor(0, { ancestor_line, 0 })
    vim.cmd('normal! zo')
  end

  -- Open target heading's section recursively
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd('normal! zO')

  -- Keep preamble open (YAML frontmatter, H1, TOC — lines 1 to just before second heading)
  local preamble_end = (headings[2] and headings[2].line or vim.fn.line('$')) - 1
  if preamble_end >= 1 then
    open_folds_in_range(1, preamble_end)
  end

  vim.cmd('normal! zz')
end

vim.keymap.set('n', 'zv', function()
  local headings = get_heading_lines()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end

  local cur = vim.fn.line('.')

  -- Check if cursor is on a heading line
  local on_heading = false
  for _, h in ipairs(headings) do
    if h.line == cur then
      on_heading = true
      break
    end
  end

  if not on_heading then
    -- Not on a heading — move to nearest heading (prefer next)
    local target
    for _, h in ipairs(headings) do
      if h.line > cur then
        target = h.line
        break
      end
    end
    if not target then
      target = headings[1].line
    end
    focus_heading(target)
    return
  end

  -- On a heading — toggle its fold
  if vim.fn.foldclosed('.') == -1 then
    vim.cmd('normal! zc')
  else
    focus_heading(cur)
  end
end, { buffer = 0, desc = 'Toggle heading fold / focus nearest' })

vim.keymap.set('n', 'zj', function()
  local headings = get_heading_lines()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end
  if #headings == 1 then
    vim.notify('Only heading in buffer', vim.log.levels.INFO)
    return
  end

  local cur = vim.fn.line('.')
  for _, h in ipairs(headings) do
    if h.line > cur then
      focus_heading(h.line)
      return
    end
  end

  -- Cycle to first heading
  focus_heading(headings[1].line)
end, { buffer = 0, desc = 'Next heading (cycle)' })

vim.keymap.set('n', 'zk', function()
  local headings = get_heading_lines()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end
  if #headings == 1 then
    vim.notify('Only heading in buffer', vim.log.levels.INFO)
    return
  end

  local cur = vim.fn.line('.')
  for i = #headings, 1, -1 do
    if headings[i].line < cur then
      focus_heading(headings[i].line)
      return
    end
  end

  -- Cycle to last heading
  focus_heading(headings[#headings].line)
end, { buffer = 0, desc = 'Previous heading (cycle)' })

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
