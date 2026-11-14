# Python

- **Docs**: <https://docs.python.org/3/using/cmdline.html#envvar-PYTHONSTARTUP>
- **Installed version**: Python 3.15.2 (`/opt/homebrew/bin/python3`)

## File structure

| File       | Purpose                                                      |
| ---------- | ------------------------------------------------------------ |
| `pythonrc` | Start-up file for the interactive REPL: XDG history location |

## How it is loaded

The `python` unit in `manifest.json` links this folder to `~/.config/python`. `config/zsh/conf.d/00-z1-env-vars-xdg.zsh`
sets:

| Variable         | Value                              |
| ---------------- | ---------------------------------- |
| `PYTHONSTARTUP`  | `$XDG_CONFIG_HOME/python/pythonrc` |
| `PYTHON_HISTORY` | `$XDG_STATE_HOME/python_history`   |

Python runs `PYTHONSTARTUP` only for the interactive REPL, not for scripts.

## pythonrc

Keeps REPL history in `$XDG_STATE_HOME/python_history` instead of `~/.python_history`.

- Python 3.13 and later read `PYTHON_HISTORY` themselves, so the file only makes sure the folder exists.
- Older versions get readline history handled by hand: 10,000 lines, read at start, written at exit.
- Skipped under IPython and bpython, which keep their own history.
