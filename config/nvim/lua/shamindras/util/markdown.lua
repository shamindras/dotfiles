-- Shared markdown treesitter helpers for fold cycling, section moves, and heading operations.
-- Lazy-loaded via require('shamindras.util.markdown') — only runs for markdown buffers.

local M = {}

-- {{{ Heading Query

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

-- }}}

-- {{{ Heading Navigation

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

-- }}}

-- {{{ Fold Management

-- Autocmd group for restoring expr foldmethod after manual fold cycling
-- Share the same augroup as ftplugin/markdown_folds.lua so clearing one
-- clears both — prevents stale restore autocmds from firing during swaps.
local fold_augroup = vim.api.nvim_create_augroup('MarkdownFoldRestore', { clear = true })

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

  -- Ensure all headings are visible as fold bars. A heading hidden inside a
  -- collapsed sibling fold (e.g., demoted H4 inside an H3 section) gets
  -- revealed by opening its parent fold. Content preamble folds prevent leak.
  -- foldclosed(line) == line means the heading IS a fold bar (visible);
  -- foldclosed(line) == other means it's hidden inside another fold.
  for _, h in ipairs(headings) do
    local fc = vim.fn.foldclosed(h.line)
    while fc ~= -1 and fc ~= h.line do
      vim.api.nvim_win_set_cursor(0, { fc, 0 })
      vim.cmd('normal! zo')
      fc = vim.fn.foldclosed(h.line)
    end
  end
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })

  -- Keep preamble open (YAML frontmatter, H1, TOC — lines 1 to just before second heading)
  local preamble_end = (headings[2] and headings[2].line or vim.fn.line('$')) - 1
  if preamble_end >= 1 then
    M.open_folds_in_range(1, preamble_end)
  end

  vim.cmd('normal! zz')
end

-- }}}

-- {{{ Section Operations

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

  -- Calculate cursor offset within current section (preserve line + column)
  local cursor_offset = cur - cur_start
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2]

  M.swap_sections({ start = cur_start, stop = cur_end }, { start = sib_start, stop = sib_end })

  -- Move cursor to new position of the swapped section
  local new_cursor
  if direction == 'down' then
    local new_start = sib_start + (sib_end - sib_start) - (cur_end - cur_start)
    new_cursor = new_start + cursor_offset
  else
    new_cursor = sib_start + cursor_offset
  end
  vim.api.nvim_win_set_cursor(0, { new_cursor, cursor_col })

  -- Rebuild folds: collapse all, focus the moved section (like zj/zk behavior).
  -- Clear fold-restore autocmd first — the swap's pending TextChanged would
  -- otherwise trigger it and reset foldmethod to expr with foldlevel=99,
  -- blowing all folds open. Re-register on next event loop tick (after the
  -- swap's TextChanged has passed).
  vim.api.nvim_clear_autocmds({ group = fold_augroup })
  local new_headings = M.get_headings()
  if #new_headings > 0 then
    local containing = M.find_containing_heading(new_headings, new_cursor)
    if containing then
      M.focus_heading(new_headings, containing.line)
      vim.api.nvim_win_set_cursor(0, { new_cursor, cursor_col })
      vim.api.nvim_clear_autocmds({ group = fold_augroup })
      vim.schedule(schedule_fold_restore)
    end
  end
end

-- }}}

-- {{{ Heading Level Cycling

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

  local saved_cursor = vim.api.nvim_win_get_cursor(0)
  vim.fn.setline(current.line, string.rep('#', new_level) .. line:sub(#hashes + 1))
  -- Temporarily open all folds to prevent cursor snap from treesitter reparse,
  -- then re-collapse and focus the changed heading (defer to let treesitter reparse)
  vim.wo.foldlevel = 99
  vim.defer_fn(function()
    -- focus_heading rebuilds manual folds from heading structure, bypassing
    -- any stale treesitter foldexpr boundaries
    local new_headings = M.get_headings()
    if #new_headings > 0 then
      local containing = M.find_containing_heading(new_headings, saved_cursor[1])
      if containing then
        M.focus_heading(new_headings, containing.line)
        vim.api.nvim_win_set_cursor(0, saved_cursor)
      end
    end
  end, 50)
end

-- }}}

return M
