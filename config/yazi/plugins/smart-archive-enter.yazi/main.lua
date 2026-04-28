--- @since 25.5.31

-- smart-archive-enter: dirs -> enter; archives -> extract+cd; files -> open.
-- Replaces yazi-rs/plugins:smart-enter for the <Enter> binding so that
-- pressing Enter on an archive both extracts AND auto-cds into the result.
-- Backend: `unar -d` (always wraps multi-root archives in a containing
-- directory, so the cd target is deterministic).
--
-- NOTE: deliberately NOT annotated `--- @sync entry`. Subprocess calls via
-- `Command:output()` deadlock yazi when made from a sync entry context;
-- async (default) is correct. State is read through a `ya.sync` wrapper.

local ARCHIVE_EXTS = {
  zip = true,
  jar = true,
  rar = true,
  ['7z'] = true,
  tar = true,
  gz = true,
  tgz = true,
  bz2 = true,
  tbz2 = true,
  xz = true,
  txz = true,
  zst = true,
  tzst = true,
}

local function is_archive(name)
  local ext = name:match('%.([^.]+)$')
  return ext ~= nil and ARCHIVE_EXTS[ext:lower()] == true
end

local get_hovered = ya.sync(function()
  local h = cx.active.current.hovered
  if not h then
    return nil
  end
  return {
    name = h.name,
    is_dir = h.cha.is_dir,
    url = tostring(h.url),
    cwd = tostring(cx.active.current.cwd),
  }
end)

local function setup(self, opts)
  self.open_multi = opts and opts.open_multi
end

local function entry(self)
  local h = get_hovered()
  if not h then
    return
  end

  if h.is_dir then
    ya.emit('enter', { hovered = not self.open_multi })
    return
  end

  if not is_archive(h.name) then
    ya.emit('open', { hovered = not self.open_multi })
    return
  end

  local output, err =
    Command('unar'):arg({ '-d', '-r', '-o', h.cwd, h.url }):stdout(Command.PIPED):stderr(Command.PIPED):output()

  if err then
    ya.notify({
      title = 'smart-archive-enter',
      content = 'Failed to spawn unar: ' .. tostring(err),
      level = 'error',
      timeout = 5,
    })
    return
  end

  if not output.status.success then
    local msg = output.stderr
    if msg == nil or msg == '' then
      msg = output.stdout
    end
    ya.notify({
      title = 'Extract failed',
      content = msg,
      level = 'error',
      timeout = 5,
    })
    return
  end

  local extracted = output.stdout:match('Successfully extracted to "([^"]+)"')
  if not extracted then
    ya.notify({
      title = 'smart-archive-enter',
      content = 'Extracted, but could not parse target path from unar output.',
      level = 'warn',
      timeout = 5,
    })
    return
  end

  ya.emit('cd', { extracted })
end

return { entry = entry, setup = setup }
