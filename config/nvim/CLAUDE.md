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
│   │   └── themes.lua                # Theme registry (plugins, palettes, setup opts, separator colors)
│   ├── core/
│   │   ├── options.lua               # Editor settings (12 fold sections)
│   │   ├── keymaps.lua               # ~400 lines of leader-based keymaps
│   │   ├── autocmds.lua              # ~295 lines (format, tool restarts, marker fold auto-collapse, help vsplit, large file detect)
│   │   └── lazy-bootstrap.lua        # Auto-downloads lazy.nvim if missing
│   └── plugins/
│       ├── lspconfig.lua             # LSP + Mason (lazydev, blink.cmp capabilities)
│       ├── blink.lua                 # Completion (blink.cmp + LuaSnip)
│       ├── conform.lua               # Multi-tool formatter
│       ├── nvim-lint.lua             # Multi-tool linter (100ms debounce)
│       ├── treesitter.lua            # Syntax highlighting + text objects
│       ├── colorscheme.lua           # 7-plugin theme registry (13 variants, dark-to-light)
│       ├── snacks/
│       │   ├── init.lua              # Fuzzy finder, file explorer, lazygit, buffer delete
│       │   └── pickers.lua           # Custom Snacks picker configs (fd, rg, ivy, todo, colorscheme)
│       ├── zk.lua                    # Zettelkasten integration
│       ├── markdown.lua              # Markdown editing (tadmccorkle/markdown.nvim)
│       ├── render-markdown.lua       # In-buffer markdown rendering
│       ├── mini.lua                  # Single mini.nvim spec (12 modules)
│       ├── flash.nvim                # Enhanced f/t motion
│       ├── smart-splits.lua          # Tmux-aware splits (C-hjkl nav, resize, swap)
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
| `<leader>t`  | Toggle (line numbers, spell, theme, cursorword, hipatterns) |
| `<leader>w`  | Window (split, equalize, maximize, resize, swap)  |

### Plugin Categories

**Completion & LSP**: nvim-lspconfig, mason.nvim, blink.cmp, LuaSnip, conform.nvim, nvim-lint, lazydev.nvim
**Finding & Navigation**: snacks.nvim (pickers, explorer, lazygit, bufdelete), flash.nvim, smart-splits.nvim, mini.files
**Syntax & Editing**: treesitter, mini.ai, mini.surround, mini.pairs, mini.move (built-in `gc`/`gcc` for commenting)
**Appearance**: mini.statusline, mini.notify, mini.icons, mini.clue, mini.cursorword, mini.hipatterns, noice.nvim
**Markdown**: markdown.nvim (editing/motions), render-markdown.nvim (rendering), marksman (LSP, non-zk files)
**Special**: zk-nvim (notes), tmux-resurrect awareness

## Cross-Tool Integration

| Tool       | Integration                                            |
| ---------- | ------------------------------------------------------ |
| tmux       | smart-splits.nvim: C-hjkl nav, `<leader>wh/j/k/l` resize, zoom-aware |
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
  Cyberdream, Dracula, Nightfox (nightfox/terafox/dayfox), Teide (dark/dimmed/light) — 13 variants
- **Add a theme**: add one entry to `M.themes` + `M.order` in
  `util/themes.lua` (plugin, scheme, setup opts, heading/code palettes, separator_fg)
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

| Key          | Action                        | Mnemonic                  |
| ------------ | ----------------------------- | ------------------------- |
| `<leader>cd` | Go to Definition              | [c]ode [d]efinition       |
| `<leader>cr` | Go to References              | [c]ode [r]eferences       |
| `<leader>ci` | Go to Implementation          | [c]ode [i]mplementation   |
| `<leader>ca` | Code Actions                  | [c]ode [a]ctions          |
| `<leader>cn` | Rename Symbol                 | [c]ode re[n]ame           |
| `<leader>ct` | Type Definition               | [c]ode [t]ype             |
| `<leader>cs` | Signature Help                | [c]ode [s]ignature        |
| `<leader>ce` | Diagnostic float at cursor    | [c]ode [e]rror/diagnostic |
| `<leader>co` | Document symbols (Snacks)     | [c]ode [o]utline          |
| `<leader>cS` | Workspace symbols (Snacks)    | [c]ode workspace [S]ymbols|
| `<leader>cI` | Toggle inlay hints            | [c]ode [I]nlay hints      |
| `K`          | Hover Documentation           | Standard Vim              |

The `<leader>c*` set deliberately mirrors and supersedes nvim 0.11+'s default
`gr*` LSP keymaps to avoid clobbering mini.operators (which owns the `gr*`
prefix for g[r]eplace, etc.).

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
- Hipatterns keywords (TODO, FIXME, etc.) highlighted in all text by default
  (`vim.g.hipatterns_comment_only = false`); toggle with `<leader>th` to
  restrict to comments only. Todo comments picker in `pickers.lua` always
  filters to comment-prefixed lines via rg pattern regardless of this setting.

### Formatter Config (repo root)

- `.prettierrc.yaml` — prettier options (`printWidth: 120`, `proseWrap: always`)
- `.prettierignore` — ignore all except `.md` files (with `!*/` to traverse subdirs)

### LSP API

Servers use the nvim 0.11+ native `vim.lsp.config()` + `vim.lsp.enable()` API.
LSP capabilities provided by `require('blink.cmp').get_lsp_capabilities()`.

**Configured servers** (`servers` table in `lspconfig.lua`):
- `lua_ls` — Lua, with lazydev for nvim runtime
- `marksman` — markdown (non-zk files; root_dir guards against `$ZK_NOTEBOOK_DIR`)
- `ty` — Python type checker (Astral, pre-1.0). Cmd resolved local-first
  via `util/project_local_resolver.lua`: `<project>/.venv/bin/ty` if present, else
  Mason's ty. Resolved at session start against cwd; recovery for files
  opened from outside their project is `:LspRestart` after cd-ing in.

### Tool installation: single source of truth

`mason-tool-installer` is set up **once** in `lspconfig.lua` with a unified
`ensure_installed` list covering every nvim-managed tool — LSP servers,
linters, AND formatters. nvim-lint and conform contain only their wiring;
they do not own install responsibility.

Architectural principle: **Mason owns the global fallback for nvim-only
tools; Homebrew/npm own the install for shell-shared tools** (jq, yq, shfmt,
prettier, taplo). Tools that are both nvim-used AND shell-shared are
installed in **both** package managers in parallel — each context has its
own canonical install. nvim resolves via Mason's automatic PATH prepend
(mason.nvim default `PATH = "prepend"`); the shell resolves via brew/npm.

**Local-first tool resolution** for `ruff` and `ty`: project's
`.venv/bin/<tool>` if present, else Mason's binary, else PATH. Single
source of truth for the registry lives in
`lua/shamindras/util/project_local_resolver.lua`. Add a new local-first
tool with one row in `local_first_tools`, a new language with one row in
`language_profiles`. Tools without a project-local install pattern (e.g.
marksman, lua_ls, stylua) do **not** belong here — they resolve via
Mason's PATH prepend automatically.

**Lazy-load gotcha (resolved)**: `mason-tool-installer`'s `plugin/` file
registers a `VimEnter` autocmd to call `run_on_start()`. When the plugin
is lazy-loaded after `BufReadPre`, `VimEnter` has already fired and the
autocmd never runs. `lspconfig.lua` calls
`require('mason-tool-installer').run_on_start()` directly after `setup()`
to make missing-tool installs deterministic on first buffer open.

### Diagnostic display

Configured via `vim.diagnostic.config()` in `lspconfig.lua`:
- Nerd-font icons for sign column (`󰅚 󰀪 󰋽 󰌶`)
- `severity_sort = true`, `update_in_insert = false`
- Underline only for WARN+
- Inline `virtual_text` everywhere (`source = 'if_many'`); full
  multiline `virtual_lines` on the **current line only** (nvim 0.11+
  `current_line` mode) — best of both worlds for verbose ty errors.
- Rounded float border with source attribution.

## Completion

Completion is powered by **blink.cmp** (replaced nvim-cmp):

- **Keymap preset**: `default` — `<C-y>` accept, `<C-n>`/`<C-p>` navigate
- **Sources**: lsp, path, snippets, buffer (+ lazydev for lua files)
- **Snippets**: LuaSnip integration via `snippets = { preset = 'luasnip' }`
- **Signature help**: enabled
- **Fuzzy**: Lua implementation
- **Cmdline mode**: enabled with auto-show for `:` commands only (not `/` `?`
  search). Inherits insert-mode keymap preset (`C-n`/`C-p` navigate, `C-y`
  accept). Sources: buffer + cmdline (vim's `getcompletion()` — covers
  commands, options, lua API, file paths). Ghost text enabled for inline
  previews.

## Plugin Consolidation

**mini.nvim**: single `'nvim-mini/mini.nvim'` spec with `event = 'VeryLazy'`.
All 13 modules configured in one `config` function, organized by fold sections:
Text Editing (ai, operators, surround, move, pairs), General Workflow
(bracketed, files), Appearance (icons, statusline, notify, cursorword, hipatterns),
Keymap Discovery (clue).

**snacks.nvim**: single spec with `lazy = false`, `priority = 1000` per
official docs. Module configs in `opts`, all keymaps in `keys` array.
`pickers.lua` is a utility module providing layout config, wrapper functions,
and custom pickers (todo comments, colorscheme, buffers) — no `setup_keymaps()`.

## Development Notes

- **Window resize/swap convention** (smart-splits.nvim): lowercase
  `<leader>wh/j/k/l` = resize (tmux-aware), uppercase `<leader>wH/J/K/L` =
  swap. `<leader>wz` = split horizontal (freed `wh` for resize).
- **options.lua API convention**: use `o` (`vim.o`) for scalar options, `opt`
  (`vim.opt`) only for table-valued assignments (`listchars`, `fillchars`) or
  `:append()`/`:remove()` methods, and `vim.g` directly for global variables
- **Timing chain**: `ttimeoutlen=5` (key code sequences) + tmux `escape-time 0`
  + Ghostty atomic key codes = instant Esc-to-Normal. Do not increase
  `ttimeoutlen` above ~10ms or Esc will feel laggy.
- **Commenting**: built-in `gc`/`gcc` (Neovim 0.10+), no plugin needed
- **LSP progress**: mini.notify built-in `lsp_progress` (no fidget.nvim)
- **Cursor word highlight**: two-tier system — LSP `documentHighlightProvider`
  (semantic, per-buffer) with mini.cursorword (lexical) as universal fallback.
  LSP-capable buffers disable mini.cursorword via `vim.b.minicursorword_disable`.
  Shared toggle: `<leader>tw` sets `vim.g.cursor_highlight_disable` (checked by
  both systems). LspDetach re-enables mini.cursorword for the buffer.
- **Marker fold system**: centralized in `autocmds.lua` via `marker_fold_filetypes`
  whitelist (`javascript`, `julia`, `lua`, `python`, `toml`, `vim`). A `FileType`
  autocmd enforces `foldmethod=marker` (overrides Neovim 0.12 defaults), then
  registers a buffer-local `BufWinEnter` (100ms defer) that collapses all folds
  and opens the one containing the cursor. Guarded by `vim.b.large_file`. Markdown
  is excluded (uses `foldmethod=expr` in `ftplugin/markdown.lua`). To add a
  filetype, append it to the `marker_fold_filetypes` table — no other changes
  needed. Global `zv`/`zj`/`zk` fold cycling in `keymaps.lua` handles ongoing
  navigation (foldmethod-agnostic).
- Format on save via conform.nvim (skips files >100KB)
- Lint debounce: 100ms on BufWritePost/InsertLeave
- Reload config: `:source $MYVIMRC` or `<leader>xb` (source current file)
- Check LSP: `:LspInfo` — check Mason: `:Mason`
- Profile startup: `<leader>lp` (~24ms startup, 10/29 plugins loaded at start)
- View keymaps: `<leader>sk`
- **Treesitter incremental selection**: uses nvim 0.12 built-in
  `vim.treesitter._select` API (not the plugin's `incremental_selection`
  module). `<A-o>` expands to parent node (outer), `<A-i>` shrinks to
  child node (inner). Works in n/x/o modes, count-aware (e.g., `3<A-o>`).
  Falls back to `vim.lsp.buf.selection_range()` for buffers without a
  treesitter parser. Keymaps defined in `core/keymaps.lua`. Triggered via
  Cmd+Alt+o/i in WezTerm (AeroSpace intercepts bare Alt+letter).
- **Alt key convention**: keymaps use `<A-...>` (not `<M-...>`) to
  explicitly bind to the physical Alt/Option key, since `<M-...>` (Meta)
  can be remapped. In WezTerm, press Cmd+Alt+letter to trigger `<A-...>`
  bindings (bare Alt is intercepted by AeroSpace for workspace switching).
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
