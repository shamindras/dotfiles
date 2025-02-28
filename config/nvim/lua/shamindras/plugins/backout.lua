return {
  'AgusDOLARD/backout.nvim',
  event = { 'InsertEnter', 'CmdlineEnter' }, -- Load when entering insert mode or cmdline
  opts = {},
  keys = {
    -- Define your keybinds
    { '<A-h>', "<cmd>lua require('backout').back()<cr>", mode = { 'i', 'c' } },
    { '<A-l>', "<cmd>lua require('backout').out()<cr>", mode = { 'i', 'c' } },
  },
}
