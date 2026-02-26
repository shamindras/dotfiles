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
- **IdentityFile**: `~/.ssh/id_ed25519`

## Development Notes

- Ed25519 keys preferred over RSA
- Add more Host blocks for additional servers
