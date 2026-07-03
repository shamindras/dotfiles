-- actions.lua — leader action table
--
-- Each leaf is { key, label, cmd, idle? }:
--   key   — single character bound inside the sub-modal
--   label — short name surfaced in errors / hs.console (not the HUD label;
--           HUD labels come from config/bin/leader-hud)
--   cmd   — shell command appended to "$HOME/.config/bin/"
--   idle  — optional override of the 2s timeout. Quit actions use 10s to let
--           sketchybar's quit notification finish drawing before another
--           leader sequence stomps it.

local M = {}

-- {{{ Helpers

-- Wrap a leader-hud-relative bin invocation. Most actions follow the same
-- form: layer-switch → hud hide → shell out. The Lua table only holds the
-- shell-out half; leader.lua appends the layer-switch + hud-hide.
local function bin(cmd)
  return '$HOME/.config/bin/' .. cmd
end

-- run-as-user prefix for actions that need to escape Hammerspoon's user
-- context to invoke something like /usr/bin/open via the console user.
-- Hammerspoon already runs as the console user, so this is a no-op
-- wrapper; the indirection stays because config/bin/leader-hud + friends
-- still rely on $SUDO_USER detection.
local function as_user(cmd)
  return bin('run-as-user ') .. cmd
end

local function url(u)
  return as_user("/usr/bin/open '" .. u .. "'")
end

-- }}}

-- {{{ Group: o — open apps (via fastopen)

M.open = {
  group_name = 'open',
  bindings = {
    { key = '1', label = '1password', cmd = bin('fastopen 1password') },
    { key = 'a', label = 'djview', cmd = bin('fastopen djview') },
    { key = 'b', label = 'firefox', cmd = bin('fastopen firefox') },
    { key = 'd', label = 'preview', cmd = bin('fastopen preview') },
    { key = 'e', label = 'finder', cmd = bin('fastopen finder') },
    { key = 'g', label = 'signal', cmd = bin('fastopen signal') },
    { key = 'i', label = 'books', cmd = bin('fastopen books') },
    { key = 'm', label = 'spotify', cmd = bin('fastopen spotify') },
    { key = 'n', label = 'nordvpn', cmd = bin('fastopen nordvpn --fullscreen N --return B') },
    { key = 'p', label = 'skim', cmd = bin('fastopen skim') },
    { key = 't', label = 'ghostty', cmd = bin('fastopen ghostty') },
    { key = 'q', label = 'textedit', cmd = bin('fastopen textedit') },
    { key = 's', label = 'vscode', cmd = bin('fastopen vscode') },
    { key = 'u', label = 'opensuperwhisper', cmd = bin('fastopen opensuperwhisper --fullscreen U --return B') },
    { key = 'v', label = 'vlc', cmd = bin('fastopen vlc') },
    { key = 'w', label = 'wezterm', cmd = bin('fastopen wezterm') },
    { key = 'x', label = 'jdownloader', cmd = bin('fastopen jdownloader') },
  },
}

-- }}}

-- {{{ Group: q — quit apps (via quit-app, idle=10s)

local QUIT_IDLE = 10000

M.quit = {
  group_name = 'quit',
  bindings = {
    { key = '1', label = '1Password', cmd = bin('quit-app 1Password B'), idle = QUIT_IDLE },
    { key = 'a', label = 'DjView', cmd = bin('quit-app DjView W'), idle = QUIT_IDLE },
    { key = 'b', label = 'Firefox', cmd = bin('quit-app Firefox W'), idle = QUIT_IDLE },
    { key = 'd', label = 'Preview', cmd = bin('quit-app Preview W'), idle = QUIT_IDLE },
    { key = 'e', label = 'Finder', cmd = bin('quit-app --activate-quit Finder W'), idle = QUIT_IDLE },
    { key = 'g', label = 'Signal', cmd = bin('quit-app Signal B'), idle = QUIT_IDLE },
    { key = 'i', label = 'Books', cmd = bin('quit-app Books B'), idle = QUIT_IDLE },
    { key = 'm', label = 'Spotify', cmd = bin('quit-app Spotify B'), idle = QUIT_IDLE },
    { key = 'n', label = 'NordVPN', cmd = bin('quit-app NordVPN B'), idle = QUIT_IDLE },
    { key = 'p', label = 'Skim', cmd = bin('quit-app Skim W'), idle = QUIT_IDLE },
    {
      key = 't',
      label = 'Ghostty',
      cmd = bin('quit-app Ghostty W --check wezterm-gui --fallback B'),
      idle = QUIT_IDLE,
    },
    { key = 'q', label = 'TextEdit', cmd = bin('quit-app TextEdit W --save-check Q'), idle = QUIT_IDLE },
    { key = 's', label = 'VSCode', cmd = bin('quit-app Code W'), idle = QUIT_IDLE },
    { key = 'u', label = 'OpenSuperWhisper', cmd = bin('quit-app OpenSuperWhisper W'), idle = QUIT_IDLE },
    { key = 'v', label = 'VLC', cmd = bin('quit-app VLC B'), idle = QUIT_IDLE },
    {
      key = 'w',
      label = 'WezTerm',
      cmd = bin('quit-app WezTerm T --check ghostty --fallback B'),
      idle = QUIT_IDLE,
    },
    { key = 'x', label = 'JDownloader', cmd = bin('quit-app JDownloader2 B'), idle = QUIT_IDLE },
  },
}

-- }}}

-- {{{ Group: c — Claude URLs

M.claude = {
  group_name = 'claude',
  bindings = {
    { key = 'n', label = 'new', cmd = url('https://claude.ai/new') },
    { key = 'r', label = 'recents', cmd = url('https://claude.ai/recents') },
    { key = 'u', label = 'usage', cmd = url('https://claude.ai/settings/usage') },
  },
}

-- }}}

-- {{{ Group: r — run utilities

M.run = {
  group_name = 'run',
  bindings = {
    { key = 'b', label = 'brew-update', cmd = bin('brew-update') },
    { key = 'c', label = 'close-notifications', cmd = as_user('$HOME/.config/bin/close-notifications') },
    {
      key = 'e',
      label = 'raycast-export',
      cmd = url('raycast://extensions/raycast/raycast/export-settings-data'),
    },
    {
      key = 'i',
      label = 'raycast-import',
      cmd = url('raycast://extensions/raycast/raycast/import-settings-data'),
    },
    {
      key = 'm',
      label = 'move-books',
      cmd = table.concat({
        as_user(
          '/opt/homebrew/bin/fd . $HOME/Downloads -e pdf -e djvu -x mv -v {} $HOME/Dropbox/resources/books/reference_books'
        ),
        as_user('/opt/homebrew/bin/fd . $HOME/Downloads -e epub -x mv -v {} $HOME/Dropbox/resources/books/ebooks'),
        as_user(
          '/opt/homebrew/bin/fd . $HOME/Dropbox/resources/books/reference_books -e epub -x mv -v {} $HOME/Dropbox/resources/books/ebooks'
        ),
      }, ' ; '),
    },
    { key = 'r', label = 'reload-hs', cmd = '/opt/homebrew/bin/hs -c "hs.reload()"' },
    { key = 't', label = 'empty-trash', cmd = bin('empty-trash') },
    {
      key = 'u',
      label = 'toggle-mute',
      cmd = as_user(
        "osascript -e 'set curVolume to get volume settings' "
          .. "-e 'if output muted of curVolume is false then' "
          .. "-e 'set volume with output muted' "
          .. "-e 'else' "
          .. "-e 'set volume without output muted' "
          .. "-e 'end if'"
      ),
    },
    {
      key = 'w',
      label = 'wipe-ds-store',
      cmd = table.concat({
        as_user(
          '/opt/homebrew/bin/fd -HI -t f .DS_Store $HOME/Dropbox/resources/books $HOME/Downloads $HOME/Documents -x rm'
        ),
        as_user('/opt/homebrew/bin/fd -HI -d 1 -t f .DS_Store $HOME -x rm'),
      }, ' ; '),
    },
  },
}

-- }}}

-- {{{ Group: s — search Raycast extensions

M.search = {
  group_name = 'search',
  bindings = {
    { key = 'b', label = 'bookmarks', cmd = url('raycast://extensions/raycast/browser-bookmarks/index') },
    { key = 'c', label = 'clipboard', cmd = url('raycast://extensions/raycast/clipboard-history/clipboard-history') },
    { key = 'f', label = 'files', cmd = url('raycast://extensions/raycast/file-search/search-files') },
  },
}

-- }}}

-- {{{ Group: g — GitHub URLs

M.github = {
  group_name = 'github',
  bindings = {
    { key = 'b', label = 'blog', cmd = url('https://github.com/shamindras/ss_personal_quarto_blog') },
    { key = 'c', label = 'codebox', cmd = url('https://github.com/shamindras/codebox') },
    { key = 'd', label = 'dotfiles', cmd = url('https://github.com/shamindras/dotfiles') },
    { key = 'g', label = 'profile', cmd = url('https://github.com/shamindras') },
    { key = 'n', label = 'nvim', cmd = url('https://github.com/shamindras/dotfiles/tree/main/config/nvim') },
  },
}

-- }}}

-- {{{ Group: u — personal URLs

M.urls = {
  group_name = 'urls',
  bindings = {
    { key = 'b', label = 'blog-posts', cmd = url('https://www.shamindras.com/posts') },
    { key = 'h', label = 'homepage', cmd = url('https://www.shamindras.com/') },
    -- Private-window Firefox (no run-as-user wrapper around -na args; let
    -- /usr/bin/open invoke it directly via the user context wrapper).
    {
      key = 'i',
      label = 'youtube',
      cmd = as_user("/usr/bin/open -na Firefox --args -private-window 'https://youtube.com'"),
    },
    { key = 'k', label = 'google-keep', cmd = url('https://keep.google.com/u/0/') },
    {
      key = 'w',
      label = 'brisbane-weather',
      cmd = url(
        'https://www.google.com/search?q=brisbane+weather&client=firefox-b-d&sca_esv=1a8f6c894285d156&sxsrf=AE3TifOl2N5wGjvwsTLrqZrmQoaHkX7GvA%3A1763829993058&ei=6eghafijA6u0qtsPvNGRkAY&ved=0ahUKEwi4vLjhmoaRAxUrmmoFHbxoBGIQ4dUDCBE&uact=5&oq=brisbane+weather&gs_lp=Egxnd3Mtd2l6LXNlcnAiEGJyaXNiYW5lIHdlYXRoZXIyCxAAGIAEGJECGIoFMggQABiABBixAzIGEAAYBxgeMgYQABgHGB4yBhAAGAcYHjIGEAAYBxgeMgYQABgHGB4yBRAAGIAEMgUQABiABDIGEAAYBxgeSK8SUMADWNUPcAJ4AZABAJgBswKgAfAQqgEFMi03LjG4AQPIAQD4AQGYAgSgArQEwgIKEAAYsAMY1gQYR8ICDRAAGIAEGLADGEMYigXCAhAQLhiABBiwAxhDGNQCGIoFmAMAiAYBkAYKkgcFMi4wLjKgB98xsgcDMi0yuAewBMIHBTAuMi4yyAcM&sclient=gws-wiz-serp'
      ),
    },
  },
}

-- }}}

-- {{{ Top-level leader: maps single letter → sub-group

-- Every other letter in the leader layer falls back to "return to base +
-- hide HUD", which leader.lua handles via the unbound-key fallback so we
-- do not enumerate it here.
M.leader_groups = {
  { key = 'o', name = 'open', target = M.open },
  { key = 'q', name = 'quit', target = M.quit },
  { key = 'c', name = 'claude', target = M.claude },
  { key = 'r', name = 'run', target = M.run },
  { key = 's', name = 'search', target = M.search },
  { key = 'g', name = 'github', target = M.github },
  { key = 'u', name = 'urls', target = M.urls },
}

-- }}}

return M
