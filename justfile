_default:
	@just --choose

# NOTE: we don't include update submods here
all: clean stylua_config update_brewfile firefox_sync treesitter_sync

clean:
	@printf "🧹 Sweeping out .DS_Store, swap files, stale sessions...\n"
	@rm -rf ./config/zsh/.zsh_sessions
	@fd '\.(DS_Store|swo|swp)$|~$' -tf -u -X rm
	@printf "✨ All clean!\n"

stylua_config:
	@printf "🎨 Formatting all Lua config files with stylua...\n"
	@fd . 'config/' -e lua -j 4 -x sh -c 'stylua "$1" > /dev/null 2>&1 || true' sh {}
	@printf "✅ Lua files formatted!\n"

update_brewfile:
	@printf "🍺 Dumping current Homebrew packages to Brewfile...\n"
	# Strip cargo from PATH so brew doesn't invoke the rustup shim, which
	# errors in subprocesses where it can't resolve the default toolchain.
	# Rust/cargo is managed separately via rustup, not the Brewfile.
	@PATH="$(echo "$PATH" | tr ':' '\n' | grep -v cargo | tr '\n' ':')" brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf "✅ Brewfile saved to ./config/brew/Brewfile\n"

firefox_sync:
	@printf "🦊 Syncing Firefox config to profile...\n"
	@./scripts/setup-firefox
	@printf "✅ Firefox synced! Restart Firefox for changes.\n"

# Update nvim-treesitter plugin + install/update parsers, then show status
treesitter_sync:
	@printf "🔄 Updating nvim-treesitter plugin...\n"
	@nvim --headless +'Lazy update nvim-treesitter' +'qa' 2>/dev/null || true
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

update_submods:
	@printf "📦 Pulling latest submodules...\n"
	git submodule update --recursive --remote
	@printf "✅ Submodules up to date!\n"
