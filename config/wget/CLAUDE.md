# wget Configuration

- **Docs**: https://www.gnu.org/software/wget/manual/
- **Installed version**: GNU Wget 1.25.0 (verified 2026-02-26)

## File Structure

| File    | Purpose               |
| ------- | --------------------- |
| `wgetrc`| Runtime flag defaults |

## Key Settings

- Timestamping enabled
- No parent directory traversal
- 60-second timeout, 3 retries
- Follow FTP links
- Robots.txt ignored
- Server response printed

## Development Notes

- Config path set via `WGETRC` in zsh env
