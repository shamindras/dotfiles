# GNU Parallel Configuration

- **Docs**: https://www.gnu.org/software/parallel/
- **Installed version**: GNU parallel 20260222 (verified 2026-02-26)

## File Structure

| File     | Purpose                     |
| -------- | --------------------------- |
| `config` | Runtime flag defaults       |

## Key Settings

- `--will-cite` (suppress citation notice)
- Progress bar enabled
- Job count: 50% of CPU cores
- Job logging commented out (enable for resume capability)

## Development Notes

- Config path set via `PARALLEL_HOME` in zsh env
