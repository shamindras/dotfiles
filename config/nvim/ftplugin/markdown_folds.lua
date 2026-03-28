-- Markdown heading fold cycling: buffer-local zv/zj/zk overrides
-- Uses treesitter to cycle all heading levels with ancestor-aware fold management.

-- {{{ Helpers -------------------------------------------------------------------------------

-- Cache the treesitter query (parsed once per nvim session, not per keypress)
local heading_query = vim.treesitter.query.parse('markdown', '(atx_heading) @heading')

-- Collect all ATX heading lines + levels via treesitter
-- Returns sorted list of { line = <1-indexed>, level = <1-6> }
local function get_headings()
  local headings = {}
  local parser = vim.treesitter.get_parser(0, 'markdown')
  if not parser then
    return headings
  end
  local tree = parser:parse()[1]
  if not tree then
    return headings
  end
  for _, node in heading_query:iter_captures(tree:root(), 0) do
    local row = node:range()
    local lnum = row + 1
    local level = #(vim.fn.getline(lnum):match('^#+') or '#')
    table.insert(headings, { line = lnum, level = level })
  end
  return headings
end

-- Open all folds in a line range (inclusive)
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

-- Find next or previous heading from cursor, with wrap-around
local function find_adjacent_heading(headings, cur, direction)
  if direction == 'next' then
    for _, h in ipairs(headings) do
      if h.line > cur then
        return h.line
      end
    end
    return headings[1].line
  else
    for i = #headings, 1, -1 do
      if headings[i].line < cur then
        return headings[i].line
      end
    end
    return headings[#headings].line
  end
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Focus Heading -------------------------------------------------------------------------

-- Close all folds, open ancestor chain one level at a time, open target section
-- recursively, keep preamble (YAML/TOC) visible, center viewport.
local function focus_heading(headings, target_line)
  -- Find target heading level
  local target_level = 1
  for _, h in ipairs(headings) do
    if h.line == target_line then
      target_level = h.level
      break
    end
  end

  -- Build ancestor chain: for each level above target, find nearest heading before it
  local ancestors = {}
  local need = target_level - 1
  for i = #headings, 1, -1 do
    if headings[i].line < target_line and headings[i].level == need then
      table.insert(ancestors, 1, headings[i].line)
      need = need - 1
      if need == 0 then
        break
      end
    end
  end

  -- Close all folds
  vim.cmd('normal! zM')

  -- Open ancestor folds one level at a time (outermost to innermost)
  for _, line in ipairs(ancestors) do
    vim.api.nvim_win_set_cursor(0, { line, 0 })
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

-- ------------------------------------------------------------------------- }}}

-- {{{ Keymaps -------------------------------------------------------------------------------

-- Cycle to next/prev heading (shared logic for zj/zk)
local function cycle_heading(direction)
  local headings = get_headings()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end
  if #headings == 1 then
    vim.notify('Only heading in buffer', vim.log.levels.INFO)
    return
  end
  -- Snap to containing heading so prev/next is relative to section, not cursor line
  local raw_cur = vim.fn.line('.')
  local cur = headings[1].line
  for _, h in ipairs(headings) do
    if h.line <= raw_cur then
      cur = h.line
    else
      break
    end
  end
  focus_heading(headings, find_adjacent_heading(headings, cur, direction))
end

-- Toggle fold on heading / focus nearest heading (zv)
local function toggle_or_focus()
  local headings = get_headings()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end

  local cur = vim.fn.line('.')

  -- O(1) heading check via set
  local on_heading = false
  for _, h in ipairs(headings) do
    if h.line == cur then
      on_heading = true
      break
    end
  end

  if not on_heading then
    focus_heading(headings, find_adjacent_heading(headings, cur, 'next'))
    return
  end

  -- On a heading — toggle its fold
  if vim.fn.foldclosed('.') == -1 then
    vim.cmd('normal! zc')
  else
    focus_heading(headings, cur)
  end
end

-- Buffer-local keymaps (override global fold cycling for markdown)
vim.keymap.set('n', 'zv', toggle_or_focus, { buffer = 0, desc = 'Toggle heading fold / focus nearest' })

vim.keymap.set('n', 'zj', function()
  cycle_heading('next')
end, { buffer = 0, desc = 'Next heading (cycle)' })

vim.keymap.set('n', 'zk', function()
  cycle_heading('prev')
end, { buffer = 0, desc = 'Previous heading (cycle)' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Auto-collapse on buffer load ------------------------------------------------------------

-- Close all folds, then focus the heading nearest to cursor (reuses zv logic).
-- Uses BufWinEnter (fires after buffer is displayed) + defer to ensure folds exist.
local bufnr = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd('BufWinEnter', {
  buffer = bufnr,
  once = true,
  callback = function()
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
        return
      end
      local headings = get_headings()
      if #headings == 0 then
        return
      end
      -- Find the containing heading (at or above cursor), close all, focus it,
      -- then restore cursor to original position
      local saved_cursor = vim.api.nvim_win_get_cursor(0)
      local cur = saved_cursor[1]
      local containing = headings[1]
      for _, h in ipairs(headings) do
        if h.line <= cur then
          containing = h
        else
          break
        end
      end
      focus_heading(headings, containing.line)
      vim.api.nvim_win_set_cursor(0, saved_cursor)
    end, 50)
  end,
})

-- ------------------------------------------------------------------------- }}}
