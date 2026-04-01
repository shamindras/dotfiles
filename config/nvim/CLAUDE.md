# Neovim Configuration

## Overview

Neovim editor config with lazy.nvim plugin manager, ~29 plugins, leader-based
keymaps, and deep cross-tool integration (tmux, aerospace, lazygit, zk).

- **Docs**: https://neovim.io/doc/
- **Installed version**: NVIM v0.12.0 (verified 2026-03-30)
- **Lua conventions**: `.claude/conventions/lua.md`

## Architecture

### File Structure

```
config/nvim/
├── init.lua                          # Entry point: leader key, lazy.nvim setup
├── lazy-lock.json                    # Plugin version lockfile (~29 plugins)
├── after/
│   └── queries/markdown/
│       └── textobjects.scm           # Custom section text object (@section.outer/inner)
├── ftplugin/
│   ├── markdown.lua                  # Buffer-local md settings, highlights, heading ops, zk keymaps
│   └── markdown_folds.lua            # Fold cycling (zv/zj/zk) + auto-collapse on load
├── lua/shamindras/
│   ├── util/
│   │   ├── markdown.lua              # Shared treesitter helpers (headings, folds, section ops)
│   │   └── themes.lua                # Theme registry (plugins, palettes, setup opts)
│   ├── core/
│   │   ├── options.lua               # Editor settings (12 fold sections)
│   │   ├── keymaps.lua               # ~400 lines of leader-based keymaps
│   │   ├── autocmds.lua              # ~176 lines (lint, format, tool restarts)
│   │   └── lazy-bootstrap.lua        # Auto-downloads lazy.nvim if missing
│   └── plugins/
│       ├── lspconfig.lua             # LSP + Mason (lazydev, blink.cmp capabilities)
│       ├── cmp.lua                   # Completion (blink.cmp + LuaSnip)
│       ├── conform.lua               # Multi-tool formatter
│       ├── nvim-lint.lua             # Multi-tool linter (100ms debounce)
│       ├── treesitter.lua            # Syntax highlighting + text objects
│       ├── colorscheme.lua           # 6-plugin theme registry (12 variants, dark-to-light)
│       ├── snacks/
│       │   ├── init.lua              # Fuzzy finder, file explorer, lazygit, buffer delete
│       │   └── pickers.lua           # Custom Snacks picker configs (fd, rg, ivy, todo, colorscheme)
│       ├── zk.lua                    # Zettelkasten integration
│       ├── markdown.lua              # Markdown editing (tadmccorkle/markdown.nvim)
│       ├── render-markdown.lua       # In-buffer markdown rendering
│       ├── mini.lua                  # Single mini.nvim spec (12 modules)
│       ├── flash.nvim                # Enhanced f/t motion
│       ├── smart-splits.lua          # Tmux-aware splits (C-hjkl)
│       └── noice.lua                 # Cmdline popup
└── spell/
    └── en.utf-8.add*                 # Custom spell dictionary
```

### Key Patterns

- **Plugin manager**: lazy.nvim with `defaults = { lazy = true }` and event/keys-based loading
- **Namespace**: `shamindras.core` (base) + `shamindras.plugins` (specs)
- **Leader key**: Space (set before plugin load in `init.lua`)
- **State**: colorscheme persisted to `~/.local/state/nvim/colorscheme_state.txt`
- **Fold markers**: `-- {{{ Descriptive Name` / `-- }}}` in all Lua config files (>20 lines)

### Keymap Organization

| Prefix       | Scope                                             |
| ------------ | ------------------------------------------------- |
| `<leader>b`  | Buffer ops (format, delete, yank, write)          |
| `<leader>c`  | Code/LSP (definition, references, actions, rename)|
| `<leader>f`  | File ops (rename, explorer, config browser, lint) |
| `<leader>g`  | Go/navigate (link opening)                        |
| `<leader>k`  | Zettelkasten (daily, idea, search, backlinks)     |
| `<leader>l`  | Lazy manager (menu, update, profile, sync)        |
| `<leader>m`  | Markdown ops (checkbox, TOC, list, render toggle) |
| `<leader>n`  | Number ops (increment, decrement)                 |
| `<leader>s`  | Search/replace (grep, diagnostics, todo comments) |
| `<leader>t`  | Toggle (line numbers, spell, theme, hipatterns)   |
| `<leader>w`  | Window (split, equalize, maximize, swap)          |

### Plugin Categories

**Completion & LSP**: nvim-lspconfig, mason.nvim, blink.cmp, LuaSnip, conform.nvim, nvim-lint, lazydev.nvim
**Finding & Navigation**: snacks.nvim (pickers, explorer, lazygit, bufdelete), flash.nvim, smart-splits.nvim, mini.files
**Syntax & Editing**: treesitter, mini.ai, mini.surround, mini.pairs, mini.move (built-in `gc`/`gcc` for commenting)
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

Colorschemes are registry-driven. Theme data lives in
`lua/shamindras/util/themes.lua` (single source of truth); plugin specs are
auto-generated by `lua/shamindras/plugins/colorscheme.lua`.

- **Themes**: Eldritch (default), TokyoNight, Catppuccin (mocha/macchiato/latte),
  Cyberdream, Nightfox (nightfox/terafox/dayfox), Teide (dark/dimmed/light) — 12 variants
- **Add a theme**: add one entry to `M.themes` + `M.order` in
  `util/themes.lua` (plugin, scheme, setup opts, heading/code palettes)
- **Cycle themes**: `<leader>tc` (persists selection to
  `~/.local/state/nvim/colorscheme_state.txt`)
- **Pick theme**: `<leader>pc` (curated Snacks picker with live preview)
- **Update themes**: `:Lazy update` or `<leader>lu`
- **Lazy-loading**: only the active theme loads at startup; others are
  `lazy = true` until cycled/picked

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

### LSP Keybindings

| Key          | Action              | Mnemonic             |
| ------------ | ------------------- | -------------------- |
| `<leader>cd` | Go to Definition    | [c]ode [d]efinition  |
| `<leader>cr` | Go to References    | [c]ode [r]eferences  |
| `<leader>ci` | Go to Implementation| [c]ode [i]mplementation |
| `<leader>ca` | Code Actions        | [c]ode [a]ctions     |
| `<leader>cn` | Rename Symbol       | [c]ode re[n]ame      |
| `<leader>ct` | Type Definition     | [c]ode [t]ype        |
| `<leader>cs` | Signature Help      | [c]ode [s]ignature   |
| `K`          | Hover Documentation | Standard Vim         |

### LSP Routing

- Files inside `$ZK_NOTEBOOK_DIR` → zk LSP (auto-attach via zk-nvim)
- All other `.md` files → marksman (guard in `lspconfig.lua` `root_dir`)

### Buffer Settings (ftplugin/markdown.lua)

- Spell check auto-enabled (en_AU/en_GB)
- Treesitter-based heading folding (all folds open by default)
- Section text object `h` via mini.ai + custom treesitter query
  (`after/queries/markdown/textobjects.scm`)
- Theme-aware heading + code block highlights — palettes imported from
  `util/themes.lua` for all 12 themes; auto-updates on `ColorScheme` event
- Buffer-local `zv`/`zj`/`zk` fold cycling — uses treesitter `atx_heading`
  query to cycle all heading levels (overrides global fold-cycling keymaps)

### Formatter Config (repo root)

- `.prettierrc.yaml` — prettier options (`printWidth: 120`, `proseWrap: always`)
- `.prettierignore` — ignore all except `.md` files (with `!*/` to traverse subdirs)

### LSP API

Servers use the nvim 0.11 native `vim.lsp.config()` + `vim.lsp.enable()` API.
Homebrew-managed servers (marksman) are excluded from Mason via `mason_exclude`
list and set up directly in `lspconfig.lua`. LSP capabilities provided by
`require('blink.cmp').get_lsp_capabilities()`.

## Completion

Completion is powered by **blink.cmp** (replaced nvim-cmp):

- **Keymap preset**: `default` — `<C-y>` accept, `<C-n>`/`<C-p>` navigate
- **Sources**: lsp, path, snippets, buffer (+ lazydev for lua files)
- **Snippets**: LuaSnip integration via `snippets = { preset = 'luasnip' }`
- **Signature help**: enabled
- **Fuzzy**: Lua implementation

## Plugin Consolidation

**mini.nvim**: single `'nvim-mini/mini.nvim'` spec with `event = 'VeryLazy'`.
All 12 modules configured in one `config` function, organized by fold sections:
Text Editing (ai, operators, surround, move, pairs), General Workflow
(bracketed, files), Appearance (icons, statusline, notify, hipatterns),
Keymap Discovery (clue).

**snacks.nvim**: single spec with `lazy = false`, `priority = 1000` per
official docs. Module configs in `opts`, all keymaps in `keys` array.
`pickers.lua` is a utility module providing layout config, wrapper functions,
and custom pickers (todo comments, colorscheme, buffers) — no `setup_keymaps()`.

## Development Notes

- **options.lua API convention**: use `o` (`vim.o`) for scalar options, `opt`
  (`vim.opt`) only for table-valued assignments (`listchars`, `fillchars`) or
  `:append()`/`:remove()` methods, and `vim.g` directly for global variables
- **Timing chain**: `ttimeoutlen=5` (key code sequences) + tmux `escape-time 0`
  + Ghostty atomic key codes = instant Esc-to-Normal. Do not increase
  `ttimeoutlen` above ~10ms or Esc will feel laggy.
- **Commenting**: built-in `gc`/`gcc` (Neovim 0.10+), no plugin needed
- **LSP progress**: mini.notify built-in `lsp_progress` (no fidget.nvim)
- Format on save via conform.nvim (skips files >100KB)
- Lint debounce: 100ms on BufWritePost/InsertLeave
- Reload config: `:source $MYVIMRC` or `<leader>xb` (source current file)
- Check LSP: `:LspInfo` — check Mason: `:Mason`
- Profile startup: `<leader>lp` (~24ms startup, 10/29 plugins loaded at start)
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
