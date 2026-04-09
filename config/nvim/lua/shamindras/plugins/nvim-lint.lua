-- {{{ Dependencies

-- Tool installation (linters + formatters + LSP) is centralized in
-- `lspconfig.lua` via a single mason-tool-installer.setup() call. This
-- plugin spec only configures the linter wiring; it does not own install
-- responsibility for any tool. Mason's PATH prepend ensures the bare
-- linter names below resolve to Mason-installed binaries at lint time.

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile', 'InsertLeave' },

  -- }}}

  -- {{{ Linter Configuration

  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      bash = { 'shellcheck' },
      cmake = { 'cmakelint' },
      json = { 'jsonlint' },
      lua = { 'selene' },
      markdown = { 'markdownlint-cli2' },
      python = { 'ruff' },
      sh = { 'shellcheck' },
      yaml = { 'yamllint' },
      zsh = { 'shellcheck' },
    }

    -- Local-first ruff: resolved per-lint-call against the active buffer's
    -- project root. nvim-lint's spawn code (eval(linter.cmd)) accepts a
    -- callable. Single source of truth for the registry lives in
    -- `lua/shamindras/util/project_local_resolver.lua`.
    lint.linters.ruff.cmd = function()
      return require('shamindras.util.project_local_resolver').resolve_tool('ruff')
    end

    -- markdownlint-cli2: switch from stdin to file-path mode AND pass
    -- `--config` explicitly. markdownlint-cli2 only looks in the file's
    -- own directory for configs — it does NOT walk up. nvim-lint spawns
    -- with cwd = buffer dir, so without `--config` a file in
    -- `~/Dropbox/notes/zk/ideas/foo.md` never sees
    -- `~/Dropbox/notes/zk/.markdownlint-cli2.yaml` one level above.
    -- We walk up from the buffer with `vim.fs.find` and inject the
    -- nearest config path as `--config <path>`.
    -- Per-call helper: find the nearest `.markdownlint-cli2.yaml` by
    -- walking up from the buffer's dir. Returned as an upvalue-shared
    -- closure so the three arg callbacks below agree on a single result.
    local function md_ctx()
      local bufname = vim.api.nvim_buf_get_name(0)
      local found = vim.fs.find(
        { '.markdownlint-cli2.yaml', '.markdownlint-cli2.yml', '.markdownlint-cli2.jsonc' },
        { upward = true, path = vim.fs.dirname(bufname) }
      )[1]
      return bufname, found
    end
    lint.linters['markdownlint-cli2'].stdin = false
    lint.linters['markdownlint-cli2'].stream = 'stderr'
    lint.linters['markdownlint-cli2'].args = {
      function()
        local _, found = md_ctx()
        return found and '--config' or vim.NIL
      end,
      function()
        local _, found = md_ctx()
        return found or vim.NIL
      end,
      function()
        local bufname = md_ctx()
        return bufname
      end,
    }
    -- File-path mode emits `<file>:<line>(:<col>)? <msg>` instead of the
    -- default `stdin:...`; rebuild the parser to match.
    lint.linters['markdownlint-cli2'].parser = require('lint.parser').from_errorformat(
      '%f:%l:%c %m,%f:%l %m',
      { source = 'markdownlint', severity = vim.diagnostic.severity.WARN }
    )

    -- Configure shellcheck for multiple shell types
    lint.linters.shellcheck.args = {
      '--shell=bash',
      '--severity=warning',
    }

    -- selene: discover `selene.toml` from cwd (upward walk), not from the
    -- buffer file — nvim-lint invokes selene from nvim's cwd, so when
    -- nvim is launched outside ~/.config/nvim the config is missed and
    -- `vim` falls back to undefined. Pass `--config` explicitly pinned
    -- to our nvim config dir.
    local selene_config = vim.fn.stdpath('config') .. '/selene.toml'
    table.insert(lint.linters.selene.args, 1, selene_config)
    table.insert(lint.linters.selene.args, 1, '--config')

    -- }}}

    -- {{{ Debounced Linting

    local DEBOUNCE_TIME = 100
    local timer = nil

    local function do_lint()
      local file_size = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local file_type = vim.bo.filetype

      if file_size < 100000 and not vim.tbl_contains({ 'binary', 'help' }, file_type) then
        require('lint').try_lint()
      end
    end

    local function schedule_lint()
      if timer then
        vim.fn.timer_stop(timer)
      end
      timer = vim.fn.timer_start(DEBOUNCE_TIME, function()
        vim.schedule(do_lint)
      end)
    end

    -- Set up autocommands for linting
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
      callback = function()
        schedule_lint()
      end,
    })

    -- Optional: Add keymapping for manual linting
    vim.keymap.set('n', '<leader>cl', function()
      require('lint').try_lint()
    end, { desc = '[c]ode [l]int' })

    -- }}}
  end,
}
