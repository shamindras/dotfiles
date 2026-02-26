# marimo Configuration

- **Docs**: https://docs.marimo.io/
- **Installed version**: N/A (Python package, check via `marimo --version`)

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

## Development Notes

- AI provider API keys set via env vars (not in config)
- Python reactive notebook alternative to Jupyter
