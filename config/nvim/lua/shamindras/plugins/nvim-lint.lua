-- File: lua/shamindras/plugins/nvim-lint.lua
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    {
      'williamboman/mason.nvim',
      lazy = false,
      config = true,
      priority = 100,
    },
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      lazy = false,
      config = function()
        require('mason-tool-installer').setup {
          ensure_installed = {
            'cmakelint',
            'luacheck',
            'markdownlint-cli2',
            'shellcheck',
            'yamllint',
          },
          auto_update = true,
          run_on_start = true,
          automatic_installation = true,
        }
      end,
      priority = 90,
    },
  },
  config = function()
    local lint = require 'lint'

    -- Add mason bin path to ensure executables can be found
    local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
    vim.env.PATH = mason_bin .. ':' .. vim.env.PATH

    -- Configure linters per filetype
    lint.linters_by_ft = {
      cmake = { 'cmakelint' },
      python = { 'ruff' },
      lua = { 'luacheck' },
      bash = { 'shellcheck' },
      sh = { 'shellcheck' },
      zsh = { 'shellcheck' },
      yaml = { 'yamllint' },
      markdown = { 'markdownlint-cli2' },
    }

    -- Configure shellcheck for multiple shell types
    lint.linters.shellcheck.args = {
      '--shell=bash',
      '--severity=warning',
    }

    -- Configure luacheck to use config from nvim config directory
    local config_path = vim.fn.stdpath 'config'
    local luacheckrc_path = config_path .. '/.luacheckrc'

    if vim.fn.filereadable(luacheckrc_path) == 1 then
      lint.linters.luacheck.args = {
        '--config',
        luacheckrc_path,
      }
    end

    -- Set up debounced linting
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
    vim.keymap.set('n', '<leader>nl', function()
      require('lint').try_lint()
    end, { desc = 'Trigger linting for current file' })
  end,
}
