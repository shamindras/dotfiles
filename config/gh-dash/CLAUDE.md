# gh-dash Configuration

- **Docs**: https://dlvhdr.github.io/gh-dash/
- **Installed version**: gh extension (via `gh extension list`)

## Overview

Terminal dashboard for GitHub PRs and issues. Tokyo Night theme, delta
pager, custom keybindings for lazygit and gum workflows.

## File Structure

| File         | Purpose                           |
| ------------ | --------------------------------- |
| `config.yml` | Single YAML config (88 lines)     |

## Key Settings

- **PR sections**: My PRs, My Review, Involved (3 sections, limit 20 each)
- **Issue sections**: Assigned, Creator, Involved, Commented (4 sections)
- **Default view**: `prs`
- **Preview pane**: open by default, 70% width
- **Pager**: delta
- **Theme**: Tokyo Night palette (primary: #E2E1ED, inverted: #242347)
- **Keybindings**:
  - `g` — cd into repo + lazygit
  - `b` — view buildkite status URL
  - `a` — git add -A + lazygit
  - `v` — approve PR with gum prompt
- **Repo paths**: shamindras/dotfiles → ~/DROPBOX/REPOS/dotfiles

## Cross-Tool References

- Uses **lazygit** (keybind `g`)
- Uses **delta** for pager
- Uses **gum** for interactive prompts

## Development Notes

- No reload needed; changes apply immediately
