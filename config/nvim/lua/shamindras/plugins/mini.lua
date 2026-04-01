return {
  'nvim-mini/mini.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'main',
      lazy = true,
    },
  },
  config = function()
    -- {{{ Text Editing

    local ai = require('mini.ai')
    ai.setup({
      n_lines = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),
        f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
        c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
      },
    })

    require('mini.operators').setup()
    require('mini.surround').setup()
    require('mini.move').setup()
    require('mini.pairs').setup()

    -- }}}

    -- {{{ General Workflow

    require('mini.bracketed').setup()

    local minifiles = require('mini.files')
    minifiles.setup({
      windows = {
        max_number = 3,
        preview = true,
        width_focus = 30,
        width_preview = 60,
      },
      options = {
        permanent_delete = false,
      },
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        vim.keymap.set('n', 'q', MiniFiles.close, { buf = buf_id, desc = 'Close Mini Files' })
      end,
    })

    vim.keymap.set('n', '<leader>fm', '<cmd>lua MiniFiles.open()<cr>', { desc = '[f]ile [m]ini files' })
    vim.keymap.set(
      'n',
      '<leader>fa',
      '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>',
      { desc = '[f]ile [a]ctive file' }
    )
    vim.keymap.set('n', '<leader>fh', "<cmd>lua MiniFiles.open('~')<cr>", { desc = '[f]ile [h]ome dir' })

    -- }}}

    -- {{{ Appearance

    require('mini.icons').setup()

    local statusline = require('mini.statusline')
    statusline.setup({ use_icons = vim.g.have_nerd_font })

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    -- {{{ Git branch caching and highlight

    local cached_branch = ''

    local function refresh_git_branch()
      local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
      if vim.v.shell_error == 0 and branch ~= '' then
        cached_branch = branch
      else
        cached_branch = ''
      end
    end

    -- Refresh on buffer/directory changes instead of every render
    local git_augroup = vim.api.nvim_create_augroup('MiniStatuslineGitBranch', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'DirChanged' }, {
      group = git_augroup,
      callback = refresh_git_branch,
    })

    -- Initial fetch
    refresh_git_branch()

    -- Define red highlight for main/master branches
    local function set_git_main_highlight()
      local devinfo_hl = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo', link = false })
      vim.api.nvim_set_hl(0, 'MiniStatuslineGitMainBranch', {
        fg = vim.api.nvim_get_hl(0, { name = 'DiagnosticError', link = false }).fg,
        bg = devinfo_hl.bg,
        bold = true,
      })
    end

    set_git_main_highlight()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = git_augroup,
      callback = set_git_main_highlight,
    })

    --- Return git branch display string and highlight group
    local function git_info()
      if cached_branch == '' then
        return '', 'MiniStatuslineDevinfo'
      end
      local text = '󰘬 ' .. cached_branch
      if cached_branch == 'main' or cached_branch == 'master' then
        return text, 'MiniStatuslineGitMainBranch'
      end
      return text, 'MiniStatuslineDevinfo'
    end

    -- }}}

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git, git_hl = git_info()
      local filename = statusline.section_filename({ trunc_width = 140 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
      local location = statusline.section_location({ trunc_width = 75 })

      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = git_hl, strings = { git } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { location } },
      })
    end

    local mini_notify = require('mini.notify')
    mini_notify.setup()
    vim.notify = mini_notify.make_notify()

    local hipatterns = require('mini.hipatterns')

    -- Define custom highlight groups for keywords not covered by built-in groups.
    -- Built-in: MiniHipatternsFixme, MiniHipatternsHack, MiniHipatternsTodo, MiniHipatternsNote
    -- Custom:   MiniHipatternsWarn, MiniHipatternsPerf, MiniHipatternsTest
    local function set_custom_highlight_groups()
      local function fg_from(group, fallback)
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        return hl.fg or fallback
      end

      vim.api.nvim_set_hl(0, 'MiniHipatternsWarn', {
        bg = fg_from('DiagnosticWarn', 0xFBBF24),
        fg = 0xFFFFFF,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'MiniHipatternsPerf', {
        bg = fg_from('Identifier', 0x7C3AED),
        fg = 0xFFFFFF,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'MiniHipatternsTest', {
        bg = fg_from('Identifier', 0xFF00FF),
        fg = 0xFFFFFF,
        bold = true,
      })
    end

    set_custom_highlight_groups()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('MiniHipatternsCustomHl', { clear = true }),
      callback = set_custom_highlight_groups,
    })

    -- Session-persistent toggle: true = comment-only (default), false = all matches
    vim.g.hipatterns_comment_only = true

    -- Check if a position is inside a treesitter @comment capture.
    -- Falls back to always-highlight when no treesitter parser is available.
    local function is_in_comment(buf_id, data)
      if not vim.g.hipatterns_comment_only then
        return true
      end
      local ok, parser = pcall(vim.treesitter.get_parser, buf_id)
      if not ok or not parser then
        return true
      end
      local row = data.line - 1
      local col = data.from_col - 1
      local captures = vim.treesitter.get_captures_at_pos(buf_id, row, col)
      for _, cap in ipairs(captures) do
        if cap.capture:match('^comment') then
          return true
        end
      end
      return false
    end

    -- Word-boundary pattern helper: matches whole-word KEYWORD only inside comments
    local function kw(word, hl_group)
      return {
        pattern = '%f[%w]()' .. word .. '()%f[%W]',
        group = function(buf_id, _, data)
          if is_in_comment(buf_id, data) then
            return hl_group
          end
          return nil
        end,
      }
    end

    hipatterns.setup({
      highlighters = {
        -- Primary keywords
        fixme = kw('FIXME', 'MiniHipatternsFixme'),
        hack = kw('HACK', 'MiniHipatternsHack'),
        todo = kw('TODO', 'MiniHipatternsTodo'),
        note = kw('NOTE', 'MiniHipatternsNote'),
        warn = kw('WARN', 'MiniHipatternsWarn'),
        perf = kw('PERF', 'MiniHipatternsPerf'),
        test = kw('TEST', 'MiniHipatternsTest'),

        -- Alternate keywords (match todo-comments.nvim defaults)
        bug = kw('BUG', 'MiniHipatternsFixme'),
        fixit = kw('FIXIT', 'MiniHipatternsFixme'),
        issue = kw('ISSUE', 'MiniHipatternsFixme'),
        info = kw('INFO', 'MiniHipatternsNote'),
        warning = kw('WARNING', 'MiniHipatternsWarn'),
        xxx = kw('XXX', 'MiniHipatternsWarn'),
        optim = kw('OPTIM', 'MiniHipatternsPerf'),
        optimize = kw('OPTIMIZE', 'MiniHipatternsPerf'),
        performance = kw('PERFORMANCE', 'MiniHipatternsPerf'),
        testing = kw('TESTING', 'MiniHipatternsTest'),
        passed = kw('PASSED', 'MiniHipatternsTest'),
        failed = kw('FAILED', 'MiniHipatternsTest'),
      },
    })

    -- }}}

    -- {{{ Keymap Discovery

    local miniclue = require('mini.clue')
    miniclue.setup({
      triggers = {
        { mode = 'n', keys = '<leader>' },
        { mode = 'x', keys = '<leader>' },
        { mode = 'i', keys = '<C-x>' },
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
        { mode = 'n', keys = '<C-w>' },
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
      },

      clues = {
        { mode = 'n', keys = '<leader>b', desc = '+[b]uffer' },
        { mode = 'n', keys = '<leader>d', desc = '+[d]elete (black hole)' },
        { mode = 'n', keys = '<leader>c', desc = '+[c]ode' },
        { mode = 'n', keys = '<leader>f', desc = '+[f]ile' },
        { mode = 'n', keys = '<leader>g', desc = '+[g]o/navigate' },
        { mode = 'n', keys = '<leader>i', desc = '+[i]nsert' },
        { mode = 'n', keys = '<leader>k', desc = '+[k]asten' },
        { mode = 'n', keys = '<leader>l', desc = '+[l]azy' },
        { mode = 'n', keys = '<leader>m', desc = '+[m]arkdown' },
        { mode = 'n', keys = '<leader>n', desc = '+[n]umber' },
        { mode = 'v', keys = '<leader>p', desc = '+[p]aste (register-aware)' },
        { mode = 'n', keys = '<leader>q', desc = '+[q]uit' },
        { mode = 'n', keys = '<leader>t', desc = '+[t]oggle' },
        { mode = 'n', keys = '<leader>w', desc = '+[w]indow' },
        { mode = 'n', keys = '<leader>x', desc = '+e[x]ecute' },
        { mode = 'n', keys = '<leader>y', desc = '+[y]ank (clipboard)' },
        { mode = 'v', keys = '<leader>y', desc = '+[y]ank (clipboard)' },
        { mode = 'n', keys = '<leader>s', desc = '+[s]earch' },
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      },
      window = {
        delay = 0,
        config = {
          width = 40,
          border = 'rounded',
        },
      },
    })

    -- }}}
  end,
}
