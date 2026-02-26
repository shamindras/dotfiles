# GitHub CLI Configuration

- **Docs**: https://cli.github.com/manual/
- **Installed version**: gh 2.87.3 (verified 2026-02-26)

## Overview

GitHub CLI with SSH protocol, custom aliases for PR/issue workflows,
and bat as pager.

## File Structure

| File         | Purpose                                |
| ------------ | -------------------------------------- |
| `config.yml` | Main config (protocol, pager, aliases) |
| `hosts.yml`  | Host auth (github.com, user shamindras)|

## Key Settings

- **Git protocol**: `ssh`
- **Browser**: firefox
- **Pager**: bat
- **Aliases** (25+):
  - Repo: `clone` → `repo clone`, `clp` (clone to ~/DROPBOX/REPOS/)
  - PR: `co` (checkout), `diff`, `merge`, `vpr` (view in browser)
  - Issue: `add` (create), `todo` (assigned @me), `mine`, `bugs`, `homework`
  - Utility: `zen`, `il` (issue list), `browser` (repo page)

## Cross-Tool References

- Uses **bat** for pager output
- Used by **lazygit** for PR/issue commands
- Referenced in **leader-key**

## Development Notes

- No reload needed; changes apply immediately
- Alias syntax validated on execution
