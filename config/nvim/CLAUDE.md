# Neovim Configuration

## Overview

Neovim editor config with lazy.nvim plugin manager, ~44 plugins, leader-based
keymaps, and deep cross-tool integration (tmux, aerospace, lazygit, zk).

- **Docs**: https://neovim.io/doc/
- **Installed version**: NVIM v0.11.6 (verified 2026-02-26)
- **Lua conventions**: `.claude/conventions/lua.md`

## Architecture

### File Structure

```
config/nvim/
├── init.lua                          # Entry point: leader key, lazy.nvim setup
├── lazy-lock.json                    # Plugin version lockfile (~44 plugins)
├── ftplugin/
│   └── markdown.lua                  # Buffer-local zk keymaps for .md files
├── lua/shamindras/
│   ├── core/
│   │   ├── options.lua               # Editor settings (tabs, UI, search, undo)
│   │   ├── keymaps.lua               # ~330 lines of leader-based keymaps
│   │   ├── autocmds.lua              # ~164 lines (lint, format, tool restarts)
│   │   └── lazy-bootstrap.lua        # Auto-downloads lazy.nvim if missing
│   └── plugins/
│       ├── lspconfig.lua             # LSP + Mason + Fidget
│       ├── cmp.lua                   # Completion (nvim-cmp + LuaSnip)
│       ├── conform.lua               # Multi-tool formatter
│       ├── nvim-lint.lua             # Multi-tool linter (100ms debounce)
│       ├── treesitter.lua            # Syntax highlighting + text objects
│       ├── colorscheme.lua           # 3-theme cycler (Eldritch/TokyoNight/Jellybeans)
│       ├── snacks/
│       │   ├── init.lua              # Fuzzy finder, file explorer, lazygit
│       │   └── pickers.lua           # Custom Snacks picker configs (fd, rg, ivy)
│       ├── zk.lua                    # Zettelkasten integration
│       ├── mini.lua                  # 13 mini.nvim modules
│       ├── flash.nvim                # Enhanced f/t motion
│       ├── smart-splits.lua          # Tmux-aware splits (C-hjkl)
│       ├── todo-comments.lua         # TODO/FIXME highlighting
│       ├── comment.lua               # Comment toggling
│       ├── noice.lua                 # Cmdline popup
│       └── backout.lua               # Alt+hl escape insert/cmdline
└── spell/
    └── en.utf-8.add*                 # Custom spell dictionary
```

### Key Patterns

- **Plugin manager**: lazy.nvim with event-based lazy loading
- **Namespace**: `shamindras.core` (base) + `shamindras.plugins` (specs)
- **Leader key**: Space (set before plugin load in `init.lua`)
- **State**: colorscheme persisted to `~/.local/state/nvim/colorscheme_state.txt`

### Keymap Organization

| Prefix       | Scope                                          |
| ------------ | ---------------------------------------------- |
| `<leader>b`  | Buffer ops (format, yank, write)               |
| `<leader>f`  | File ops (rename, explorer, config browser)    |
| `<leader>s`  | Search (grep, diagnostics, help, keymaps)      |
| `<leader>l`  | Lazy manager (menu, update, profile, sync)     |
| `<leader>w`  | Window (split, equalize, maximize, swap)       |
| `<leader>k`  | Zettelkasten (daily, idea, search, backlinks)  |
| `<leader>t`  | Toggle (line numbers, spell check, theme)      |
| `<leader>g`  | Go/navigation (link opening)                   |

### Plugin Categories

**Completion & LSP**: nvim-lspconfig, mason.nvim, nvim-cmp, LuaSnip, conform.nvim, nvim-lint, lazydev.nvim
**Finding & Navigation**: snacks.nvim (pickers), flash.nvim, smart-splits.nvim, mini.files
**Syntax & Editing**: treesitter, mini.ai, mini.surround, mini.pairs, mini.move, Comment.nvim
**Appearance**: mini.statusline, mini.notify, mini.icons, mini.clue, noice.nvim, todo-comments
**Special**: zk-nvim (notes), tmux-resurrect awareness

## Cross-Tool Integration

| Tool       | Integration                                            |
| ---------- | ------------------------------------------------------ |
| tmux       | smart-splits.nvim: C-hjkl nav, zoom-aware             |
| aerospace  | Autocmd: reload-config on aerospace.toml save          |
| yazi       | Autocmd: clear-cache on yazi.toml save                 |
| lazygit    | Snacks.lazygit() via `<leader>lg`                      |
| borders    | Autocmd: restart service on bordersrc save             |
| zk         | zk-nvim with LSP attach on .md files in notebook       |
| fd/rg      | Custom args in snacks/pickers.lua (exclude .git, submods) |

## Development Notes

- Format on save via conform.nvim (skips files >100KB)
- Lint debounce: 100ms on BufWritePost/InsertLeave
- Reload config: `:source $MYVIMRC` or `<leader>xb` (source current file)
- Check LSP: `:LspInfo` — check Mason: `:Mason`
- Profile startup: `<leader>lp`
- View keymaps: `<leader>sk`
