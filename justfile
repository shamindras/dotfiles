_default:
	@just --choose

# NOTE: we don't include update submods here
all: clean stylua_config prettier_md update_brewfile firefox_sync firefox_audit treesitter_sync

clean:
	@printf "🧹 Sweeping out .DS_Store, swap files, stale sessions...\n"
	@rm -rf ./config/zsh/.zsh_sessions
	@fd '\.(DS_Store|swo|swp)$|~$' -tf -u -X rm
	@printf "✨ All clean!\n"

stylua_config:
	@printf "🎨 Formatting all Lua config files with stylua...\n"
	@fd . 'config/' -e lua -j 4 -x sh -c 'stylua "$1" > /dev/null 2>&1 || true' sh {}
	@printf "✅ Lua files formatted!\n"

prettier_md:
	@printf "🎨 Formatting markdown files with prettier...\n"
	@prettier --write . > /dev/null 2>&1
	@printf "✅ Markdown files formatted!\n"

update_brewfile:
	@printf "🍺 Dumping current Homebrew packages to Brewfile...\n"
	# Strip cargo from PATH so brew doesn't invoke the rustup shim, which
	# errors in subprocesses where it can't resolve the default toolchain.
	# Rust/cargo is managed separately via rustup, not the Brewfile.
	@PATH="$(echo "$PATH" | tr ':' '\n' | grep -v cargo | tr '\n' ':')" brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf "✅ Brewfile saved to ./config/brew/Brewfile\n"

firefox_sync:
	@printf "🦊 Syncing Firefox config (user.js, chrome/, policies.json) to profile...\n"
	@./scripts/setup-firefox
	@printf "✅ Firefox synced! Restart Firefox for changes.\n"

firefox_audit:
	@printf "🔍 Auditing Firefox config for drift...\n"
	@./scripts/audit-firefox

# Update nvim-treesitter plugin + install/update parsers, then show status
treesitter_sync:
	@printf "🔄 Updating nvim-treesitter plugin...\n"
	@nvim --headless -c 'lua require("lazy").update({plugins={"nvim-treesitter"}, wait=true})' -c 'qa' 2>/dev/null || true
	@printf "✅ Plugin updated!\n"
	@just treesitter_update

# Install missing + update outdated treesitter parsers, then show status
treesitter_update:
	@./scripts/setup-nvim-treesitter
	@printf "\n"
	@./scripts/setup-nvim-treesitter --status

# Show treesitter parser status (read-only)
treesitter_status:
	@./scripts/setup-nvim-treesitter --status

raycast_export:
	@printf "📦 Opening Raycast export dialog...\n"
	@open "raycast://extensions/raycast/raycast/export-settings-data"
	@printf "💡 Save to: config/raycast/Raycast.rayconfig\n"
	@printf "📖 Full instructions: config/raycast/CLAUDE.md\n"

raycast_import:
	@printf "📥 Opening Raycast import dialog...\n"
	@open "raycast://extensions/raycast/raycast/import-settings-data"
	@printf "💡 Select: config/raycast/Raycast.rayconfig\n"
	@printf "📖 Full instructions: config/raycast/CLAUDE.md\n"

update_submods:
	@printf "📦 Pulling latest submodules...\n"
	git submodule update --recursive --remote
	@printf "✅ Submodules up to date!\n"
