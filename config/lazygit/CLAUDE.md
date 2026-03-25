# Lazygit Configuration

- **Docs**: https://github.com/jesseduffield/lazygit
- **Installed version**: lazygit 0.59.0 (verified 2026-02-26)

## Overview

Terminal UI for git. Tokyo Night color theme, delta pager for diffs,
custom commands for commitizen and branch pruning.

## File Structure

| File         | Purpose                              |
| ------------ | ------------------------------------ |
| `config.yml` | Single YAML config (150 lines)       |

## Key Settings

- **Nerd font**: version "3" (file icons)
- **Theme**: Tokyo Night colors (custom hex), rounded borders
- **Side panel**: 33.33% width, flexible main panel split
- **File tree view**: enabled by default (toggle with `~`)
- **Editor**: nvim with `+{{line}} -- {{filename}}` template
- **Pager**: delta (`--dark --side-by-side --line-numbers`)
- **Force push**: disabled (`disableForcePushing: true`)
- **Log order**: `topo-order` (topological)
- **Custom commands**:
  - `W` — commit without hooks
  - `C` — commitizen
  - `z` — custom gum commit script
  - `G` — prune gone branches

## Cross-Tool References

- Uses **nvim** as editor
- Uses **delta** for diff display
- Launched from **leader-key**, tmux (`prefix+g`)

## Theme Management

lazygit uses inline hex colors in `config.yml` under `gui.theme`. No
external theme files or import system.

- **Change theme**: replace hex values under `gui.theme` in `config.yml`
- Theme palettes for popular schemes (Tokyo Night, Catppuccin, etc.) are
  published in their respective repos as lazygit YAML snippets

## Development Notes

- Restart app to apply config changes
- Schema: https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json
