-- Keymaps

-- {{{ Keymap Helper

-- Keymap helper which sets default options for silent and noremap to true
local function keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ------------------------------------------------------------------------- }}}

-- {{{ [b]uffer Operations

keymap({ 'i', 'x', 'n', 's' }, '<C-s>', "<cmd>w<cr><esc><cmd>echo 'Saved ' . @%<cr>", { desc = 'Save file' })
keymap('n', '<leader>bb', '<cmd>e #<cr>', { desc = '[b]uffer [b]ack (alternate)' })
keymap('n', '<leader>by', '<cmd>%y+<CR>', { desc = '[b]uffer [y]ank all' })
keymap('n', '<leader>bl', '<cmd>%d _<CR>', { desc = '[b]uffer c[l]ear (no copy)' })
keymap('n', '<leader>bc', '<cmd>%d<CR>', { desc = '[b]uffer [c]lear (with copy)' })
keymap('n', '<leader>bw', '<cmd>wall!<cr>', { desc = '[b]uffer [w]rite all' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [n]umber Operations

keymap({ 'n', 'v' }, '<leader>na', '<C-a>', { desc = '[n]umber [a]dd (increment)' })
keymap({ 'n', 'v' }, '<leader>nx', '<C-x>', { desc = '[n]umber subtrac[x]t (decrement)' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [d]elete to Black Hole

keymap({ 'n', 'v' }, '<leader>d', '"_d', { desc = '[d]elete to black hole' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [f]ile Operations

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

keymap('n', '<leader>fx', make_executable, { desc = '[f]ile e[x]ecutable (chmod +x)' })
keymap('n', '<leader>fr', rename_file, { desc = '[f]ile [r]ename' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [g]o/Navigate

keymap({ 'n', 'x' }, '<leader>gx', function()
  if _G.MiniOperators then
    local gx_keymap = vim.fn.maparg('gX', 'n', false, true)
    if gx_keymap.callback then
      gx_keymap.callback()
    end
  else
    vim.cmd('normal! gx')
  end
end, { desc = '[g]o open lin[x]/link' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [i]nsert Operations

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

-- ------------------------------------------------------------------------- }}}

-- {{{ [l]azy Plugin Manager

keymap('n', '<leader>ll', '<cmd>Lazy<cr>', { desc = '[l]azy menu' })
keymap('n', '<leader>lu', '<cmd>Lazy update<cr>', { desc = '[l]azy [u]pdate' })
keymap('n', '<leader>lp', '<cmd>Lazy profile<cr>', { desc = '[l]azy [p]rofile' })
keymap('n', '<leader>ls', '<cmd>Lazy sync<cr>', { desc = '[l]azy [s]ync' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [p]aste (Register-Aware)

keymap('v', '<leader>p', '"_dP', { desc = '[p]aste (preserve register)' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [q]uit Operations

keymap('n', '<leader>qa', '<cmd>qall!<cr>', { desc = '[q]uit [a]ll (force, no save)' })
keymap('n', '<leader>qs', '<cmd>wqall!<cr>', { desc = '[q]uit [s]ave all and exit' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [t]oggle Operations

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

keymap('n', '<leader>tn', custom_toggle_line_numbers, { desc = '[t]oggle line [n]umbers' })

keymap('n', '<leader>ts', function()
  vim.wo.spell = not vim.wo.spell
  if vim.wo.spell then
    vim.opt.spelllang = { 'en_au', 'en_gb' }
    vim.notify('Spell check enabled (en_AU/en_GB)')
  else
    vim.notify('Spell check disabled')
  end
end, { desc = '[t]oggle [s]pell check' })

-- ------------------------------------------------------------------------- }}}

-- {{{ [w]indow Operations

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
keymap('n', '<leader>wh', '<C-w>s', { desc = '[w]indow split [h]orizontal' })
keymap('n', '<leader>wm', toggle_window_maximize, { desc = '[w]indow [m]aximize toggle' })
keymap('n', '<leader>wv', '<C-w>v', { desc = '[w]indow split [v]ertical' })
keymap('n', '<leader>wx', '<cmd>close<CR>', { desc = '[w]indow close [x]' })

-- ------------------------------------------------------------------------- }}}

-- {{{ E[x]ecute Operations

keymap('n', '<leader>xl', '<cmd>.lua<CR>', { desc = 'e[x]ecute [l]ine (Lua)' })
keymap('v', '<leader>xv', '<cmd>.lua<CR>', { desc = 'e[x]ecute [v]isual (Lua)' })
keymap(
  'n',
  '<leader>xb',
  "<cmd>w<cr><cmd>luafile %<cr><cmd>echo 'Sourced ' . @%<cr>",
  { desc = 'e[x]ecute [b]uffer (source file)' }
)

-- ------------------------------------------------------------------------- }}}

-- {{{ [y]ank to Clipboard

keymap({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[y]ank to clipboard' })
keymap('n', '<leader>Y', '"+Y', { desc = '[y]ank line to clipboard' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Editing Text

keymap('n', 'x', '"_x', { desc = 'Delete char (no copy)' })
keymap('n', 'X', '"_X', { desc = 'Delete back char (no copy)' })
keymap('n', 'c', '"_c', { desc = 'Change (no copy)' })
keymap('n', 'C', '"_C', { desc = 'Change to EOL (no copy)' })

keymap('v', '>', '>gv^', { desc = 'Indent right (stay in visual)' })
keymap('v', '<', '<gv^', { desc = 'Indent left (stay in visual)' })

keymap('n', '<C-c>', 'ciW', { desc = 'Change in WORD' })

keymap('i', '<Esc>', function()
  return vim.fn.col('.') == 1 and '<Esc>' or '<Esc>l'
end, { expr = true, desc = 'Exit insert (smart cursor)' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Folding

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

keymap('n', 'zv', function()
  if vim.fn.foldlevel('.') == 0 then
    -- Not on a fold — move to nearest fold (prefer next like zj)
    local starts = get_fold_starts()
    if #starts == 0 then
      vim.notify('No folds in buffer', vim.log.levels.INFO)
      return
    end
    local cur = vim.fn.line('.')
    local target
    for _, start in ipairs(starts) do
      if start > cur then
        target = start
        break
      end
    end
    if not target then
      target = starts[1]
    end
    vim.api.nvim_win_set_cursor(0, { target, 0 })
    vim.cmd('normal! zMzvzz')
    return
  end

  -- On a fold — toggle
  if vim.fn.foldclosed('.') == -1 then
    vim.cmd('normal! zc')
  else
    vim.cmd('normal! zOzz')
  end
end, { desc = 'Toggle fold / focus nearest' })

keymap('n', 'zj', function()
  local starts = get_fold_starts()
  if #starts == 0 then
    vim.notify('No folds in buffer', vim.log.levels.INFO)
    return
  end
  if #starts == 1 then
    vim.notify('Only fold in buffer', vim.log.levels.INFO)
    return
  end

  -- Close current fold if open
  if vim.fn.foldclosed('.') == -1 and vim.fn.foldlevel('.') > 0 then
    vim.cmd('normal! zc')
  end

  local cur = vim.fn.line('.')
  for _, start in ipairs(starts) do
    if start > cur then
      vim.api.nvim_win_set_cursor(0, { start, 0 })
      vim.cmd('normal! zOzz')
      return
    end
  end

  -- Cycle to first fold
  vim.api.nvim_win_set_cursor(0, { starts[1], 0 })
  vim.cmd('normal! zOzz')
end, { desc = 'Next fold (cycle)' })

keymap('n', 'zk', function()
  local starts = get_fold_starts()
  if #starts == 0 then
    vim.notify('No folds in buffer', vim.log.levels.INFO)
    return
  end
  if #starts == 1 then
    vim.notify('Only fold in buffer', vim.log.levels.INFO)
    return
  end

  -- Close current fold if open
  if vim.fn.foldclosed('.') == -1 and vim.fn.foldlevel('.') > 0 then
    vim.cmd('normal! zc')
  end

  local cur = vim.fn.line('.')
  for i = #starts, 1, -1 do
    if starts[i] < cur then
      vim.api.nvim_win_set_cursor(0, { starts[i], 0 })
      vim.cmd('normal! zOzz')
      return
    end
  end

  -- Cycle to last fold
  vim.api.nvim_win_set_cursor(0, { starts[#starts], 0 })
  vim.cmd('normal! zOzz')
end, { desc = 'Previous fold (cycle)' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Macros

-- Count-aware macro replay (e.g. 10Q runs 10@q).
keymap('n', 'Q', '@q', { desc = 'Execute macro q' })
keymap('v', 'Q', '<cmd>norm @q<cr>', { desc = 'Execute macro q on selection' })

-- ------------------------------------------------------------------------- }}}

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

-- ------------------------------------------------------------------------- }}}
