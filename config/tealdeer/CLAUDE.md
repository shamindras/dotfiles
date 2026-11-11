# tealdeer Configuration

- **Docs**: https://github.com/dbrgn/tealdeer
- **Installed version**: tealdeer 1.8.1 (verified 2026-02-26)

## File Structure

| File          | Purpose                      |
| ------------- | ---------------------------- |
| `config.toml` | Display and cache settings   |

## Key Settings

- **Display**: non-compact, with pager
- **Styling**: red commands, green examples, blue code/variables
- **Auto-update**: enabled
- **Cache dir**: `~/.cache/tealdeer` (env vars are not expanded, but a leading `~` is: tealdeer 1.9.1 `expand_home`, checked with `tldr --show-paths`)

## Development Notes

- Update cache: `tldr --update`
- Aliased as `tldr` in zsh
