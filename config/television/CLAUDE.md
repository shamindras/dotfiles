# television Configuration

- **Docs**: https://alexpasmantier.github.io/television/user-guide/channels
- **Installed version**: written against the tv 0.15 docs (2026-11-06); replace
  with `tv --version` output once checked on the Mac

## File Structure

| File                    | Purpose                                                |
| ----------------------- | ------------------------------------------------------ |
| `cable/site-posts.toml` | shamindras.com posts: pick one, `just open` it         |
| `cable/site-new.toml`   | shamindras.com templates: pick one, `just new` from it |

Cable channels are one TOML file each in `cable/`; run one with
`tv <name>` (`tv site-posts`, `tv site-new`).

## Development Notes

- Both channels run the site's `just` recipes in
  `$DROPBOX_REPOS_DIR/ss_personal_website`; Neovim has the same actions
  under `<leader>e` (see `config/nvim/CLAUDE.md`).
- `just posts --plain` rows are `short|state|title|file`. `|` is also the
  template pipe operator, so `split` escapes it as `\|` (in TOML literal
  strings; `\\|` in basic strings).
- Actions use `mode = "execute"`: tv hands the terminal to `just`.
