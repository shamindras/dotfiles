--- @since 26.1.22

local M = {}

local THEME_FILE = os.getenv('HOME') .. '/.config/yazi/theme.toml'
local FLAVORS_GLOB = os.getenv('HOME') .. '/.config/yazi/flavors'

local function shell_pipe(cmd_str, prompt)
  local child, err = Command('sh')
    :arg('-c')
    :arg(cmd_str .. ' | fzf --prompt=' .. string.format('%q', prompt) .. ' --height=40% --layout=reverse')
    :stdin(Command.INHERIT)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()
  if not child then
    return nil, Err('Failed to spawn shell: %s', err)
  end
  local output, werr = child:wait_with_output()
  if not output then
    return nil, Err('Shell read error: %s', werr)
  elseif output.status.code == 130 or output.status.code == 1 then
    return nil, nil
  elseif not output.status.success then
    return nil, Err('fzf/shell exited with %s', output.status.code)
  end
  return (output.stdout:gsub('[\r\n]+$', '')), nil
end

local function write_theme(dark, light)
  local tmp = THEME_FILE .. '.tmp'
  local f, oerr = io.open(tmp, 'w')
  if not f then
    return Err('Cannot open %s: %s', tmp, oerr)
  end
  f:write('# A TOML linter such as https://taplo.tamasfe.dev/ can use this schema to validate your config.\n')
  f:write('# If you encounter any issues, please make an issue at https://github.com/yazi-rs/schemas.\n')
  f:write('"$schema" = "https://yazi-rs.github.io/schemas/theme.json"\n\n')
  f:write('[flavor]\n')
  f:write(string.format('dark  = "%s"\n', dark))
  f:write(string.format('light = "%s"\n', light))
  f:close()
  local ok, rerr = os.rename(tmp, THEME_FILE)
  if not ok then
    return Err('Rename failed: %s', rerr)
  end
  return nil
end

local function read_current_slots()
  local f = io.open(THEME_FILE, 'r')
  if not f then
    return 'catppuccin-mocha', 'catppuccin-latte'
  end
  local text = f:read('*a')
  f:close()
  local dark = text:match('dark%s*=%s*"([^"]+)"') or 'catppuccin-mocha'
  local light = text:match('light%s*=%s*"([^"]+)"') or 'catppuccin-latte'
  return dark, light
end

function M:entry()
  ya.emit('escape', { visual = true })

  local permit = ui.hide()

  local list_cmd = string.format("ls -1 %q 2>/dev/null | grep '\\.yazi$' | sed 's/\\.yazi$//' | sort", FLAVORS_GLOB)
  local flavor, err = shell_pipe(list_cmd, 'Flavor> ')
  if not flavor or flavor == '' then
    permit:drop()
    if err then
      ya.notify({ title = 'Flavor picker', content = tostring(err), timeout = 5, level = 'error' })
    end
    return
  end

  local slot, serr = shell_pipe("printf 'both\\ndark\\nlight\\n'", 'Slot> ')
  permit:drop()
  if not slot or slot == '' then
    if serr then
      ya.notify({ title = 'Flavor picker', content = tostring(serr), timeout = 5, level = 'error' })
    end
    return
  end

  local cur_dark, cur_light = read_current_slots()
  local new_dark, new_light = cur_dark, cur_light
  if slot == 'both' then
    new_dark, new_light = flavor, flavor
  elseif slot == 'dark' then
    new_dark = flavor
  elseif slot == 'light' then
    new_light = flavor
  end

  local werr = write_theme(new_dark, new_light)
  if werr then
    return ya.notify({
      title = 'Flavor picker',
      content = tostring(werr),
      timeout = 5,
      level = 'error',
    })
  end

  ya.notify({
    title = 'Flavor picker',
    content = string.format('Set %s → %s. Restarting yazi…', slot, flavor),
    timeout = 3,
    level = 'info',
  })
  ya.emit('quit', {})
end

return M
