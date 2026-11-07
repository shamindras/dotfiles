# television Configuration

- **Docs**: https://alexpasmantier.github.io/television/user-guide/channels
- **Installed version**: written against the tv 0.15 docs (2026-11-06); replace
  with `tv --version` output once checked on the Mac

## File Structure

| File                    | Purpose                                                |
| ----------------------- | ------------------------------------------------------ |
| `cable/site-posts.toml` | shamindras.com posts: pick one, `site-post open` it    |
| `cable/site-new.toml`   | shamindras.com templates: pick one, `site-post new`    |

Cable channels are one TOML file each in `cable/`; run one with
`tv <name>` (`tv site-posts`, `tv site-new`).

## Development Notes

- Both channels call `~/.config/bin/site-post` (see `config/bin/CLAUDE.md`),
  the single source of truth for where the site lives; the same actions
  are `<leader>e*` in Neovim and `es` in zsh.
- `just posts --plain` rows are `short|state|title|file`. `|` is also the
  template pipe operator, so `split` escapes it as `\|` (in TOML literal
  strings; `\\|` in basic strings).
- Actions use `mode = "execute"`: tv hands the terminal to `just`.
