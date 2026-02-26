# zk Configuration

- **Docs**: https://github.com/zk-org/zk
- **Installed version**: zk 0.15.2 (verified 2026-02-26)

## File Structure

| File          | Purpose                                 |
| ------------- | --------------------------------------- |
| `config.toml` | Notebook config (groups, aliases, LSP)  |
| `templates/`  | Note templates (daily.md, idea.md)      |

## Key Settings

- **Notebook dir**: `$HOME/DROPBOX/notes/zk`
- **Filename**: `{{slug title}}-{{id}}` with 5-char alphanum IDs
- **Groups**: journal (daily auto-numbered), ideas (with template)
- **Aliases**: daily, edit (interactive), list, search
- **Editor**: nvim, pager: less, fzf-preview: bat
- **LSP**: wiki-title link hints, dead-link errors

## Development Notes

- Zsh functions `k`/`ki` wrap zk with template sync from config to notebook
- Nvim integration via zk-nvim plugin (`<leader>k` prefix)
- Setup script: `scripts/setup-zk`
