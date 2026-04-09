-- {{{ Plugin Specs

return {
  {
    'folke/lazydev.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        build = ':MasonUpdate',
        config = true,
      },
      {
        -- Kept solely as the lspconfig-name <-> Mason-package-name registry.
        -- mason-tool-installer depends on this mapping (see its init.lua:178)
        -- to translate `lua_ls` -> `lua-language-server` etc. We disable its
        -- `automatic_enable` feature below: server attachment is driven by
        -- our `servers` table, not by what happens to be installed in Mason.
        'williamboman/mason-lspconfig.nvim',
      },
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
      },
    },
    config = function()
      -- {{{ Diagnostic Display

      vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        underline = { severity = vim.diagnostic.severity.WARN },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        -- virtual_text everywhere (truncated inline preview),
        -- virtual_lines on the current line only (full multiline detail).
        virtual_text = {
          spacing = 2,
          source = 'if_many',
          prefix = '●',
        },
        virtual_lines = { current_line = true },
        float = {
          border = 'rounded',
          source = true,
          header = '',
          prefix = '',
        },
      })

      -- }}}

      -- {{{ LSP Attach Keymaps

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspAttachKeymaps', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buf = event.buf, desc = desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          map('<leader>cd', vim.lsp.buf.definition, '[c]ode [d]efinition')
          map('<leader>cr', vim.lsp.buf.references, '[c]ode [r]eferences')
          map('<leader>ci', vim.lsp.buf.implementation, '[c]ode [i]mplementation')
          map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ctions')
          map('<leader>cn', vim.lsp.buf.rename, '[c]ode re[n]ame')
          map('<leader>ct', vim.lsp.buf.type_definition, '[c]ode [t]ype definition')
          map('<leader>cs', vim.lsp.buf.signature_help, '[c]ode [s]ignature help')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Diagnostic float: full message popup at cursor (inline virtual text
          -- can truncate). Bound to <leader>ce ([c]ode [e]rror/diagnostic).
          map('<leader>ce', vim.diagnostic.open_float, '[c]ode [e]rror/diagnostic float')

          -- Document and workspace symbol pickers via Snacks (fuzzy outline +
          -- workspace-wide symbol search). Uppercase S avoids collision with
          -- <leader>cs signature help.
          map('<leader>co', function()
            require('snacks').picker.lsp_symbols()
          end, '[c]ode [o]utline (document symbols)')
          map('<leader>cS', function()
            require('snacks').picker.lsp_workspace_symbols()
          end, '[c]ode workspace [S]ymbols')

          -- Inlay hints toggle — lives under <leader>t (toggle) namespace
          -- but defined here because it requires an LSP capability check.
          if client and client.server_capabilities.inlayHintProvider then
            vim.keymap.set('n', '<leader>ti', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, { buf = event.buf, desc = '[t]oggle [i]nlay hints' })
          end

          -- semantic highlight: supersedes mini.cursorword for this buffer
          if client and client.server_capabilities.documentHighlightProvider then
            vim.b[event.buf].minicursorword_disable = true
            local hl_group = vim.api.nvim_create_augroup('lsp-document-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = hl_group,
              callback = function()
                -- shared flag: toggled by <leader>tw in mini.lua
                if not vim.g.cursor_highlight_disable then
                  vim.lsp.buf.document_highlight()
                end
              end,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- clean up document highlight autocmds when LSP detaches
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('LspDetachCleanup', { clear = true }),
        callback = function(event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'lsp-document-highlight', buffer = event.buf })
          -- let mini.cursorword resume for this buffer
          vim.b[event.buf].minicursorword_disable = false
        end,
      })

      -- }}}

      -- {{{ Server Definitions

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local pt = require('shamindras.util.project_local_resolver')

      local servers = {
        lua_ls = {},
        marksman = {
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local zk_dir = vim.fn.getenv('ZK_NOTEBOOK_DIR')
            if zk_dir ~= vim.NIL and zk_dir ~= '' and vim.startswith(fname, zk_dir) then
              return -- skip zk notebooks → marksman won't attach
            end
            on_dir(require('lspconfig.util').root_pattern('.marksman.toml', '.git')(fname))
          end,
        },
        ty = {
          -- Local-first ty: project's .venv/bin/ty if available, Mason fallback otherwise.
          -- LSP starts once at session start, so resolve against cwd here. Files
          -- opened from outside their project will use the Mason ty; recovery is
          -- `:LspRestart` after cd-ing into the project.
          cmd = { pt.resolve_tool('ty', { cwd = vim.fn.getcwd() }), 'server' },
        },
      }

      -- }}}

      -- {{{ Mason Setup

      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✅',
            package_pending = '🟡',
            package_uninstalled = '❌',
          },
        },
      })

      -- mason-lspconfig: kept ONLY for its lspconfig <-> Mason-package name
      -- mapping (consumed by mason-tool-installer). `automatic_enable = false`
      -- disables its auto-attach feature, which would otherwise enable every
      -- installed Mason LSP package (pylsp, ruff, etc.) regardless of our
      -- `servers` table. No `ensure_installed`, no `handlers` -- those are
      -- owned by mason-tool-installer and the unified loop below.
      require('mason-lspconfig').setup({
        automatic_enable = false,
      })

      -- Unified per-server config + enable. nvim-lspconfig ships sane
      -- defaults in `lsp/<server>.lua`; vim.lsp.config() merges our
      -- overrides on top, vim.lsp.enable() starts the client.
      for name, cfg in pairs(servers) do
        cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, cfg.capabilities or {})
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end

      -- mason-tool-installer: single source of truth for every nvim-managed
      -- tool — LSP servers, linters, and formatters. Mason owns the global
      -- fallback for nvim-only tools; tools that are also shell-shared
      -- (jq, yq, shfmt, prettier, etc.) remain in Brewfile/npm in parallel
      -- so the shell context has its own canonical install. nvim resolves
      -- via Mason's PATH prepend regardless.
      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, {
        -- Linters (consumed by nvim-lint)
        'cmakelint',
        'jsonlint',
        'selene',
        'markdownlint-cli2',
        'ruff', -- also consumed by conform's ruff_format
        'shellcheck',
        'yamllint',
        -- Formatters (consumed by conform)
        'stylua',
        'shfmt',
        'prettier',
        'jq',
        'yq',
        'taplo',
      })

      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
        auto_update = true,
        run_on_start = true,
      })
      -- mason-tool-installer's plugin/ file registers a VimEnter autocmd to
      -- call run_on_start(). Since we load it lazily (BufReadPre), VimEnter
      -- has already fired by then and the autocmd never runs. Call it
      -- directly so missing tools install on first buffer open.
      require('mason-tool-installer').run_on_start()

      -- }}}
    end,
  },
}

-- }}}
