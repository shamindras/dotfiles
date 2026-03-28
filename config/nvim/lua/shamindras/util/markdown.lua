-- Shared markdown treesitter helpers for fold cycling, section moves, and heading operations.
-- Lazy-loaded via require('shamindras.util.markdown') — only runs for markdown buffers.

local M = {}

-- {{{ Heading Query ---------------------------------------------------------------------------

-- Cache the treesitter query (parsed once per nvim session, not per keypress)
local heading_query = vim.treesitter.query.parse('markdown', '(atx_heading) @heading')

-- Collect all ATX heading lines + levels via treesitter
-- Returns sorted list of { line = <1-indexed>, level = <1-6> }
function M.get_headings()
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

-- ------------------------------------------------------------------------- }}}

-- {{{ Heading Navigation ----------------------------------------------------------------------

-- Find next or previous heading from cursor, with wrap-around
function M.find_adjacent_heading(headings, cur, direction)
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

-- Find nearest heading by line distance
function M.find_nearest_heading(headings, cur)
  local nearest = headings[1]
  for _, h in ipairs(headings) do
    if math.abs(h.line - cur) < math.abs(nearest.line - cur) then
      nearest = h
    end
  end
  return nearest.line
end

-- Find the containing heading for a given line (nearest heading at or above cursor)
function M.find_containing_heading(headings, cur)
  local containing = nil
  for _, h in ipairs(headings) do
    if h.line <= cur then
      containing = h
    else
      break
    end
  end
  return containing
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Fold Management -------------------------------------------------------------------------

-- Open all folds in a line range (inclusive)
function M.open_folds_in_range(from, to)
  local saved = vim.api.nvim_win_get_cursor(0)
  for lnum = from, to do
    if vim.fn.foldclosed(lnum) ~= -1 then
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      vim.cmd('normal! zO')
    end
  end
  vim.api.nvim_win_set_cursor(0, saved)
end

-- Close all folds, open ancestor chain one level at a time, open target section
-- recursively, keep preamble (YAML/TOC) visible, center viewport.
function M.focus_heading(headings, target_line)
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
    M.open_folds_in_range(1, preamble_end)
  end

  vim.cmd('normal! zz')
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Section Operations ----------------------------------------------------------------------

-- Get line range for a section: from heading line to line before next same-or-higher-level heading
-- Returns (start_line, end_line) both 1-indexed, inclusive
function M.get_section_range(headings, heading)
  local start_line = heading.line
  local end_line = vim.fn.line('$')
  for _, h in ipairs(headings) do
    if h.line > start_line and h.level <= heading.level then
      end_line = h.line - 1
      break
    end
  end
  return start_line, end_line
end

-- Swap two sections by their line ranges. Cursor moves to the new position of the first section.
function M.swap_sections(section_a, section_b)
  -- Ensure section_a comes first in the buffer
  if section_a.start > section_b.start then
    section_a, section_b = section_b, section_a
  end

  local lines_a = vim.api.nvim_buf_get_lines(0, section_a.start - 1, section_a.stop, false)
  local lines_b = vim.api.nvim_buf_get_lines(0, section_b.start - 1, section_b.stop, false)

  -- Replace from bottom up to preserve line numbers
  vim.api.nvim_buf_set_lines(0, section_b.start - 1, section_b.stop, false, lines_a)
  vim.api.nvim_buf_set_lines(0, section_a.start - 1, section_a.stop, false, lines_b)
end

-- Move current section up or down past its same-level sibling
function M.move_section(direction)
  local headings = M.get_headings()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end

  local cur = vim.fn.line('.')
  local current = M.find_containing_heading(headings, cur)
  if not current then
    vim.notify('Not inside a heading section', vim.log.levels.INFO)
    return
  end

  -- Find same-level sibling in the given direction
  local sibling = nil
  if direction == 'down' then
    for _, h in ipairs(headings) do
      if h.line > current.line and h.level == current.level then
        sibling = h
        break
      end
    end
  else
    for i = #headings, 1, -1 do
      if headings[i].line < current.line and headings[i].level == current.level then
        sibling = headings[i]
        break
      end
    end
  end

  if not sibling then
    vim.notify('No sibling to swap with', vim.log.levels.INFO)
    return
  end

  local cur_start, cur_end = M.get_section_range(headings, current)
  local sib_start, sib_end = M.get_section_range(headings, sibling)

  -- Calculate cursor offset within current section
  local cursor_offset = cur - cur_start

  M.swap_sections(
    { start = cur_start, stop = cur_end },
    { start = sib_start, stop = sib_end }
  )

  -- Move cursor to new position of the swapped section
  local new_cursor
  if direction == 'down' then
    local new_start = sib_start + (sib_end - sib_start) - (cur_end - cur_start)
    new_cursor = new_start + cursor_offset
  else
    new_cursor = sib_start + cursor_offset
  end
  vim.api.nvim_win_set_cursor(0, { new_cursor, 0 })

  -- Rebuild folds: collapse all, focus the moved section (like zj/zk behavior)
  local new_headings = M.get_headings()
  if #new_headings > 0 then
    local containing = M.find_containing_heading(new_headings, new_cursor)
    if containing then
      M.focus_heading(new_headings, containing.line)
      vim.api.nvim_win_set_cursor(0, { new_cursor, 0 })
    end
  end
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Heading Level Cycling -------------------------------------------------------------------

-- Change heading level (promote or demote) for the heading containing the cursor.
-- direction: -1 to promote (fewer #), +1 to demote (more #). Clamped H1–H6.
function M.cycle_heading_level(direction)
  local headings = M.get_headings()
  if #headings == 0 then
    vim.notify('No headings in buffer', vim.log.levels.INFO)
    return
  end

  local current = M.find_containing_heading(headings, vim.fn.line('.'))
  if not current then
    vim.notify('Not inside a heading section', vim.log.levels.INFO)
    return
  end

  local new_level = math.max(1, math.min(6, current.level + direction))
  if new_level == current.level then
    return
  end

  local line = vim.fn.getline(current.line)
  local hashes = line:match('^(#+)')
  if not hashes then
    return
  end

  vim.fn.setline(current.line, string.rep('#', new_level) .. line:sub(#hashes + 1))
  -- Demoting nests the heading deeper; treesitter reparse with foldlevel=0 (from zM)
  -- would close the parent fold and snap the cursor. Open all folds to prevent snap.
  -- zj/zk will zM to rebuild fold state from scratch. Promote doesn't need this.
  if direction > 0 then
    vim.wo.foldlevel = 99
  end
end

-- ------------------------------------------------------------------------- }}}

return M
