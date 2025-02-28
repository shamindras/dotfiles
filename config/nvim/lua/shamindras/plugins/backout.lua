return {
  'AgusDOLARD/backout.nvim',
  event = { 'InsertEnter', 'CmdlineEnter' },
  opts = {},
  keys = {
    { '<A-h>', "<cmd>lua require('backout').back()<cr>", mode = { 'i', 'c' } },
    { '<A-l>', "<cmd>lua require('backout').out()<cr>", mode = { 'i', 'c' } },
  },
}
