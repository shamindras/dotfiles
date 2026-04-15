-- {{{ Keymap Helper

-- Keymap helper which sets default options for silent and noremap to true
local function keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- }}}

-- {{{ Buffer Operations

-- Width-adaptive save: echo in wide windows, notify (auto-clears 1s) in narrow
keymap({ 'i', 'x', 'n', 's' }, '<C-s>', function()
  if vim.fn.expand('%') == '' then
    vim.cmd('stopinsert')
    vim.notify('No file to save', vim.log.levels.WARN)
    return
  end
  vim.cmd('silent w')
  vim.cmd('stopinsert')
  local msg = 'Saved ' .. vim.fn.expand('%')
  if #msg < vim.o.columns then
    vim.cmd('echo ' .. vim.fn.string(msg))
  else
    vim.notify(msg, vim.log.levels.INFO)
    vim.defer_fn(function()
      if package.loaded['mini.notify'] then
        require('mini.notify').clear()
      else
        vim.cmd('echo ""')
      end
    end, 1000)
  end
end, { desc = 'Save file' })
keymap('n', '<leader>bb', '<cmd>e #<cr>', { desc = '[b]uffer [b]ack (alternate)' })
keymap('n', '<leader>by', '<cmd>%y+<CR>', { desc = '[b]uffer [y]ank all' })
keymap('n', '<leader>bl', '<cmd>%d _<CR>', { desc = '[b]uffer c[l]ear (no copy)' })
keymap('n', '<leader>bc', '<cmd>%d<CR>', { desc = '[b]uffer [c]lear (with copy)' })
keymap('n', '<leader>bw', '<cmd>wall!<cr>', { desc = '[b]uffer [w]rite all' })

-- }}}

-- {{{ Delete to Black Hole

keymap({ 'n', 'v' }, '<leader>d', '"_d', { desc = '[d]elete to black hole' })

-- }}}

-- {{{ Buffer File Operations

local function rename_file()
  local old_name = vim.fn.expand('%')
  if old_name == '' then
    vim.notify('No file to rename', vim.log.levels.WARN)
    return
  end

  local new_name = vim.fn.input('New name: ', old_name, 'file')

  if new_name == '' or new_name == old_name then
    return
  end

  local ok, err = pcall(vim.fn.rename, old_name, new_name)
  if not ok then
    vim.notify('Rename failed: ' .. err, vim.log.levels.ERROR)
    return
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(new_name))
  vim.cmd('bdelete ' .. vim.fn.bufnr(old_name))
  vim.notify('Renamed: ' .. old_name .. ' � ' .. new_name)
end

local function make_executable()
  local file = vim.fn.expand('%')
  if file == '' then
    vim.notify('No file to make executable', vim.log.levels.WARN)
    return
  end

  vim.cmd('silent !chmod +x ' .. vim.fn.shellescape(file))
  vim.notify('Made executable: ' .. file)
end

keymap('n', '<leader>bx', make_executable, { desc = '[b]uffer chmod +[x]' })
keymap('n', '<leader>br', rename_file, { desc = '[b]uffer [r]ename file' })
keymap('n', '<leader>bp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end, { desc = '[b]uffer copy [p]ath' })
keymap('n', '<leader>bn', function()
  local name = vim.fn.expand('%:t')
  vim.fn.setreg('+', name)
  vim.notify('Copied: ' .. name)
end, { desc = '[b]uffer copy [n]ame' })
keymap('n', '<leader>bs', function()
  local stem = vim.fn.expand('%:t:r')
  vim.fn.setreg('+', stem)
  vim.notify('Copied: ' .. stem)
end, { desc = '[b]uffer copy [s]tem' })

-- }}}

-- {{{ Insert Operations

_G.put_empty_line = function(put_above)
  if type(put_above) == 'boolean' then
    vim.o.operatorfunc = 'v:lua.put_empty_line'
    vim.g.put_empty_line_above = put_above
    return 'g@l'
  end

  local target_line = vim.fn.line('.') - (vim.g.put_empty_line_above and 1 or 0)
  vim.fn.append(target_line, vim.fn['repeat']({ '' }, vim.v.count1))
end

keymap('n', '<leader>in', 'v:lua.put_empty_line(v:false)', { expr = true, desc = '[i]nsert line [n]ext (below)' })
keymap('n', '<leader>ip', 'v:lua.put_empty_line(v:true)', { expr = true, desc = '[i]nsert line [p]revious (above)' })

-- }}}

-- {{{ Paste (Register-Aware)

keymap('v', '<leader>p', '"_dP', { desc = '[p]aste (preserve register)' })

-- }}}

-- {{{ Quit Operations

keymap('n', '<leader>qa', '<cmd>qall!<cr>', { desc = '[q]uit [a]ll (force, no save)' })
keymap('n', '<leader>qs', '<cmd>wqall!<cr>', { desc = '[q]uit [s]ave all and exit' })

-- }}}

-- {{{ Search / Replace

keymap('n', '<leader>sr', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = '[s]earch [r]eplace word',
})
keymap('v', '<leader>sr', [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = '[s]earch [r]eplace word (selection)',
})

-- }}}

-- {{{ Toggle Operations

local function custom_toggle_line_numbers()
  if vim.o.relativenumber then
    vim.o.number = true
    vim.o.relativenumber = false
    vim.wo.numberwidth = 4
    vim.wo.signcolumn = 'yes'
  else
    vim.o.number = true
    vim.o.relativenumber = true
    vim.wo.numberwidth = nil
    vim.wo.signcolumn = 'yes'
  end
end

keymap('n', '<leader>tl', custom_toggle_line_numbers, { desc = '[t]oggle [l]ine numbers' })

keymap('n', '<leader>ts', function()
  vim.wo.spell = not vim.wo.spell
  if vim.wo.spell then
    vim.opt.spelllang = { 'en_au', 'en_gb' }
    vim.notify('Spell check enabled (en_AU/en_GB)')
  else
    vim.notify('Spell check disabled')
  end
end, { desc = '[t]oggle [s]pell check' })

-- }}}

-- {{{ Window Operations

local function toggle_window_maximize()
  local current_win = vim.api.nvim_get_current_win()
  local current_view = vim.fn.winsaveview()
  local is_maximized = vim.t.maximized_window == current_win

  if is_maximized then
    vim.cmd('wincmd =')
    vim.t.maximized_window = nil
  else
    vim.cmd('wincmd |')
    vim.cmd('wincmd _')
    vim.t.maximized_window = current_win
  end

  vim.fn.winrestview(current_view)
end

keymap('n', '<leader>we', '<C-w>=', { desc = '[w]indow [e]qualize' })
keymap('n', '<leader>wm', toggle_window_maximize, { desc = '[w]indow [m]aximize toggle' })
keymap('n', '<leader>wv', '<C-w>v', { desc = '[w]indow split [v]ertical' })
keymap('n', '<leader>wx', '<cmd>close<CR>', { desc = '[w]indow close [x]' })
keymap('n', '<leader>wz', '<C-w>s', { desc = '[w]indow split hori[z]ontal' })

-- }}}

-- {{{ Execute Operations

keymap('n', '<leader>xl', '<cmd>.lua<CR>', { desc = 'e[x]ecute [l]ine (Lua)' })
keymap('v', '<leader>xv', ':lua<CR>', { desc = 'e[x]ecute [v]isual (Lua)' })
keymap(
  'n',
  '<leader>xb',
  "<cmd>w<cr><cmd>luafile %<cr><cmd>echo 'Sourced ' . @%<cr>",
  { desc = 'e[x]ecute [b]uffer (source file)' }
)
keymap({ 'n', 'v' }, '<leader>xa', '<C-a>', { desc = 'e[x]ecute [a]dd (increment)' })
keymap({ 'n', 'v' }, '<leader>xx', '<C-x>', { desc = 'e[x]ecute decrement (C-[x])' })

-- }}}

-- {{{ Yank to Clipboard

keymap({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[y]ank to clipboard' })
keymap('n', '<leader>Y', '"+Y', { desc = '[y]ank line to clipboard' })

-- }}}

-- {{{ Editing Text

keymap('n', 'x', '"_x', { desc = 'Delete char (no copy)' })
keymap('n', 'X', '"_X', { desc = 'Delete back char (no copy)' })
keymap('n', 'c', '"_c', { desc = 'Change (no copy)' })
keymap('n', 'C', '"_C', { desc = 'Change to EOL (no copy)' })

keymap('v', '>', '>gv^', { desc = 'Indent right (stay in visual)' })
keymap('v', '<', '<gv^', { desc = 'Indent left (stay in visual)' })

keymap('n', '<C-c>', '"_ciW', { desc = 'Change in WORD (no copy)' })

keymap('i', '<Esc>', function()
  return vim.fn.col('.') == 1 and '<Esc>' or '<Esc>l'
end, { expr = true, desc = 'Exit insert (smart cursor)' })

-- }}}

-- {{{ Folding

-- Place cursor line near top (1 line of context), bypassing user's scrolloff.
-- Pins scrolloff=1 globally across the zt call, then restores via vim.schedule
-- so the next redraw uses scrolloff=1 before the user's value is reinstated.
local function zt_hard()
  local so = vim.o.scrolloff
  vim.o.scrolloff = 1
  vim.cmd('normal! zt')
  vim.schedule(function()
    vim.o.scrolloff = so
  end)
end

-- Collect top-level fold start lines (where foldlevel transitions from 0 to >0)
local function get_fold_starts()
  local starts = {}
  local last_line = vim.fn.line('$')
  for i = 1, last_line do
    if vim.fn.foldlevel(i) > 0 and (i == 1 or vim.fn.foldlevel(i - 1) == 0) then
      table.insert(starts, i)
    end
  end
  return starts
end

-- Find the fold start line containing the cursor (nearest start at or before cursor)
local function find_containing_fold_start(starts, cur)
  local containing = starts[1]
  for _, s in ipairs(starts) do
    if s <= cur then
      containing = s
    else
      break
    end
  end
  return containing
end

-- Check if any fold other than the current one is open
local function has_other_open_folds(starts, current_start)
  for _, s in ipairs(starts) do
    if s ~= current_start and vim.fn.foldclosed(s) == -1 then
      return true
    end
  end
  return false
end

-- Find next or previous fold start from cursor, with wrap-around
local function find_adjacent_fold_start(starts, cur, direction)
  if direction == 'next' then
    for _, s in ipairs(starts) do
      if s > cur then
        return s
      end
    end
    return starts[1]
  else
    for i = #starts, 1, -1 do
      if starts[i] < cur then
        return starts[i]
      end
    end
    return starts[#starts]
  end
end

-- Cycle to next/prev fold (shared logic for zj/zk)
local function cycle_fold(direction)
  local starts = get_fold_starts()
  if #starts == 0 then
    vim.notify('No folds in buffer', vim.log.levels.INFO)
    return
  end
  if #starts == 1 then
    vim.notify('Only fold in buffer', vim.log.levels.INFO)
    return
  end
  local cur = find_containing_fold_start(starts, vim.fn.line('.'))
  local target = find_adjacent_fold_start(starts, cur, direction)
  vim.cmd('normal! zM')
  vim.api.nvim_win_set_cursor(0, { target, 0 })
  vim.cmd('normal! zO')
  zt_hard()
end

keymap('n', 'zv', function()
  local starts = get_fold_starts()
  if #starts == 0 then
    vim.notify('No folds in buffer', vim.log.levels.INFO)
    return
  end

  local cur = vim.fn.line('.')

  if vim.fn.foldlevel('.') == 0 then
    -- Not on a fold — collapse all, jump to containing fold start
    local containing = find_containing_fold_start(starts, cur)
    vim.b.zv_saved_cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd('normal! zM')
    vim.api.nvim_win_set_cursor(0, { containing, 0 })
    zt_hard()
    return
  end

  local containing = find_containing_fold_start(starts, cur)

  if vim.fn.foldclosed('.') == -1 then
    -- Open fold — focus or collapse depending on other folds' state
    local others_open = has_other_open_folds(starts, containing)
    vim.b.zv_saved_cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd('normal! zM')
    vim.api.nvim_win_set_cursor(0, { containing, 0 })
    if others_open then
      -- Other folds open → focus: reopen just this fold, restore cursor
      vim.cmd('normal! zO')
      vim.api.nvim_win_set_cursor(0, vim.b.zv_saved_cursor)
    end
    zt_hard()
  else
    -- Closed fold → open, restore saved cursor
    vim.cmd('normal! zM')
    vim.api.nvim_win_set_cursor(0, { cur, 0 })
    vim.cmd('normal! zO')
    if vim.b.zv_saved_cursor then
      vim.api.nvim_win_set_cursor(0, vim.b.zv_saved_cursor)
      vim.b.zv_saved_cursor = nil
    end
    zt_hard()
  end
end, { desc = 'Toggle fold / focus nearest' })

keymap('n', 'zj', function()
  cycle_fold('next')
end, { desc = 'Next fold (cycle)' })

keymap('n', 'zk', function()
  cycle_fold('prev')
end, { desc = 'Previous fold (cycle)' })

-- }}}

-- {{{ Macros

-- Count-aware macro replay (e.g. 10Q runs 10@q).
keymap('n', 'Q', '@q', { desc = 'Execute macro q' })
keymap('v', 'Q', '<cmd>norm @q<cr>', { desc = 'Execute macro q on selection' })

-- }}}

-- {{{ Navigation

keymap({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down (display line)', expr = true })
keymap({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down (display line)', expr = true })
keymap({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up (display line)', expr = true })
keymap({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up (display line)', expr = true })

keymap({ 'n', 'o' }, 'H', '^', { desc = 'Start of line' })
keymap({ 'n', 'o' }, 'L', '$', { desc = 'End of line' })

keymap('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next search result' })
keymap({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
keymap('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Previous search result' })
keymap({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Previous search result' })

keymap('n', 'J', 'mzJ`z', { desc = 'Join lines (stay in place)' })
keymap('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
keymap('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- }}}

-- {{{ Treesitter Incremental Selection

keymap({ 'n', 'x', 'o' }, '<A-o>', function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require('vim.treesitter._select').select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = 'Select parent treesitter node (expand)' })

keymap({ 'n', 'x', 'o' }, '<A-i>', function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require('vim.treesitter._select').select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = 'Select child treesitter node (shrink)' })

-- }}}
