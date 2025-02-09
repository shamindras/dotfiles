return {
  'folke/noice.nvim',
  event = 'VimEnter',
  dependencies = {
    'MunifTanjim/nui.nvim',
    {
      'echasnovski/mini.notify',
      version = false,
      opts = {
        -- Disable notifications since we're only using cmdline
        silent = true,
        lsp_progress = {
          enable = false,
        },
      },
    },
  },
  opts = {
    -- Disable everything by default
    notify = { enabled = false },
    lsp = { enabled = false },
    messages = { enabled = false },
    popupmenu = { enabled = false },
    -- Enable only cmdline with popup view
    cmdline = {
      enabled = true,
      view = 'cmdline_popup',
      format = {
        -- Default conceal is true
        cmdline = { pattern = '^:', icon = '', lang = 'vim' },
        search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
        search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
        filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
        lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' }, icon = '', lang = 'lua' },
        help = { pattern = '^:%s*he?l?p?%s+', icon = '' },
        input = { view = 'cmdline_input', icon = '?? ' },
      },
    },
    -- Configure view positioning
    views = {
      cmdline_popup = {
        position = {
          row = '10%',
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
      },
    },
    routes = {},
    presets = {
      -- Disable all presets
      bottom_search = false,
      command_palette = false,
      long_message_to_split = false,
      inc_rename = false,
      lsp_doc_border = false,
    },
  },
}
