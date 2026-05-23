# marimo Configuration

- **Docs**: https://docs.marimo.io/
- **Installed version**: `0.23.1` (Apr 2026, checked via `uv run marimo --version` in `../codebox`)
- **Runtime**: marimo is not installed globally — it's `uv`-managed in
  `/Users/shamindras/Dropbox/repos/codebox`. Launch with
  `cd ~/Dropbox/repos/codebox && uv run marimo edit <path>`.

## File Structure

| File          | Purpose                             |
| ------------- | ----------------------------------- |
| `marimo.toml` | Editor, runtime, AI, LSP settings   |

## Key Settings

- **Line length**: 79 (formatting)
- **AI models**: Claude Sonnet (chat), Opus 4.6 (edits)
- **Theme**: light, code font size 20
- **Runtime**: autorun on cell change, auto_reload enabled
- **Package manager**: `uv` (not pip)
- **LSP**: ruff + mypy enabled, pylint/flake8 disabled

## Keymap

- **Preset**: `"vim"` — CodeMirror vim in cells + vim-style cell navigation
  in command mode (`j`/`k`/`G`/`gg`/`u`/etc.).
- **Escape**: raw `Esc` for insert → normal. No `jj`/`jk` remap, no `vimrc`
  file. CodeMirror's vim implementation can't parse nvim Lua config, so
  reuse is not possible; a bespoke vimrc is deferred until actually needed.
- **No `Esc` override for cell blur**: marimo's hotkey parser only accepts
  single-key combos (e.g. `Mod-Escape`, `Shift-Escape`) — chord syntax
  like `"Escape Escape"` is silently invalid, and a plain `"Escape"`
  override races CodeMirror-vim for the same key (marimo's global hotkey
  layer wins, so the first `Esc` blurs the cell and skips normal mode
  entirely, requiring a click back in). Verified against marimo `0.23.1`
  by inspecting `cell.vimEnterCommandMode` default key in the bundled JS
  (`useEventListener-*.js`); all key strings use single combinations.
- **Insert → Normal → Cell-focus flow** (the working alternative):
  - `Esc` → insert → normal (CodeMirror-vim, no contention since marimo
    has no `Escape` override).
  - `Cmd-Esc` (marimo default for `command.vimEnterCommandMode`) →
    normal → cell focus mode (Jupyter-style).
  - `Enter` from cell focus → re-enters the cell; CodeMirror-vim restores
    its last mode, so if you went through normal first you land back in
    normal (not insert).
  - **Discipline**: always press `Esc` (to normal) *before* `Cmd-Esc` (to
    blur). Going `Insert → Cmd-Esc` directly skips normal, so re-entry
    drops you back into insert.
- **`destructive_delete = true`**: `dd` in command mode deletes cells
  containing code (no confirmation prompt).
- **Surfingkeys coexistence**: SK auto-disables inside focused cells, so
  vim bindings fire cleanly while editing. A surgical unmap on any
  `localhost:\d+` URL handles command-mode keys — see
  `config/surfingkeys/CLAUDE.md` for the full list.

### Recovery bindings (when focus is lost)

marimo does **not** auto-focus a cell on notebook load, and after certain
actions (`dd` → `Cmd-z`, undo delete) no cell is focused either.

**Defaults `Mod-Shift-{j,k,f,g}` conflict with Firefox** on macOS
(`Cmd-Shift-J` = Browser Console, `Cmd-Shift-K` = Web Console,
`Cmd-Shift-G` = Find Previous). This repo rebinds them to
`Ctrl-Shift-*` via `[keymap.overrides]` in `marimo.toml`:

| Shortcut        | Action                 | marimo action id     | Needs prior focus? |
| --------------- | ---------------------- | -------------------- | ------------------ |
| `Ctrl-Shift-F`  | Jump to first cell     | `global.focusTop`    | **No** — use from cold start |
| `Ctrl-Shift-G`  | Jump to last cell      | `global.focusBottom` | **No** — use from cold start |
| `Ctrl-Shift-J`  | Focus next cell        | `cell.focusDown`     | Yes — relative     |
| `Ctrl-Shift-K`  | Focus previous cell    | `cell.focusUp`       | Yes — relative     |

**Startup handshake**: on fresh notebook load (or after any state that
leaves nothing focused), press `Ctrl-Shift-F` (or `G`) first to anchor
onto a cell. Only then do the relative `Ctrl-Shift-J`/`K` bindings and
plain `j`/`k` vim cell-nav work.

### Undo / redo

- `Cmd-z` → `cell.undo` (restores a deleted cell; works from command mode
  or inside a cell). marimo does **not** bind `u` to undo (divergence
  from Jupyter/vim convention) — use `Cmd-z` instead. Don't override
  `cell.undo` to `u` without care: CodeMirror-vim also uses `u` for
  text-level undo inside focused cells, and the override can swallow it.
- `Cmd-Shift-z` → `cell.redo`.

## Reload

`marimo.toml` changes require a **marimo server restart** — a page refresh
is not enough. Kill and relaunch via:

```bash
cd ~/Dropbox/repos/codebox && uv run marimo edit <notebook>
```

## Development Notes

- AI provider API keys set via env vars (not in config)
- Python reactive notebook alternative to Jupyter
