local M = {}

-- {{{ Layout Configuration

M.layout_config = {
  height = 0.7,
  preview_width = 0.6,
}

-- }}}

-- {{{ Custom Arguments for Pickers

-- Custom fd args for the find files picker
M.fd_args = {
  '--type',
  'f',
  '--strip-cwd-prefix',
  '--hidden',
  '--exclude',
  '.git',
  '--exclude',
  'node_modules',
  '--exclude',
  'submods',
  '--follow',
}

-- Custom ripgrep args for the grep picker (escaped glob patterns for zsh)
M.ripgrep_args = {
  '--color=never',
  '--no-heading',
  '--with-filename',
  '--line-number',
  '--column',
  '--smart-case',
  '--hidden',
  '--glob=!.git/*',
  '--glob=!node_modules/*',
  '--follow',
}

-- }}}

-- {{{ Ivy Layout Configuration

M.ivy_layout = {
  layout = {
    box = 'vertical',
    backdrop = false,
    row = -1,
    width = 0,
    height = M.layout_config.height,
    border = 'top',
    title = ' {title} {live} {flags}',
    title_pos = 'left',
    { win = 'input', height = 1, border = 'bottom' },
    {
      box = 'horizontal',
      { win = 'list', border = 'none' },
      {
        win = 'preview',
        title = '{preview}',
        width = M.layout_config.preview_width,
        border = 'left',
      },
    },
  },
}

-- }}}

-- {{{ Wrapper Functions

-- Wrapper function to apply ivy layout to a picker
function M.with_ivy_layout(picker_func, opts)
  opts = opts or {}
  opts.layouts = {
    ivy = M.ivy_layout,
  }
  opts.layout = 'ivy'
  opts.matcher = {
    sort_empty = true,
    cwd_bonus = true,
    frecency = true,
    history_bonus = true,
  }
  picker_func(opts)
end

-- Wrapper for the grep picker using ripgrep with custom args
function M.grep_with_ripgrep(opts)
  opts = opts or {}

  -- Remove the initial 'rg' from args since it's in cmd
  local grep_args = vim.list_extend({}, M.ripgrep_args)

  -- Merge passed options with our defaults
  opts.cmd = 'rg'
  opts.args = grep_args
  opts.layout = 'ivy'
  opts.layouts = {
    ivy = M.ivy_layout,
  }

  Snacks.picker.grep(opts)
end

-- Wrapper for the find files picker or smart picker using fd with custom args
function M.picker_with_fd(picker_func, opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = M.fd_args
  M.with_ivy_layout(picker_func, opts)
end

-- }}}

-- {{{ TODO Comments Picker

-- Keyword → highlight group mapping (matches mini.hipatterns config in mini.lua)
local todo_keyword_hl = {
  FIXME = 'MiniHipatternsFixme',
  BUG = 'MiniHipatternsFixme',
  FIXIT = 'MiniHipatternsFixme',
  ISSUE = 'MiniHipatternsFixme',
  TODO = 'MiniHipatternsTodo',
  HACK = 'MiniHipatternsHack',
  NOTE = 'MiniHipatternsNote',
  INFO = 'MiniHipatternsNote',
  WARN = 'MiniHipatternsWarn',
  WARNING = 'MiniHipatternsWarn',
  XXX = 'MiniHipatternsWarn',
  PERF = 'MiniHipatternsPerf',
  OPTIM = 'MiniHipatternsPerf',
  OPTIMIZE = 'MiniHipatternsPerf',
  PERFORMANCE = 'MiniHipatternsPerf',
  TEST = 'MiniHipatternsTest',
  TESTING = 'MiniHipatternsTest',
  PASSED = 'MiniHipatternsTest',
  FAILED = 'MiniHipatternsTest',
}

-- Keyword category groups for filtered pickers (deterministic order for badge detection)
local todo_keyword_groups = {
  TODO = { 'TODO' },
  FIXME = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
  NOTE = { 'NOTE', 'INFO' },
  WARN = { 'WARN', 'WARNING', 'XXX' },
  HACK = { 'HACK' },
  PERF = { 'PERF', 'OPTIM', 'OPTIMIZE', 'PERFORMANCE' },
  TEST = { 'TEST', 'TESTING', 'PASSED', 'FAILED' },
}

-- All keywords in priority order (primary first, then alternates)
local todo_all_keywords = {
  'TODO',
  'FIXME',
  'HACK',
  'NOTE',
  'WARN',
  'PERF',
  'TEST',
  'BUG',
  'FIXIT',
  'ISSUE',
  'INFO',
  'WARNING',
  'XXX',
  'OPTIM',
  'OPTIMIZE',
  'PERFORMANCE',
  'TESTING',
  'PASSED',
  'FAILED',
}

-- Build a comment-prefix-aware rg pattern for the given keywords.
-- Covers: // # -- /* <!-- ; % (C/JS/Python/Shell/Lua/CSS/HTML/Lisp/LaTeX)
local function build_todo_rg_pattern(keywords)
  return '(<!--|/\\*|//|--|#|;|%).*?\\b(' .. table.concat(keywords, '|') .. ')\\b'
end

-- Picker with colored keyword categories, pre-filtered to comment lines.
-- Uses Snacks.picker() with pre-loaded items so the input bar is clean.
-- @param filter string|nil  Category name (e.g. "TODO", "FIXME") to restrict results
function M.todo_comments_picker(filter)
  local keywords
  local title = 'Todo Comments'
  if filter and todo_keyword_groups[filter] then
    keywords = todo_keyword_groups[filter]
    title = filter .. ' Comments'
  else
    keywords = todo_all_keywords
  end

  local rg_pattern = build_todo_rg_pattern(keywords)
  local cmd = vim.list_extend({ 'rg' }, M.ripgrep_args)
  vim.list_extend(cmd, { '-e', rg_pattern })

  local output = vim.fn.systemlist(cmd)
  local items = {}
  -- Detect keyword from the filtered set first (deterministic order), avoiding
  -- false badges when a line contains multiple keywords (e.g. "TODO/FIXME").
  local detect_keywords = keywords
  for _, line in ipairs(output) do
    local file, lnum, col, text = line:match('^(.+):(%d+):(%d+):(.*)$')
    if file and lnum then
      local kw_match
      for _, kw in ipairs(detect_keywords) do
        if text:find('%f[%w]' .. kw .. '%f[%W]') then
          kw_match = kw
          break
        end
      end
      items[#items + 1] = {
        text = line,
        file = file,
        pos = { tonumber(lnum), tonumber(col) },
        keyword = kw_match,
        idx = #items + 1,
      }
    end
  end

  Snacks.picker({
    title = title,
    items = items,
    format = function(item, picker)
      local ret = require('snacks.picker.format').file(item, picker)
      if item.keyword and todo_keyword_hl[item.keyword] then
        table.insert(ret, { ' ' .. item.keyword .. ' ', todo_keyword_hl[item.keyword] })
      end
      return ret
    end,
    layout = 'ivy',
    layouts = { ivy = M.ivy_layout },
  })
end

-- }}}

-- {{{ Curated Colorscheme Picker

-- Picker showing only registered themes from util/themes.lua with live preview.
-- on_change applies each theme as you browse; on_close restores on cancel.
function M.colorscheme_picker()
  local theme_registry = require('shamindras.util.themes')
  local original_scheme = vim.g.colors_name or ''
  local confirmed = false

  -- Resolve active theme key via registry lookup (handles scheme name mismatches)
  local active_key = theme_registry.scheme_to_key[original_scheme]

  -- Build items from the curated theme list (idx preserves M.order)
  local items = {}
  for idx, key in ipairs(theme_registry.order) do
    local theme = theme_registry.themes[key]
    items[#items + 1] = {
      text = theme.scheme,
      idx = idx,
      theme_key = key,
    }
  end

  -- Load a theme plugin and apply its colorscheme.
  -- Updates _colorscheme_intended so the ColorschemeGuard allows the change.
  local function apply_theme(theme_key, scheme)
    local short_name = theme_registry.themes[theme_key].plugin:match('[^/]+$')
    require('lazy').load({ plugins = { short_name } })
    vim.g._colorscheme_intended = scheme
    pcall(vim.cmd.colorscheme, scheme)
  end

  -- Ivy layout without preview pane (live switching makes file preview unnecessary)
  local ivy_no_preview = {
    layout = {
      box = 'vertical',
      backdrop = false,
      row = -1,
      width = 0,
      height = M.layout_config.height,
      border = 'top',
      title = ' {title} {live} {flags}',
      title_pos = 'left',
      { win = 'input', height = 1, border = 'bottom' },
      { win = 'list', border = 'none' },
    },
  }

  Snacks.picker({
    title = 'Colorschemes',
    items = items,
    matcher = { sort_empty = false },
    format = function(item)
      local ret = { { item.text } }
      if item.theme_key == active_key then
        table.insert(ret, { ' (active)', 'DiagnosticHint' })
      end
      return ret
    end,
    layout = 'ivy',
    layouts = { ivy = ivy_no_preview },
    on_change = function(_picker, item)
      if item then
        vim.schedule(function()
          apply_theme(item.theme_key, item.text)
        end)
      end
    end,
    confirm = function(picker, item)
      confirmed = true
      picker:close()
      if item then
        vim.schedule(function()
          apply_theme(item.theme_key, item.text)
          vim.cmd.hi('Comment gui=none')

          -- Persist selection
          local state_file = vim.fn.stdpath('state') .. '/colorscheme_state.txt'
          local file = io.open(state_file, 'w')
          if file then
            file:write(item.theme_key)
            file:close()
          end
        end)
      end
    end,
    on_close = function()
      if not confirmed then
        -- Restore original colorscheme on cancel
        local orig_key = theme_registry.scheme_to_key[original_scheme]
        if orig_key then
          vim.schedule(function()
            apply_theme(orig_key, original_scheme)
          end)
        end
      end
    end,
  })
end

-- }}}

-- {{{ Buffers Picker

-- Helper function to configure and show the buffers picker
function M.buffers_picker(opts)
  opts = opts or {}
  Snacks.picker.buffers({
    -- I always want my buffers picker to start in normal mode
    on_show = function()
      vim.cmd.stopinsert()
    end,
    finder = 'buffers',
    format = 'buffer',
    hidden = false,
    unloaded = true,
    current = true,
    sort_lastused = true,
    win = {
      input = {
        keys = {
          ['d'] = 'bufdelete',
        },
      },
      list = { keys = { ['d'] = 'bufdelete' } },
    },
    -- In case you want to override the layout for this keymap
    layout = 'ivy',
  })
end

-- }}}

return M
