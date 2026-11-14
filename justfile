set shell := ['bash', '-eu', '-o', 'pipefail', '-c']
set export
export JUST_CHOOSER := 'fzf --preview "just --show {}" --preview-window=right:60%'

# Open interactive recipe picker with fzf preview of recipe bodies.
_default:
	@just --choose

# NOTE: we don't include submods_update or firefox_audit here;
# `just audit` is the home for read-only drift checks.
# Run cleanup, format, manifest render, firefox sync, treesitter sync, yazi upgrade.
all:
	@scripts/step outer 1 7 🧹 "Cleaning artifacts"
	@just clean
	@scripts/step outer 2 7 🎨 "Formatting Lua configs"
	@just stylua_config
	@scripts/step outer 3 7 🎨 "Formatting markdown"
	@just prettier_md
	@scripts/step outer 4 7 🧾 "Rendering generated/ from manifest.json"
	@just manifest_render
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
	@just submods_update

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

# Deploy prettier + markdownlint configs from config/zk/notebook/ into $NOTES_DIR.
[group('notes')]
notes_config_sync:
	@printf "📝 Syncing notes formatter configs to $NOTES_DIR...\n"
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
[group('update')]
submods_update:
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

# Static checks: shellcheck, harness self-test, resolver tests, docs lint, invariants, manifest, home parity, zizmor.
[group('test')]
test_static:
	@scripts/step inner 1 6 "shellcheck scripts/test"
	@shellcheck -x scripts/test/lib.sh $(grep -l '^#!/usr/bin/env bash' scripts/test/*)
	@scripts/step inner 2 6 "Harness self-test"
	@scripts/test/self-test
	@scripts/step inner 3 6 "Resolver unit tests"
	@python3 scripts/test/manifest_test.py
	@scripts/step inner 4 6 "Decision notes and plan graph"
	@scripts/test/check-docs
	@scripts/step inner 5 6 "Invariants"
	@scripts/test/check-invariants
	@scripts/step inner 6 6 "Manifest, home parity and path gates"
	@scripts/ops/manifest check
	@scripts/test/check-parity
	@scripts/test/check-paths
	@scripts/test/check-hammerspoon
	@scripts/test/check-layout
	@scripts/test/check-workflows
	@scripts/step done 🧪 "Static checks passed"

# Sandbox tests in a throwaway HOME: config load, link-only install, doctor, dropbox_finish.
[group('test')]
test_sandbox:
	@scripts/step inner 1 4 "Config load"
	@scripts/test/check-config-load
	@scripts/step inner 2 4 "Install into a throwaway HOME"
	@scripts/test/sandbox-install
	@scripts/step inner 3 4 "doctor is read-only"
	@scripts/test/check-doctor
	@scripts/step inner 4 4 "dropbox_finish, GitHub auth, brew-update and treesitter against stubs"
	@scripts/test/check-dropbox
	@scripts/test/check-github-auth
	@scripts/test/check-brew-update
	@scripts/test/check-treesitter
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

# Read-only health report for this Mac and clone (works before anything is installed).
[group('health')]
doctor *args:
	@scripts/ops/doctor {{args}}

# Finish Dropbox after sign-in (home): ~/Dropbox link, then the notes notebook. Waits for nothing; safe any time.
[group('notes')]
dropbox_finish:
	#!/usr/bin/env bash
	set -Eeuo pipefail
	if [[ ! -f "$HOME/.dropbox/info.json" ]]; then
	    echo "Waiting for Dropbox sign-in (~/.dropbox/info.json is missing). Sign in in the app, then run this again."
	    exit 0
	fi
	scripts/ops/ensure-dropbox-link
	notes="${NOTES_DIR:?NOTES_DIR is not set: open a new shell, or run ./install first}"
	if [[ ! -d "$notes" ]]; then
	    echo "Waiting for $notes to sync. A first sync can take hours; run this again later."
	    exit 0
	fi
	scripts/setup/setup-zk
	echo
	echo "One-time step (Dropbox has no command for it): in Finder, right-click"
	echo "$notes and choose 'Make available offline', so zk, rg and nvim never"
	echo "meet an online-only placeholder. just doctor reports any placeholders left."

# Update nvim plugins (lazy.nvim sync; lazy-lock.json changes in the repo).
[group('update')]
nvim_update:
	@printf "💤 Syncing nvim plugins (Lazy sync)...\n"
	@nvim --headless "+Lazy! sync" +qa
	@printf "✅ nvim plugins synced (review git diff config/nvim/lazy-lock.json)\n"

# Move the zsh plugin pins to the latest upstream commit, then check the local clones out there.
[group('update')]
zsh_plugins_update:
	#!/usr/bin/env bash
	set -Eeuo pipefail
	f=config/zsh/conf.d/08-z1-plugins.zsh
	for pin in $(grep -oE '[a-z0-9-]+/[a-z0-9-]+@[0-9a-f]{40}' "$f"); do
	    repo="${pin%@*}"
	    new="$(git ls-remote "https://github.com/$repo" HEAD | cut -f1)"
	    [[ -n "$new" ]] || { echo "could not read $repo"; exit 1; }
	    sed -i '' "s|$pin|$repo@$new|" "$f"
	    dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/${repo#*/}"
	    if [[ -d "$dir/.git" ]]; then
	        git -C "$dir" fetch -q --depth 1 origin "$new" && git -C "$dir" checkout -q "$new"
	    fi
	    echo "$repo -> ${new:0:12}"
	done

# Update everything that is pinned in the repo: nvim, zsh plugins, yazi, treesitter, submodules.
[group('update')]
update-all:
	@scripts/step outer 1 5 💤 "nvim plugins"
	@just nvim_update
	@scripts/step outer 2 5 🐚 "zsh plugin pins"
	@just zsh_plugins_update
	@scripts/step outer 3 5 🐱 "yazi plugins"
	@just yazi_plugins_upgrade
	@scripts/step outer 4 5 🔄 "treesitter parsers"
	@just treesitter_update
	@scripts/step outer 5 5 📦 "submodules"
	@just submods_update

# Read-only: what would update (Homebrew, zsh plugin pins, submodules).
[group('update')]
outdated:
	#!/usr/bin/env bash
	set -Eeuo pipefail
	echo "── Homebrew (greedy) ──"
	HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --greedy || true
	echo "── zsh plugin pins ──"
	for pin in $(grep -oE '[a-z0-9-]+/[a-z0-9-]+@[0-9a-f]{40}' config/zsh/conf.d/08-z1-plugins.zsh); do
	    repo="${pin%@*}"; new="$(git ls-remote "https://github.com/$repo" HEAD | cut -f1)"
	    [[ "$new" == "${pin#*@}" ]] && echo "$repo: current" || echo "$repo: ${pin#*@} -> $new"
	done
	echo "── submodules ──"
	git submodule status
