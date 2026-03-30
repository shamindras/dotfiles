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

-- Find the containing heading for a given line (nearest heading at or above cursor)
local function find_containing_heading(headings, cur)
  local containing = headings[1]
  for _, h in ipairs(headings) do
    if h.line <= cur then
      containing = h
    else
      break
    end
  end
  return containing
end

-- Ensure every heading is visible as a fold bar by opening parent folds.
-- foldclosed(line) == line means the heading IS a fold bar (visible);
-- foldclosed(line) == other means it's hidden inside another fold.
-- Content preamble folds (from rebuild_manual_folds) prevent content leak.
local function ensure_headings_visible(headings)
  for _, h in ipairs(headings) do
    local fc = vim.fn.foldclosed(h.line)
    while fc ~= -1 and fc ~= h.line do
      vim.api.nvim_win_set_cursor(0, { fc, 0 })
      vim.cmd('normal! zo')
      fc = vim.fn.foldclosed(h.line)
    end
  end
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Focus Heading -------------------------------------------------------------------------

-- Autocmd group for restoring expr foldmethod after manual fold cycling
local fold_augroup = vim.api.nvim_create_augroup('MarkdownFoldRestore', { clear = true })

-- Build manual folds from heading structure for precise fold boundaries.
-- Treesitter foldexpr can leave content "loose" at the wrong fold level
-- (especially after heading level changes), causing leaks. Manual folds
-- give us exact control: each section spans heading line to the line
-- before the next same-or-higher-level heading.
local function rebuild_manual_folds(headings)
  vim.wo.foldmethod = 'manual'
  vim.cmd('normal! zE') -- eliminate all existing folds

  -- Compute section ranges
  local sections = {}
  local last_line = vim.fn.line('$')
  for i, h in ipairs(headings) do
    local section_end = last_line
    for j = i + 1, #headings do
      if headings[j].level <= h.level then
        section_end = headings[j].line - 1
        break
      end
    end
    if section_end >= h.line then
      table.insert(sections, { line = h.line, level = h.level, end_line = section_end })
    end
  end

  -- Create content preamble folds: for headings whose next heading is a
  -- child, fold the heading + content lines before that child. Starting
  -- from h.line (not h.line+1) ensures fold bars display the heading text
  -- with no blank-line gap between sibling fold bars.
  for i, h in ipairs(headings) do
    if i < #headings then
      local next_h = headings[i + 1]
      if next_h.level > h.level then
        table.insert(sections, {
          line = h.line,
          level = next_h.level,
          end_line = next_h.line - 1,
        })
      end
    end
  end

  -- Create folds from shallowest to deepest for proper nesting.
  -- Each level opens all folds first so inner lines are accessible,
  -- then creates folds at that level. This ensures H2 folds nest
  -- inside H1, H3 inside H2, etc.
  local max_level = 0
  for _, s in ipairs(sections) do
    if s.level > max_level then
      max_level = s.level
    end
  end
  for level = 1, max_level do
    vim.cmd('normal! zR') -- open all so inner lines are accessible
    for _, s in ipairs(sections) do
      if s.level == level then
        vim.cmd(s.line .. ',' .. s.end_line .. 'fold')
      end
    end
  end
end

-- Schedule restore of expr foldmethod on next buffer edit
local function schedule_fold_restore()
  vim.api.nvim_clear_autocmds({ group = fold_augroup })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = fold_augroup,
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldlevel = 99
    end,
  })
end

-- Collapse all heading folds, keeping every heading visible as a fold bar.
-- Used by toggle_or_focus() collapse paths; focus_heading() handles uncollapse.
-- No explicit ancestor/preamble opening needed — ensure_headings_visible opens
-- parent folds to reveal all headings, which implicitly opens ancestors and
-- exposes preamble content (opening H1 to reveal H2 also reveals lines between them).
local function collapse_all_headings(headings)
  rebuild_manual_folds(headings)
  schedule_fold_restore()
  vim.cmd('normal! zM')
  ensure_headings_visible(headings)
end

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

  -- Build ancestor chain: for each level above target, find nearest heading before it.
  -- Uses <= to handle skipped levels (e.g., H2 directly containing H5 with no H3/H4).
  local ancestors = {}
  local need = target_level - 1
  for i = #headings, 1, -1 do
    if headings[i].line < target_line and headings[i].level <= need then
      table.insert(ancestors, 1, headings[i].line)
      need = headings[i].level - 1
      if need == 0 then
        break
      end
    end
  end

  -- Rebuild folds with precise boundaries, then restore expr on next edit
  rebuild_manual_folds(headings)
  schedule_fold_restore()

  -- Close all folds
  vim.cmd('normal! zM')

  -- Open ancestor folds one level at a time (outermost to innermost)
  for _, line in ipairs(ancestors) do
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    vim.cmd('normal! zo')
  end

  -- Open target heading's section recursively, then collapse direct children
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd('normal! zO')

  -- Close all child heading folds (handles skipped levels like H2 > H5).
  -- After zO opens everything, close from top to bottom: first child closes
  -- and hides its descendants; subsequent descendants fail silently via pcall.
  for _, h in ipairs(headings) do
    if h.line > target_line then
      if h.level <= target_level then
        break -- past target's section
      end
      vim.api.nvim_win_set_cursor(0, { h.line, 0 })
      pcall(vim.cmd, 'normal! zc')
    end
  end
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })

  ensure_headings_visible(headings)
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })

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
  local cur = find_containing_heading(headings, vim.fn.line('.')).line
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
    -- Collapse all folds, saving cursor for restore on reopen
    local containing = find_containing_heading(headings, cur).line
    vim.b.zv_saved_cursor = vim.api.nvim_win_get_cursor(0)
    collapse_all_headings(headings)
    vim.api.nvim_win_set_cursor(0, { containing, 0 })
    vim.cmd('normal! zz')
    return
  end

  -- On a heading — toggle its fold
  if vim.fn.foldclosed('.') == -1 then
    -- Collapse all folds (clear stale saved cursor from prior case-1)
    vim.b.zv_saved_cursor = nil
    collapse_all_headings(headings)
    vim.api.nvim_win_set_cursor(0, { cur, 0 })
    vim.cmd('normal! zz')
  else
    focus_heading(headings, cur)
    -- Restore cursor position from prior zv collapse
    if vim.b.zv_saved_cursor then
      vim.api.nvim_win_set_cursor(0, vim.b.zv_saved_cursor)
      vim.b.zv_saved_cursor = nil
    end
  end
end

-- Buffer-local keymaps (override global fold cycling for markdown)
vim.keymap.set('n', 'zv', toggle_or_focus, { buf = 0, desc = 'Toggle heading fold / focus nearest' })

vim.keymap.set('n', 'zj', function()
  cycle_heading('next')
end, { buf = 0, desc = 'Next heading (cycle)' })

vim.keymap.set('n', 'zk', function()
  cycle_heading('prev')
end, { buf = 0, desc = 'Previous heading (cycle)' })

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
      local containing = find_containing_heading(headings, saved_cursor[1])
      focus_heading(headings, containing.line)
      vim.api.nvim_win_set_cursor(0, saved_cursor)
    end, 50)
  end,
})

-- ------------------------------------------------------------------------- }}}
