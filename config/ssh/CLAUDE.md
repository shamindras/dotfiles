# SSH Configuration

- **Docs**: https://man.openbsd.org/ssh_config
- **Installed version**: system OpenSSH (macOS built-in)

## File Structure

| File     | Purpose                      |
| -------- | ---------------------------- |
| `config` | Host-specific SSH settings   |

## Key Settings

- **Host**: github.com
- **AddKeysToAgent**: yes (caches key in ssh-agent)
- **IdentityFile**: `~/.ssh/id_ed25519_github` (one key per Mac, from
  `setup-github-auth`), then the pre-overhaul `~/.ssh/id_ed25519` as a marked
  transitional fallback until the auth step has run (N16)
- **IdentitiesOnly**: yes (only these keys are offered to github.com)
- **Work Mac**: an existing `~/.ssh/config` is never replaced; install's link
  fails safely and this file can be added there with `Include`

## Development Notes

- Ed25519 keys preferred over RSA
- Add more Host blocks for additional servers
