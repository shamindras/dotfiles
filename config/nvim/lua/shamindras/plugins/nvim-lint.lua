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
      lua = { 'luacheck' },
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

    -- Configure shellcheck for multiple shell types
    lint.linters.shellcheck.args = {
      '--shell=bash',
      '--severity=warning',
    }

    -- Configure luacheck to use config from nvim config directory
    local config_path = vim.fn.stdpath('config')
    local luacheckrc_path = config_path .. '/.luacheckrc'

    if vim.fn.filereadable(luacheckrc_path) == 1 then
      lint.linters.luacheck.args = {
        '--config',
        luacheckrc_path,
      }
    end

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
    vim.keymap.set('n', '<leader>fl', function()
      require('lint').try_lint()
    end, { desc = '[f]ile [l]int (trigger)' })

    -- }}}
  end,
}
