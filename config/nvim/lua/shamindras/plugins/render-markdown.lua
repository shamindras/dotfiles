-- {{{ Render Markdown Configuration

return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = 'markdown',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-mini/mini.icons',
  },
  opts = {
    heading = {
      sign = false,
      icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
      backgrounds = {
        'Headline1Bg',
        'Headline2Bg',
        'Headline3Bg',
        'Headline4Bg',
        'Headline5Bg',
        'Headline6Bg',
      },
      foregrounds = {
        'Headline1Fg',
        'Headline2Fg',
        'Headline3Fg',
        'Headline4Fg',
        'Headline5Fg',
        'Headline6Fg',
      },
    },
    checkbox = {
      enabled = true,
      position = 'inline',
      unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
      checked = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked' },
    },
    code = {
      enabled = true,
      style = 'full',
      border = 'thin',
      highlight = 'RenderMarkdownCode',
    },
    link = {
      enabled = true,
      hyperlink = '󰌹 ',
      custom = {
        youtu = { pattern = 'youtu%.be', icon = '󰗃 ' },
        github = { pattern = 'github%.com', icon = '󰊤 ' },
      },
    },
  },
}

-- }}}
