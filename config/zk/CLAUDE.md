# zk Configuration

- **Docs**: https://github.com/zk-org/zk
- **Installed version**: zk 0.15.4 (verified 2026-05-29)

## File Structure

| File          | Purpose                                                              |
| ------------- | -------------------------------------------------------------------- |
| `config.toml` | Notebook config (groups, aliases, LSP)                               |
| `templates/`  | Note templates (daily.md, idea.md)                                   |
| `notebook/`   | Canonical prettier + markdownlint configs for `$DROPBOX_NOTES_DIR`   |

## Key Settings

- **Notebook dir**: `$HOME/Dropbox/notes/zk`
- **Filename**: `{{slug title}}-{{id}}` with 5-char alphanum IDs
- **Groups**: journal (daily auto-numbered), ideas (with template)
- **Aliases**: daily, edit (interactive), list, search
- **Editor**: nvim, pager: less, fzf-preview: bat
- **LSP**: wiki-title link hints, dead-link errors

## Notebook layout (`$HOME/Dropbox/notes/zk/`)

| Path                  | Synced? | Notes                                                              |
| --------------------- | ------- | ------------------------------------------------------------------ |
| `journal/`, `ideas/`  | Yes     | Markdown notes — canonical source of truth, cross-machine via Dropbox. |
| `.zk/`                | **No**  | Marked `com.dropbox.ignored=1` by `setup-zk`. Local-only, regenerable. |
| `.zk/notebook.db`     | **No**  | SQLite index, rebuilt lazily by zk-nvim LSP from the markdown files.   |
| `.zk/notebook.db-wal`, `.zk/notebook.db-shm` | **No** | Transient SQLite WAL sidecars (long-lived during nvim sessions).       |
| `.zk/templates/`      | **No**  | Cache rsync'd locally from `config/zk/templates/` by `sync_templates()` in `config/nvim/lua/shamindras/plugins/zk.lua`. |

## Markdown formatting config (`$DROPBOX_NOTES_DIR/`)

prettier (conform.nvim) and markdownlint-cli2 (nvim-lint) both search upward
from the file being edited, so one config set at the notes root serves the zk
notebook and the scratch directory (`notes/scratch`, a sibling of `zk/`).
`config/zk/notebook/` mirrors the notes tree and is the source of truth;
`scripts/ops/sync-notes-config` copies it out (never symlinks — Dropbox does
not sync symlinks reliably).

| Deployed path                      | Source (`config/zk/notebook/`) | Notes                                            |
| ---------------------------------- | ------------------------------ | ------------------------------------------------ |
| `notes/.prettierrc.yaml`           | `.prettierrc.yaml`             | `printWidth: 120`, `proseWrap: always`           |
| `notes/.prettierignore`            | `.prettierignore`              | Markdown only; skips `.zk/`, `.claude/`          |
| `notes/.markdownlint-cli2.yaml`    | `.markdownlint-cli2.yaml`      | MD013 at 120; MD041 on (scratch starts with H1)  |
| `notes/zk/.markdownlint-cli2.yaml` | `zk/.markdownlint-cli2.yaml`   | Override: MD041 off, frontmatter title not an H1 |

Refresh after editing a tracked copy: `just notes_config_sync` (also part of
`just sync-all`). `./install` runs it via `setup-zk`. Dropbox syncs the
deployed copies to other machines.

Why `.zk/` is Dropbox-ignored: on macOS Tahoe (26.x), `~/Library/CloudStorage/Dropbox`
is a File Provider that materialises files on demand. A synced `notebook.db`
can be partially-resident while SQLite is mid-write, which corrupts B-tree
pages. Keeping `.zk/` local-only removes the entire race.

## Recovery

- **Rebuild a corrupt or missing index**: `./scripts/setup/setup-zk` from the
  dotfiles repo root. Idempotent — backs up a corrupt `notebook.db` to
  `/tmp/notebook.db.corrupt-<ts>.bak`, removes it, and lets the zk-nvim LSP
  rebuild on next markdown buffer open (~500ms for 200 notes).
- **Re-seed `.zk/templates/` from scratch**: `rm -rf
  $ZK_NOTEBOOK_DIR/.zk/templates && ./scripts/setup/setup-zk`. The starter
  templates from `config/zk/templates/` are copied back in. zk-nvim's
  `sync_templates_with_callback` (triggered by `<leader>kD` / `<leader>kI`)
  also refreshes on demand.

## Development Notes

- Zsh functions `k`/`ki` wrap zk with template sync from config to notebook
- Nvim integration via zk-nvim plugin (`<leader>k` prefix)
- Setup script: `scripts/setup/setup-zk`
- Scratch notes live **outside** the notebook (`$DROPBOX_NOTES_DIR/scratch`,
  see `config/nvim/CLAUDE.md` § Scratch Notes). `<leader>np` promotes one into
  `ideas/` via `zk.api.new` (title = H1, `idea.md` template, body appended
  after creation because the template does not render `{{content}}`)
