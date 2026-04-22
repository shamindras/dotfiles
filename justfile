set shell := ['bash', '-eu', '-o', 'pipefail', '-c']
set export
export JUST_CHOOSER := 'fzf --preview "just --show {}" --preview-window=right:60%'

# Open interactive recipe picker with fzf preview of recipe bodies.
_default:
	@just --choose

# NOTE: we don't include update_submods or firefox_audit here;
# `just audit` is the home for read-only drift checks.
# Run cleanup, format, brewfile dump, firefox sync, treesitter sync, yazi upgrade.
all:
	@scripts/step outer 1 7 🧹 "Cleaning artifacts"
	@just clean
	@scripts/step outer 2 7 🎨 "Formatting Lua configs"
	@just stylua_config
	@scripts/step outer 3 7 🎨 "Formatting markdown"
	@just prettier_md
	@scripts/step outer 4 7 🍺 "Dumping Brewfile"
	@just update_brewfile
	@scripts/step outer 5 7 🦊 "Syncing Firefox"
	@just firefox_sync
	@scripts/step outer 6 7 🔄 "Syncing treesitter"
	@just treesitter_sync
	@scripts/step outer 7 7 🐱 "Upgrading yazi plugins"
	@just yazi_plugins_upgrade

# Read-only audit: firefox drift, treesitter parser status, yazi plugin list.
audit:
	@scripts/step outer 1 3 🔍 "Auditing Firefox"
	@just firefox_audit
	@scripts/step outer 2 3 🔄 "Checking treesitter parsers"
	@just treesitter_status
	@scripts/step outer 3 3 🐱 "Listing yazi plugins"
	@just yazi_plugins_list

# Format all Lua + markdown configs.
format:
	@scripts/step outer 1 2 🎨 "Formatting Lua configs"
	@just stylua_config
	@scripts/step outer 2 2 🎨 "Formatting markdown"
	@just prettier_md

# Show all targets grouped.
help:
	@just --list

# Sync firefox, treesitter, yazi plugins, submodules.
sync-all:
	@scripts/step outer 1 4 🦊 "Syncing Firefox"
	@just firefox_sync
	@scripts/step outer 2 4 🔄 "Syncing treesitter"
	@just treesitter_sync
	@scripts/step outer 3 4 🐱 "Upgrading yazi plugins"
	@just yazi_plugins_upgrade
	@scripts/step outer 4 4 📦 "Updating submodules"
	@just update_submods

# Format markdown files with prettier.
[group('format')]
prettier_md:
	@printf "🎨 Formatting markdown files with prettier...\n"
	@prettier --write . > /dev/null 2>&1
	@printf "✅ Markdown files formatted\n"

# Format all Lua config files with stylua.
[group('format')]
stylua_config:
	@printf "🎨 Formatting all Lua config files with stylua...\n"
	@fd . 'config/' -e lua -j 4 -x sh -c 'stylua "$1" > /dev/null 2>&1 || true' sh {}
	@printf "✅ Lua files formatted\n"

# Dump current Homebrew packages to Brewfile.
[group('packages')]
update_brewfile:
	@./scripts/ops/dump-brewfile

# Audit Firefox config for drift against tracked user.js/policies.json.
[group('firefox')]
firefox_audit:
	@printf "🔍 Auditing Firefox config for drift...\n"
	@./scripts/ops/audit-firefox

# Sync Firefox user.js, chrome/, policies.json to active profile.
[group('firefox')]
firefox_sync:
	@printf "🦊 Syncing Firefox config (user.js, chrome/, policies.json) to profile...\n"
	@./scripts/ops/setup-firefox
	@printf "✅ Firefox synced (restart Firefox for changes)\n"

# Show nvim-treesitter parser status (read-only).
[group('treesitter')]
treesitter_status:
	@./scripts/ops/setup-nvim-treesitter --status

# Update nvim-treesitter plugin + parsers, then show status.
[group('treesitter')]
treesitter_sync:
	@./scripts/ops/treesitter-sync

# Install missing + update outdated treesitter parsers, then show status.
[group('treesitter')]
treesitter_update:
	@./scripts/ops/setup-nvim-treesitter
	@printf "\n"
	@./scripts/ops/setup-nvim-treesitter --status

# Clear yazi preview cache.
[group('yazi')]
yazi_clear_cache:
	@printf "🧹 Clearing yazi preview cache...\n"
	@yazi --clear-cache
	@printf "✅ Yazi cache cleared\n"

# Install yazi plugins + flavors from package.toml (idempotent).
[group('yazi')]
yazi_plugins_install:
	@printf "🐱 Installing yazi plugins + flavors via ya pkg...\n"
	@ya pkg install
	@printf "✅ Yazi plugins installed\n"

# List installed yazi plugins + flavors.
[group('yazi')]
yazi_plugins_list:
	@ya pkg list

# Upgrade all yazi plugins + flavors to latest revisions.
[group('yazi')]
yazi_plugins_upgrade:
	@printf "🐱 Upgrading yazi plugins + flavors via ya pkg...\n"
	@ya pkg upgrade
	@printf "✅ Yazi plugins upgraded\n"

# Open Raycast export dialog. Save to config/raycast/Raycast.rayconfig (see config/raycast/CLAUDE.md).
[group('raycast')]
raycast_export:
	@printf "📤 Opening Raycast export dialog...\n"
	@open "raycast://extensions/raycast/raycast/export-settings-data"

# Open Raycast import dialog. Select config/raycast/Raycast.rayconfig (see config/raycast/CLAUDE.md).
[group('raycast')]
raycast_import:
	@printf "📥 Opening Raycast import dialog...\n"
	@open "raycast://extensions/raycast/raycast/import-settings-data"

# Pull latest submodule revisions.
[group('submodules')]
update_submods:
	@printf "📦 Pulling latest submodules...\n"
	git submodule update --recursive --remote
	@printf "✅ Submodules up to date\n"

# Sweep .DS_Store, swap files, stale zsh sessions.
[group('cleanup')]
clean:
	@./scripts/ops/clean-dotfiles
