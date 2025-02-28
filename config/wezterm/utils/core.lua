-- modules/core.lua
local M = {}

function M.setup(config)
  -- Environment variables
  config.set_environment_variables = {
    PATH = '/usr/local/bin:' .. '/opt/homebrew/bin:' .. os.getenv('PATH'),
  }

  -- Shell configuration
  config.default_prog = { '/bin/zsh', '-l' }
  config.launch_menu = {
    {
      label = 'zsh',
      args = { '/bin/zsh', '-l' },
    },
  }

  -- Pane behavior
  config.pane_focus_follows_mouse = true

  return config
end

return M
