return {
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' }, -- Load when entering insert mode or cmdline
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        event = 'InsertEnter', -- Only load when entering insert mode
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {}, -- Removed friendly-snippets as it was commented out
        config = function()
          require('luasnip').config.setup {}
        end,
      },
      {
        'saadparwaiz1/cmp_luasnip',
        event = 'InsertEnter', -- Load with insert mode
      },
      {
        'hrsh7th/cmp-nvim-lsp',
        event = 'InsertEnter',
      },
      {
        'hrsh7th/cmp-path',
        event = { 'InsertEnter', 'CmdlineEnter' }, -- Load for both insert and cmdline
      },
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        performance = {
          debounce = 60, -- Delay completions to save CPU
          throttle = 30, -- Throttle completion menu updates
          fetching_timeout = 100, -- Timeout for completion requests
        },

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Optimize loading by setting a reasonable size limit
        completion = {
          completeopt = 'menu,menuone,noinsert',
          keyword_length = 2, -- Start completing after 2 characters
          max_item_count = 20, -- Limit number of suggestions
        },

        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },

        -- Prioritize sources and lazy load them
        sources = {
          {
            name = 'lazydev',
            group_index = 0,
            max_item_count = 20,
          },
          {
            name = 'nvim_lsp',
            max_item_count = 20,
            keyword_length = 3, -- Require more chars for LSP completions
            priority = 1000,
          },
          {
            name = 'luasnip',
            max_item_count = 10,
            priority = 750,
          },
          {
            name = 'path',
            max_item_count = 10,
            priority = 500,
            keyword_length = 3,
          },
        },

        -- Add view options to optimize performance
        view = {
          entries = { name = 'custom', selection_order = 'near_cursor' },
        },

        -- Add experimental features for better performance
        experimental = {
          ghost_text = false, -- Disable ghost text for better performance
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
