return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        -- 'html',
        -- 'json',
        'lua',
        -- 'make',
        'markdown',
        -- 'markdown_inline',
        'python',
        -- 'toml',
        -- 'yaml',
      },
      -- Autoinstall languages that are not installed
      -- auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<Enter>',
          node_incremental = '<Enter>',
          scope_incremental = false,
          node_decremental = '<BS>',
        },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
