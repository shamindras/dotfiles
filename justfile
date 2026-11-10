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

# Sync firefox, treesitter, yazi plugins, notes configs, submodules.
sync-all:
	@scripts/step outer 1 5 🦊 "Syncing Firefox"
	@just firefox_sync
	@scripts/step outer 2 5 🔄 "Syncing treesitter"
	@just treesitter_sync
	@scripts/step outer 3 5 🐱 "Upgrading yazi plugins"
	@just yazi_plugins_upgrade
	@scripts/step outer 4 5 📝 "Syncing notes configs"
	@just notes_config_sync
	@scripts/step outer 5 5 📦 "Updating submodules"
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

# Deploy prettier + markdownlint configs from config/zk/notebook/ into $DROPBOX_NOTES_DIR.
[group('notes')]
notes_config_sync:
	@printf "📝 Syncing notes formatter configs to $DROPBOX_NOTES_DIR...\n"
	@./scripts/ops/sync-notes-config
	@printf "✅ Notes configs synced\n"

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

# Run every test: static checks, then the sandbox tests.
[group('test')]
test:
	@scripts/step outer 1 2 🧪 "Running static checks"
	@just test_static
	@scripts/step outer 2 2 📦 "Running sandbox tests"
	@just test_sandbox

# Static checks: shellcheck the tests, harness self-test, resolver tests, docs lint, invariants.
[group('test')]
test_static:
	@scripts/step inner 1 5 "shellcheck scripts/test"
	@shellcheck -x scripts/test/lib.sh $(grep -l '^#!/usr/bin/env bash' scripts/test/*)
	@scripts/step inner 2 5 "Harness self-test"
	@scripts/test/self-test
	@scripts/step inner 3 5 "Resolver unit tests"
	@python3 scripts/test/manifest_test.py
	@scripts/step inner 4 5 "Decision notes and plan graph"
	@scripts/test/check-docs
	@scripts/step inner 5 5 "Invariants"
	@scripts/test/check-invariants
	@scripts/step done 🧪 "Static checks passed"

# Sandbox tests in a throwaway HOME: config load, then link-only install.
[group('test')]
test_sandbox:
	@scripts/step inner 1 2 "Config load"
	@scripts/test/check-config-load
	@scripts/step inner 2 2 "Install into a throwaway HOME"
	@scripts/test/sandbox-install
	@scripts/step done 📦 "Sandbox tests passed"

# Render generated/<profile>/ and generated/compare.md from manifest.json.
[group('manifest')]
manifest_render:
	@scripts/ops/manifest render

# Validate manifest.json (schema, closure, leader keys, links) and check generated/ is current.
[group('manifest')]
manifest_check:
	@scripts/ops/manifest check

# Set a unit's state in a profile: just manifest_set work zoom external (managed|external|off|default).
[group('manifest')]
manifest_set profile unit state:
	@scripts/ops/manifest set {{profile}} {{unit}} {{state}}

# Explain why a unit is on or off in a profile: just manifest_why work bat.
[group('manifest')]
manifest_why profile unit:
	@scripts/ops/manifest why {{profile}} {{unit}}

# Print the home-versus-work comparison.
[group('manifest')]
manifest_diff:
	@scripts/ops/manifest diff
