# Neovim Configuration

## Overview

Neovim editor config with lazy.nvim plugin manager, ~45 plugins, leader-based
keymaps, and deep cross-tool integration (tmux, aerospace, lazygit, zk).

- **Docs**: https://neovim.io/doc/
- **Installed version**: NVIM v0.12.0 (verified 2026-03-30)
- **Lua conventions**: `.claude/conventions/lua.md`

## Architecture

### File Structure

```
config/nvim/
├── init.lua                          # Entry point: leader key, lazy.nvim setup
├── lazy-lock.json                    # Plugin version lockfile (~45 plugins)
├── after/
│   └── queries/markdown/
│       └── textobjects.scm           # Custom section text object (@section.outer/inner)
├── ftplugin/
│   ├── markdown.lua                  # Buffer-local md settings, highlights, heading ops, zk keymaps
│   └── markdown_folds.lua            # Fold cycling (zv/zj/zk) + auto-collapse on load
├── lua/shamindras/
│   ├── util/
│   │   └── markdown.lua              # Shared treesitter helpers (headings, folds, section ops)
│   ├── core/
│   │   ├── options.lua               # Editor settings (12 fold sections)
│   │   ├── keymaps.lua               # ~370 lines of leader-based keymaps
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
│       ├── markdown.lua              # Markdown editing (tadmccorkle/markdown.nvim)
│       ├── render-markdown.lua       # In-buffer markdown rendering
│       ├── mini.lua                  # 14 mini.nvim modules (incl. hipatterns for TODO/FIXME)
│       ├── flash.nvim                # Enhanced f/t motion
│       ├── smart-splits.lua          # Tmux-aware splits (C-hjkl)
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

| Prefix       | Scope                                             |
| ------------ | ------------------------------------------------- |
| `<leader>b`  | Buffer ops (format, yank, write)                  |
| `<leader>f`  | File ops (rename, explorer, config browser, lint) |
| `<leader>g`  | Go/navigation (link opening)                      |
| `<leader>k`  | Zettelkasten (daily, idea, search, backlinks)     |
| `<leader>l`  | Lazy manager (menu, update, profile, sync)        |
| `<leader>m`  | Markdown ops (checkbox, TOC, list, render toggle) |
| `<leader>n`  | Number ops (increment, decrement)                 |
| `<leader>s`  | Search/replace (grep, diagnostics, todo comments) |
| `<leader>t`  | Toggle (line numbers, spell, theme, hipatterns)   |
| `<leader>w`  | Window (split, equalize, maximize, swap)          |

### Plugin Categories

**Completion & LSP**: nvim-lspconfig, mason.nvim, nvim-cmp, LuaSnip, conform.nvim, nvim-lint, lazydev.nvim
**Finding & Navigation**: snacks.nvim (pickers), flash.nvim, smart-splits.nvim, mini.files
**Syntax & Editing**: treesitter, mini.ai, mini.surround, mini.pairs, mini.move, Comment.nvim
**Appearance**: mini.statusline, mini.notify, mini.icons, mini.clue, mini.hipatterns, noice.nvim
**Markdown**: markdown.nvim (editing/motions), render-markdown.nvim (rendering), marksman (LSP, non-zk files)
**Special**: zk-nvim (notes), tmux-resurrect awareness

## Cross-Tool Integration

| Tool       | Integration                                            |
| ---------- | ------------------------------------------------------ |
| tmux       | smart-splits.nvim: C-hjkl nav, zoom-aware             |
| aerospace  | Autocmd: reload-config on aerospace.toml save          |
| yazi       | Autocmd: clear-cache on yazi.toml save                 |
| lazygit    | Snacks.lazygit() via `<leader>lg`                      |
| borders    | Autocmd: restart service on bordersrc save             |
| sketchybar | Autocmd: reload on sketchybarrc/colors/items save      |
| leader-key | Autocmd: restart app on config.json save               |
| zk         | zk-nvim with LSP attach on .md files in notebook       |
| fd/rg      | Custom args in snacks/pickers.lua (exclude .git, submods) |

## Theme Management

Colorschemes are managed via lazy.nvim plugin specs in
`lua/shamindras/plugins/colorscheme.lua`.

- **Add a theme**: add a plugin spec to `colorscheme.lua` and include it
  in the `themes` table for the cycler
- **Cycle themes**: `<leader>tc` (persists selection to
  `~/.local/state/nvim/colorscheme_state.txt`)
- **Update themes**: `:Lazy update` or `<leader>lu`

## Markdown Setup

Three plugins + formatter, all lazy-loaded on `ft = "markdown"`:

- **markdown.nvim** — editing: inline style toggle, TOC, checkbox, lists, links
- **render-markdown.nvim** — in-buffer rendering with custom config: linkarzu-style
  heading backgrounds/icons, inline checkboxes, code block borders, link icons
- **marksman** — LSP for non-zk markdown (link validation, completions, go-to-def)
- **prettier** — GFM formatter via conform.nvim (config from `.prettierrc.yaml`: `proseWrap: always`, `printWidth: 120`)

### Markdown Keybindings (filetype-local)

| Key                 | Action                                            | Mode    |
| ------------------- | ------------------------------------------------- | ------- |
| `gl{motion}{style}` | Toggle inline style                               | n       |
| `gll{style}`        | Toggle style (line)                               | n       |
| `gl{style}`         | Toggle style (visual)                             | v       |
| `ds{style}`         | Delete inline style                               | n       |
| `cs{from}{to}`      | Change inline style                               | n       |
| `C-b`               | Toggle bold (cursor word)                         | n, v, i |
| `C-t`               | Toggle italic (cursor word)                       | n, v, i |
| `<CR>`              | Follow link                                       | n       |
| `gL`                | Add link                                          | n, v    |
| `<leader>mx`        | Toggle checkbox (dot-repeatable)                  | n, v    |
| `<C-x>`             | Toggle checkbox (dot-repeatable)                  | n       |
| `<leader>mo` / `mO` | List item below / above                           | n       |
| `<leader>mc` / `mC` | Insert TOC / TOC loclist                          | n       |
| `<leader>mr`        | Toggle render-markdown                            | n       |
| `<leader>mh`        | Promote heading level (dot-repeatable)            | n       |
| `<leader>ml`        | Demote heading level (dot-repeatable)             | n       |
| `<leader>mj`        | Move section down (dot-repeatable)                | n       |
| `<leader>mk`        | Move section up (dot-repeatable)                  | n       |
| `zv`                | Toggle heading fold / focus nearest               | n       |
| `zj`                | Next heading fold (cycle)                         | n       |
| `zk`                | Previous heading fold (cycle)                     | n       |
| `]]` / `[[`         | Next / prev heading                               | n       |
| `]h` / `[h`         | Current / parent heading                          | n       |
| `dah` / `vah`       | Delete/select heading section (heading + content) | n, v    |
| `dih` / `vih`       | Delete/select section content (without heading)   | n, v    |

Style keys: `b`=bold, `i`=italic, `s`=strikethrough, `c`=code span

### LSP Routing

- Files inside `$ZK_NOTEBOOK_DIR` → zk LSP (auto-attach via zk-nvim)
- All other `.md` files → marksman (guard in `lspconfig.lua` `root_dir`)

### Buffer Settings (ftplugin/markdown.lua)

- Spell check auto-enabled (en_AU/en_GB)
- Treesitter-based heading folding (all folds open by default)
- Section text object `h` via mini.ai + custom treesitter query
  (`after/queries/markdown/textobjects.scm`)
- Theme-aware heading + code block highlights — per-theme palettes
  for Eldritch, TokyoNight, Jellybeans; auto-updates on `ColorScheme` event
- Buffer-local `zv`/`zj`/`zk` fold cycling — uses treesitter `atx_heading`
  query to cycle all heading levels (overrides global fold-cycling keymaps)

### Formatter Config (repo root)

- `.prettierrc.yaml` — prettier options (`printWidth: 120`, `proseWrap: always`)
- `.prettierignore` — ignore all except `.md` files (with `!*/` to traverse subdirs)

### LSP API

Servers use the nvim 0.11 native `vim.lsp.config()` + `vim.lsp.enable()` API.
Homebrew-managed servers (marksman) are excluded from Mason via `mason_exclude`
list and set up directly in `lspconfig.lua`.

## Development Notes

- **options.lua API convention**: use `o` (`vim.o`) for scalar options, `opt`
  (`vim.opt`) only for table-valued assignments (`listchars`, `fillchars`) or
  `:append()`/`:remove()` methods, and `vim.g` directly for global variables
- **Timing chain**: `ttimeoutlen=5` (key code sequences) + tmux `escape-time 0`
  + Ghostty atomic key codes = instant Esc-to-Normal. Do not increase
  `ttimeoutlen` above ~10ms or Esc will feel laggy.
- Format on save via conform.nvim (skips files >100KB)
- Lint debounce: 100ms on BufWritePost/InsertLeave
- Reload config: `:source $MYVIMRC` or `<leader>xb` (source current file)
- Check LSP: `:LspInfo` — check Mason: `:Mason`
- Profile startup: `<leader>lp`
- View keymaps: `<leader>sk`
- **Treesitter parsers**: nvim 0.11+ bundles parsers for c, lua, markdown,
  markdown_inline, query, vim, vimdoc. `ensure_installed` lists only
  non-bundled parsers (bash, python, etc.). `auto_install` is disabled and
  `build = ':TSUpdate'` is removed to prevent races when multiple nvim
  instances start simultaneously (e.g., `sesh-reset --common`). Parsers are
  managed by `scripts/setup-nvim-treesitter` (run during `./install` and via
  justfile). Requires `tree-sitter-cli` (`brew install tree-sitter-cli`) for
  compilation. Compiled `.so` files live in
  `~/.local/share/nvim/site/parser/`, revision tracking in
  `~/.local/share/nvim/site/parser-info/<lang>.revision`.
  - **Default mode**: `./scripts/setup-nvim-treesitter` — installs missing
    parsers and updates outdated ones (compares installed vs wanted revision)
  - **Status mode**: `./scripts/setup-nvim-treesitter --status` — read-only
    table showing parser status, revisions, file sizes, modified dates
  - **Justfile**: `just treesitter_update` (install+update, then status),
    `just treesitter_status` (status only)
  - **Add a parser**: add to `ensure_installed` in `treesitter.lua`, then
    `just treesitter_update`
  - **Manual testing**: `:InspectTree` (AST), `:Inspect` (highlight groups),
    `:checkhealth nvim-treesitter`
