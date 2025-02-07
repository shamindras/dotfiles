return {

  -- Text editing plugins
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    keys = {
      { 'a', mode = { 'x', 'o' } },
      { 'i', mode = { 'x', 'o' } },
    },
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        init = function()
          -- Only load the queries, not the full plugin
          require('lazy.core.loader').disable_rtp_plugin 'nvim-treesitter-textobjects'
        end,
      },
    },
    opts = function()
      local ai = require 'mini.ai'
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }, {}),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
        },
      }
    end,
  },
  -- {
  --   'echasnovski/mini.ai',
  --   version = '*',
  --   event = 'VeryLazy', -- Load after startup
  --   config = function()
  --     require('mini.ai').setup()
  --   end,
  -- },
  {
    'echasnovski/mini.operators',
    version = '*',
    event = 'VeryLazy', -- Load after startup
    config = function()
      require('mini.operators').setup()
    end,
  },
  {
    'echasnovski/mini.surround',
    version = '*',
    event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
    config = function()
      require('mini.surround').setup()
    end,
  },
  {
    'echasnovski/mini.move',
    version = '*',
    event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
    config = function()
      require('mini.move').setup {
        mappings = {
          left = 'H',
          right = 'L',
          down = 'J',
          up = 'K',
        },
      }
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = '*',
    event = 'InsertEnter', -- Load when entering insert mode
    config = function()
      require('mini.pairs').setup()
    end,
  },

  -- General workflow plugins
  {
    'echasnovski/mini.bracketed',
    version = '*',
    event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
    config = function()
      require('mini.bracketed').setup()
    end,
  },
  {
    'echasnovski/mini.files',
    version = '*',
    cmd = {
      'MiniFiles',
      'MiniFilesBufferDir',
      'MiniFilesCursorFile',
    },
    keys = {
      {
        '<leader>fm',
        '<cmd>lua MiniFiles.open()<cr>',
        desc = 'Open Mini Files',
      },
      {
        '<leader>fe',
        '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>',
        desc = 'Mini Files Current File',
      },
      {
        '<leader>fh',
        "<cmd>lua MiniFiles.open('~')<cr>",
        desc = 'Mini Files Home Dir',
      },
    },
    config = function()
      local minifiles = require 'mini.files'
      minifiles.setup {
        -- Customize windows
        windows = {
          -- Maximum number of windows to show side by side
          max_number = 3,
          -- Whether to show preview of file/directory under cursor
          preview = true,
          -- Width of focused window
          width_focus = 30,
          -- Width of non-focused window
          width_nofocus = 15,
          -- Width of preview window
          width_preview = 60,
          -- Use mini.icons for file icons
          use_icons = true,
        },
        options = {
          -- Whether to delete permanently or move into trash
          permanent_delete = false,
          -- Whether to use for editing directories
          use_as_default_explorer = true,
        },
      }

      -- Add split window functionality
      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          -- Make new window and set it as target
          local new_target_window
          vim.api.nvim_win_call(minifiles.get_target_window(), function()
            vim.cmd(direction .. ' split')
            new_target_window = vim.api.nvim_get_current_win()
          end)

          minifiles.set_target_window(new_target_window)
        end

        -- Adding buffer-local mapping
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. direction })
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Add mappings only for mini.files buffer
          map_split(buf_id, 'gs', 'horizontal') -- Go Split
          map_split(buf_id, 'gv', 'vertical')   -- Go Vertical

          -- Add quit mappings
          vim.keymap.set('n', 'q', MiniFiles.close, { buffer = buf_id, desc = 'Close Mini Files' })
          vim.keymap.set('n', 'Q', function()
            MiniFiles.close()
            -- Ensure all mini.files windows are closed
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_name:match 'mini.files' then
                vim.api.nvim_win_close(win, true)
              end
            end
          end, { buffer = buf_id, desc = 'Force Close Mini Files' })
        end,
      })
    end,
  },

  -- Appearance plugins
  {
    'echasnovski/mini.statusline',
    version = '*',
    event = 'VimEnter', -- Load when Vim starts
    config = function()
      -- Simple and easy statusline
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- Configure cursor location section to show LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- Add mini.icons plugin
  {
    'echasnovski/mini.icons',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('mini.icons').setup()
    end,
  },
}
