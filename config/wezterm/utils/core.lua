-- {{{ Boilerplate

local M = {}

local default_shell = { '/bin/zsh', '-l' }

-- ------------------------------------------------------------------------- }}}

-- {{{ Configuration

---@param config table
---@return table
function M.setup(config)
  -- Ensure Homebrew is on PATH for direct command spawns (e.g. lazygit)
  -- Login shells rebuild PATH from zsh profile, but SpawnCommandInNewTab
  -- bypasses the shell and inherits WezTerm's launchd-minimal PATH
  config.set_environment_variables = {
    PATH = '/opt/homebrew/bin:/usr/local/bin:' .. os.getenv('PATH'),
  }

  -- Shell configuration
  config.default_prog = default_shell
  config.launch_menu = {
    {
      label = 'zsh',
      args = default_shell,
    },
  }

  -- Pane behavior
  config.pane_focus_follows_mouse = true

  return config
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return M

-- ------------------------------------------------------------------------- }}}
