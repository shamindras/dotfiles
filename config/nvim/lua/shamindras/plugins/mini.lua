return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      local ai = require 'mini.ai'
      local extras = require 'mini.extra'
      ai.setup {
        n_lines = 500,
        custom_textobjects = {
          -- TODO: check why `vaf` and `vao` are not working.
          f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
          o = ai.gen_spec.treesitter {
            a = { '@block.outer', '@loop.outer', '@conditional.outer' },
            i = { '@block.inner', '@loop.inner', '@conditional.inner' },
          },
          B = extras.gen_ai_spec.buffer(),
          D = extras.gen_ai_spec.diagnostic(),
          I = extras.gen_ai_spec.indent(),
          L = extras.gen_ai_spec.line(),
          N = extras.gen_ai_spec.number(),
        },
      }
      -- require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Insert matching pairs of `({[`
      require('mini.pairs').setup()

      require('mini.bracketed').setup()

      require('mini.move').setup {
        mappings = {
          left = 'H',
          right = 'L',
          down = 'J',
          up = 'K',
        },
      }

      -- require('mini.animate').setup()
      -- require('mini.indentscope').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
