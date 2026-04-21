# config/archive/

Temporarily archived configs replaced by kanata (commit `a5f8d15` on
`feat/kanata-config`). Delete this directory once kanata is stable.

## Archived Packages

| Directory      | Was replaced by              | Original purpose                         |
| -------------- | ---------------------------- | ---------------------------------------- |
| `karabiner/`   | `config/kanata/` (tap-hold)  | Keyboard remapping (caps→esc/ctrl, etc.) |
| `leader-key/`  | `config/kanata/` (sequences) | App launcher with hierarchical menus     |

## How to Revert: Replace Kanata with Karabiner + Leader Key

### 1. Stop and remove kanata

```bash
# Unload daemon
sudo launchctl unload /Library/LaunchDaemons/com.jtroo.kanata.plist
sudo rm /Library/LaunchDaemons/com.jtroo.kanata.plist

# Remove Input Monitoring permission
# System Settings → Privacy & Security → Input Monitoring → remove kanata

# Optionally uninstall binary
cargo uninstall kanata
```

### 2. Restore archived configs

```bash
mv config/archive/karabiner config/karabiner
mv config/archive/leader-key config/leader-key
```

### 3. Revert install.conf.yaml symlinks

Replace the kanata symlink with the original two:

```yaml
# Remove this line:
    ${XDG_CONFIG_HOME}/kanata: config/kanata

# Add these lines back:
    ${XDG_CONFIG_HOME}/karabiner: config/karabiner
    ${XDG_CONFIG_HOME}/leader-key: config/leader-key
```

Also remove the kanata shell step:

```yaml
# Remove this block:
# kanata (keyboard remapper with cmd feature — built from source)
- shell:
    - command: ./scripts/setup/setup-upgrade-kanata
      description: install kanata with cmd feature, or upgrade
```

### 4. Revert Brewfile

Uncomment karabiner-elements and leader-key in `config/brew/Brewfile`:

```ruby
cask "karabiner-elements"
cask "leader-key"
```

Then run `brew bundle --file=config/brew/Brewfile` to install them.

### 5. Restore login items in setup-macos

Add back to the `login_items` array in `scripts/setup/setup-macos`:

```bash
"/Applications/Karabiner-Elements.app"
"/Applications/Leader Key.app"
```

Remove the kanata LaunchDaemon comment.

### 6. Revert nvim autocmd

In `config/nvim/lua/shamindras/core/autocmds.lua`, replace the kanata
autocmd with the original leader-key one:

```lua
-- Replace this:
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*.kbd' },
  command = "execute 'silent !sudo launchctl kickstart -k system/com.jtroo.kanata'",
})

-- With this:
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*/leader-key/config.json' },
  command = 'execute \'silent !killall "Leader Key" 2>/dev/null; sleep 0.5; open -a "Leader Key"\'',
})
```

### 7. Revert CLAUDE.md references

In root `CLAUDE.md`:
- Change `kanata (keyboard remapper + leader sequences)` back to
  `karabiner (keyboard)` in supported apps
- Replace kanata reload entry in the tool reload table with:
  `leader-key | leader-key/config.json | killall 'Leader Key' ...; open -a 'Leader Key'`

In `scripts/CLAUDE.md`:
- Remove `setup-upgrade-kanata` from key scripts table
- Change kanata login items row back to karabiner + leader-key rows

### 8. Restart Karabiner services

```bash
# Re-enable Karabiner services that were booted out
sudo launchctl load /Library/LaunchDaemons/org.pqrs.service.daemon.Karabiner-Core-Service.plist
# Console user server auto-starts when Karabiner-Elements.app launches
```

### 9. Re-enable Input Monitoring for Karabiner

System Settings → Privacy & Security → Input Monitoring → re-enable:
- `karabiner_grabber`
- `Karabiner-Core-Service.app`

### 10. Clean up kanata artifacts

Files to remove if fully reverting:
- `config/kanata/` (entire directory)
- `config/bin/run-as-user`
- `config/bin/fastopen`
- `config/bin/open-nordvpn`
- `config/bin/brew-update`
- `config/bin/empty-trash`
- `scripts/setup/setup-upgrade-kanata`
- `config/archive/` (this directory, after restoring contents)

The `quit-app` refactoring (pgrep, `_is_running`, `--activate-quit`,
`--delay`, `run-as-user` integration) can be kept or reverted — it is
backwards-compatible with Leader Key usage.

### 11. Revert install script

In `install`, remove:
- `CARGO_HOME` and `RUSTUP_HOME` exports (unless needed for other tools)
- `sudo -v` and keep-alive block (unless needed for other scripts)
