-- journal-layout.lua — split layout for the sesh `notes` journal window
--
-- Run by notes.sh as `nvim +'luafile <this file>' <today's daily note>`.
-- Reproduces the hand sequence <leader>wz, 5x<leader>wj, then `zv` on a
-- heading in each window and a step down to the first item. `zv` is
-- invoked through `:normal` (no bang, so mappings apply) — it is the
-- buffer-local heading focus + float-to-top from
-- config/nvim/ftplugin/markdown_folds.lua, reused as-is. Nothing in
-- config/nvim knows about this file; it exists only for the sesh session.

-- {{{ Config

-- Rows for the bottom (tasks) window.
local TASKS_HEIGHT = 8

-- sesh-reset creates the session detached at the terminal's full height; on
-- attach tmux's status line takes a row and nvim is resized, which recentres
-- the cursor in the non-current window. A resize inside this grace period
-- re-applies the layout once; later resizes are left alone.
local RESIZE_GRACE_MS = 3000

-- }}}

-- {{{ Helpers

-- All H2 headings in the current buffer: { line = <1-indexed>, title = <lowercase> }.
local function h2_headings()
  local found = {}
  for i, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local title = text:match('^##%s+(.-)%s*$')
    if title then
      found[#found + 1] = { line = i, title = title:lower() }
    end
  end
  return found
end

-- Pick the two headings: the first H2 titled "tasks" (any case) falls back
-- to the first H2; the "notes" target is the next H2 after it, falling back
-- to the last H2. No template wording or line numbers are assumed.
local function pick_targets(h2s)
  local tasks_idx = 1
  for i, h in ipairs(h2s) do
    if h.title:find('task', 1, true) then
      tasks_idx = i
      break
    end
  end
  return h2s[tasks_idx], h2s[tasks_idx + 1] or h2s[#h2s]
end

-- First non-blank line after `heading_line` that is still inside its
-- section (before the next heading of any level); the heading itself when
-- the section is empty.
local function first_item(heading_line)
  local lnum = vim.fn.nextnonblank(heading_line + 1)
  if lnum == 0 or vim.fn.getline(lnum):match('^#') then
    return heading_line
  end
  return lnum
end

-- In the current window: float the heading to the top with only its
-- section open (`zv`), then rest the cursor on the first item beneath it.
-- `zM` first so `zv` always takes its deterministic closed-heading branch
-- regardless of what the auto-collapse left behind.
local function focus_section(heading_line)
  vim.api.nvim_win_set_cursor(0, { heading_line, 0 })
  vim.cmd('normal! zM')
  vim.cmd('normal zv')
  vim.api.nvim_win_set_cursor(0, { first_item(heading_line), 0 })
end

-- }}}

-- {{{ Layout

-- Place both windows; `top`/`bottom` are window ids from the split. Each
-- window is made current for its `zv` (a `zt` issued via nvim_win_call on a
-- non-current window is applied late, against the moved cursor) and the
-- top window goes last so focus ends there.
local function place(top, bottom, tasks, notes)
  vim.api.nvim_set_current_win(bottom)
  focus_section(tasks.line)
  vim.api.nvim_set_current_win(top)
  focus_section(notes.line)
end

local function apply()
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('journal-layout: not a markdown buffer, skipping', vim.log.levels.WARN)
    return
  end
  local h2s = h2_headings()
  if #h2s == 0 then
    vim.notify('journal-layout: no H2 headings, skipping', vim.log.levels.WARN)
    return
  end
  local tasks, notes = pick_targets(h2s)

  local top = vim.api.nvim_get_current_win()
  vim.cmd('belowright ' .. TASKS_HEIGHT .. 'split')
  local bottom = vim.api.nvim_get_current_win()
  place(top, bottom, tasks, notes)

  local placed_at = vim.uv.now()
  vim.api.nvim_create_autocmd('VimResized', {
    once = true,
    desc = 'journal-layout: re-place windows after the attach-time resize',
    callback = function()
      if vim.uv.now() - placed_at > RESIZE_GRACE_MS then
        return
      end
      if vim.api.nvim_win_is_valid(top) and vim.api.nvim_win_is_valid(bottom) then
        place(top, bottom, tasks, notes)
      end
    end,
  })
end

-- Run from the first idle moment ('updatetime' after startup) rather than
-- a timer: a timer callback can fire inside lazy.nvim's startup `vim.wait`
-- (checker/git tasks), and a viewport set in that context is re-derived at
-- the next main-loop redraw, scrolling the cursor line back to the top.
-- CursorHold only fires from the idle main loop, which is also after
-- ftplugin/markdown_folds.lua's 50 ms auto-collapse, so this layout is the
-- last thing to touch fold state.
vim.api.nvim_create_autocmd('CursorHold', { once = true, callback = apply })

-- }}}
