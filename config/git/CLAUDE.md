# Git Configuration

- **Docs**: https://git-scm.com/docs
- **Installed version**: git 2.56.0 (verified 2026-11-11)

## Overview

Git config with delta pager, Catppuccin Mocha diff theme, and custom
aliases. Includes global ignore file.

## File Structure

| File                     | Purpose                                                              |
| ------------------------ | -------------------------------------------------------------------- |
| `config`                 | Main gitconfig (editor, pager, aliases, delta); no identity          |
| `ignore`                 | Global gitignore patterns                                            |
| `transitional.gitconfig` | Home Mac only, until the move to ~/repos (N16): old identity and key |

## Key Settings

- **Editor**: nvim
- **Pager**: delta with Catppuccin Mocha theme
- **Delta**: side-by-side diffs, line numbers, themes from
  `config/delta/themes.gitconfig` (included via `[include]`)
- **Aliases**: `lg` (fancy log graph), `clean-branches`, `gone` (prune
  remote-deleted branches)
- **Auto-correct**: disabled
- **Identity**: not in this folder. `config` includes, in order:
  `transitional.gitconfig` (by its Dropbox path, so only this Mac before the
  move), `~/.config/dotfiles/gitconfig` (rendered per profile from
  `manifest.json`: name, home email, `signingkey = ~/.ssh/id_ed25519_github.pub`,
  allowed signers) and `~/.config/dotfiles/gitconfig.local` (the work email,
  written once by `scripts/setup/setup-github-auth`; never in the repo).
- **Signing**: SSH (`gpg.format = ssh`), every commit and tag. One key per Mac,
  made and registered by `setup-github-auth`.
- **Transport**: HTTPS first. No https-to-ssh `insteadOf` rewrite; `gh auth
  git-credential` is the credential helper for github.com, so a fresh Mac
  clones and taps with no SSH key. Remotes already set to SSH keep working.
- `git config --global --get` does not follow includes: use `git config --get`
  (outside a repo) or `--global --includes` to see the identity.

## Cross-Tool References

- Uses **delta** for diff display (theme sourced from `config/delta/`)
- Uses **nvim** as editor
- **lazygit** overrides pager settings

## Development Notes

- Test config: `git config --list --show-origin`
- Delta themes: add/change in `config/delta/themes.gitconfig`
