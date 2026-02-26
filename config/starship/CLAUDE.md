# Starship Configuration

- **Docs**: https://starship.rs/config/
- **Installed version**: starship 1.24.2 (verified 2026-02-26)

## Overview

Cross-shell prompt with Tokyo Night-inspired colors. Multi-line format
showing directory and git branch. Currently commented out in zsh config
(simple vcs_info prompt used instead).

## File Structure

| File             | Purpose                        |
| ---------------- | ------------------------------ |
| `starship.toml`  | Single config file (77 lines)  |

## Key Settings

- **Format**: multi-line with blue directory pill, teal git branch pill
- **No blank line**: `add_newline = false`
- **Directory**: 5-level truncation, `…/` symbol
- **Git**: branch display only — git_status, git_metrics, git_commit,
  git_state all disabled
- **Character**: success `❯`, error (red), vicmd (green)
- **Disabled modules**: aws, cmd_duration, rlang, hostname, docker_context,
  lua, nodejs, package, rust, username

## Cross-Tool References

- Integrates with **zsh** (prompt display, init in `10-z1-brew-apps.zsh`)
- Uses **git** for branch info

## Development Notes

- Reload: automatic on save (shell re-evaluates prompt)
- Test: `starship config` to validate TOML
