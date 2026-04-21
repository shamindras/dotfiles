set shell := ['bash', '-eu', '-o', 'pipefail', '-c']
set export
export JUST_CHOOSER := 'fzf --preview "just --show {}" --preview-window=right:60%'

# Open interactive recipe picker with fzf preview of recipe bodies.
_default:
	@just --choose

# NOTE: we don't include update_submods here.
# Run cleanup, format, brewfile dump, firefox sync+audit, treesitter sync, yazi upgrade.
all:
	@scripts/step outer 1 8 🧹 "Cleaning artifacts"
	@just clean
	@scripts/step outer 2 8 🎨 "Formatting Lua configs"
	@just stylua_config
	@scripts/step outer 3 8 🎨 "Formatting markdown"
	@just prettier_md
	@scripts/step outer 4 8 🍺 "Dumping Brewfile"
	@just update_brewfile
	@scripts/step outer 5 8 🦊 "Syncing Firefox"
	@just firefox_sync
	@scripts/step outer 6 8 🔍 "Auditing Firefox"
	@just firefox_audit
	@scripts/step outer 7 8 🔄 "Syncing treesitter"
	@just treesitter_sync
	@scripts/step outer 8 8 🐱 "Upgrading yazi plugins"
	@just yazi_plugins_upgrade

# Format markdown files with prettier.
[group('format')]
prettier_md:
	@printf "🎨 Formatting markdown files with prettier...\n"
	@prettier --write . > /dev/null 2>&1
	@printf "✅ Markdown files formatted!\n"

# Format all Lua config files with stylua.
[group('format')]
stylua_config:
	@printf "🎨 Formatting all Lua config files with stylua...\n"
	@fd . 'config/' -e lua -j 4 -x sh -c 'stylua "$1" > /dev/null 2>&1 || true' sh {}
	@printf "✅ Lua files formatted!\n"

# Dump current Homebrew packages to Brewfile.
[group('packages')]
update_brewfile:
	@printf "🍺 Dumping current Homebrew packages to Brewfile...\n"
	# Strip cargo from PATH so brew doesn't invoke the rustup shim, which
	# errors in subprocesses where it can't resolve the default toolchain.
	# Rust/cargo is managed separately via rustup, not the Brewfile.
	@PATH="$(echo "$PATH" | tr ':' '\n' | grep -v cargo | tr '\n' ':')" brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf "✅ Brewfile saved to ./config/brew/Brewfile\n"

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
	@printf "✅ Firefox synced! Restart Firefox for changes.\n"

# Show nvim-treesitter parser status (read-only).
[group('treesitter')]
treesitter_status:
	@./scripts/ops/setup-nvim-treesitter --status

# Update nvim-treesitter plugin + parsers, then show status.
[group('treesitter')]
treesitter_sync:
	@printf "🔄 Updating nvim-treesitter plugin...\n"
	@nvim --headless -c 'lua require("lazy").update({plugins={"nvim-treesitter"}, wait=true})' -c 'qa' 2>/dev/null || true
	@printf "✅ Plugin updated!\n"
	@just treesitter_update

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
	@printf "✅ Yazi cache cleared!\n"

# Install yazi plugins + flavors from package.toml (idempotent).
[group('yazi')]
yazi_plugins_install:
	@printf "🐱 Installing yazi plugins + flavors via ya pkg...\n"
	@ya pkg install
	@printf "✅ Yazi plugins installed!\n"

# List installed yazi plugins + flavors.
[group('yazi')]
yazi_plugins_list:
	@ya pkg list

# Upgrade all yazi plugins + flavors to latest revisions.
[group('yazi')]
yazi_plugins_upgrade:
	@printf "🐱 Upgrading yazi plugins + flavors via ya pkg...\n"
	@ya pkg upgrade
	@printf "✅ Yazi plugins upgraded!\n"

# Open Raycast export dialog (save to config/raycast/Raycast.rayconfig).
[group('raycast')]
raycast_export:
	@printf "📦 Opening Raycast export dialog...\n"
	@open "raycast://extensions/raycast/raycast/export-settings-data"
	@printf "💡 Save to: config/raycast/Raycast.rayconfig\n"
	@printf "📖 Full instructions: config/raycast/CLAUDE.md\n"

# Open Raycast import dialog (select config/raycast/Raycast.rayconfig).
[group('raycast')]
raycast_import:
	@printf "📥 Opening Raycast import dialog...\n"
	@open "raycast://extensions/raycast/raycast/import-settings-data"
	@printf "💡 Select: config/raycast/Raycast.rayconfig\n"
	@printf "📖 Full instructions: config/raycast/CLAUDE.md\n"

# Pull latest submodule revisions.
[group('submodules')]
update_submods:
	@printf "📦 Pulling latest submodules...\n"
	git submodule update --recursive --remote
	@printf "✅ Submodules up to date!\n"

# Sweep .DS_Store, swap files, stale zsh sessions.
[group('cleanup')]
clean:
	@printf "🧹 Sweeping out .DS_Store, swap files, stale sessions...\n"
	@rm -rf ./config/zsh/.zsh_sessions
	@fd '\.(DS_Store|swo|swp)$|~$' -tf -u -X rm
	@printf "✨ All clean!\n"
