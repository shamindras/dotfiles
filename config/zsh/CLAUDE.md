# Zsh Configuration

## Overview

Modular zsh config with custom "Z1" framework. Numbered `conf.d/` files ensure
deterministic load order. Custom plugin system (git-based, no external manager).
18 autoloaded functions in `functions/`.

- **Docs**: https://zsh.sourceforge.io/Doc/
- **Installed version**: zsh 5.9 (system `/bin/zsh`, verified 2026-03-25)

## Architecture

### File Structure

```
config/zsh/
├── .zshenv                           # ZDOTDIR + XDG exports + dir creation
├── .zshrc                            # Entry point: Z1 init + sources conf.d/*
├── completions/                      # Custom _toolname completion files (.gitkeep)
├── conf.d/                           # Modular configs (sourced alphabetically)
│   ├── 00-z1-env-vars-xdg.zsh       # XDG paths for tools (~95 lines)
│   ├── 01-z1-env-vars-gen.zsh       # General env vars, PATH, Homebrew
│   ├── 02-z1-funcdir.zsh            # Autoload function directory
│   ├── 03-z1-memoize.zsh            # __memoize_cmd (caches command output 20h)
│   ├── 04-z1-directory.zsh          # Directory options, pushd stack
│   ├── 05-z1-editor.zsh             # Vi keybindings, smart-enter, zsh-no-ps2
│   ├── 06-z1-history.zsh            # History: 100k entries, no share
│   ├── 07-z1-utility.zsh            # Misc options, bracketed paste
│   ├── 08-z1-plugins.zsh            # Custom plugin manager (clone/update/compile)
│   ├── 09-z1-completions.zsh        # Completion system, 50+ zstyle rules
│   ├── 10-z1-brew-apps.zsh          # zoxide, fzf, atuin (cached via __memoize_cmd)
│   ├── 11-z1-aliases.zsh            # 90+ aliases (regular, suffix, global)
│   └── 12-z1-prompt.zsh             # Simple vcs_info prompt
└── functions/                        # Autoloaded functions (18 files)
    ├── smart-enter                   # ZLE widget: git status + eza on empty Return
    ├── k, ki                         # Zettelkasten (zk) wrappers
    ├── y                             # Yazi wrapper (preserves cwd)
    ├── ua                            # Activate nearest uv Python venv
    ├── wash                          # Clean .DS_Store, swap, backup files
    ├── mcd                           # mkdir + cd via zoxide
    ├── colormap                      # Print terminal 256-color map
    ├── sesh-reset                    # Force-recreate sesh tmux session
    ├── tmux-resize                   # Pre-resize tmux for TUI apps
    ├── convcomm                      # Conventional commit helper (gum)
    ├── zr                            # Reload zsh config (tmux-aware)
    └── ...                           # br, rmt, up, ffc, gi, brew_rebuild
```

### Loading Order

1. `.zshenv` — sets `ZDOTDIR`, exports XDG variables, creates XDG directories
2. `.zshrc` — initializes Z1 framework, defines `z1_confd`
3. `z1_confd` — sources all `conf.d/*.zsh` in alphabetical order
4. Function calls in sequence: funcdir → directory → vi_keybindings →
   history → utility → plugins → completions → brew_apps → aliases → prompt

### Naming Convention

`NN-z1-*.zsh` — numbered prefix for deterministic order. Each file defines
one or more `z1_*` functions called by `.zshrc`.

### File Conventions

- **No shebangs**: sourced files and autoloaded functions do not have `#!/bin/zsh`
  (they are never executed directly). Each file ends with `# vim: ft=zsh`.
- **Emulate -L zsh**: functions use `emulate -L zsh` to isolate option changes
- **Lazy autoload**: functions in `fpath` not loaded until called
- **Background compinit**: `.zcompdump.zwc` compiled async (`&!`)
- **Memoization**: `__memoize_cmd` caches command output for 20 hours
  (used for fzf init, zoxide init, atuin init)
- **No plugin manager**: custom `plugin-clone/update/compile` functions
- **No .zwc pre-compilation**: tested and found negligible benefit (~1ms)
  for these small config files; the fork overhead outweighed savings

### Env Var Assignment Convention

- **Direct assignment** for tool-specific paths: `export VAR="value"`
- **Conditional** for EDITOR/VISUAL/PAGER/BROWSER: `export VAR="${VAR:-value}"`
  (preserves IDE terminal overrides like VS Code)
- HISTFILE set at **top level** of `06-z1-history.zsh` (outside function body)
  so it's active before any function runs
- **ZDOTDIR** in `.zshenv` uses bare assignment (no `export`) per romkatv's
  advice — zsh reads it internally, child processes re-source `.zshenv`

### Function Docstring Convention

All functions use `##?` docstrings:

```
##? name - one-line description
##?
##? usage:
##?   name [options] [args...]
##?
##? options:
##?   -h, --help  show help
##?
##? examples:
##?   name foo    # does bar
```

Help is extracted via `grep "^##?" "${(%):-%x}" | cut -c 5-`.
ZLE widgets (e.g., `smart-enter`) omit `-h` handling since they operate on
`$BUFFER`, not `$1`.

## XDG Integration

XDG base directory variables are exported in `.zshenv` so they're available
to all zsh invocations (interactive, scripts, cron, `zsh -c`).

`00-z1-env-vars-xdg.zsh` sets XDG paths for tools including bat, zoxide,
gh, npm, node, cargo, tmux, ipython, python. All tools use proper XDG base
directories. HISTFILE uses `XDG_STATE_HOME/zsh/history`.

## Editor & Keybindings (`05-z1-editor.zsh`)

- Vi mode (`bindkey -v`) with emacs-style Ctrl-A/E for line navigation
- `smart-enter`: empty Return → git status + eza; non-empty → execute
- `zsh-no-ps2`: validates syntax before execution; incomplete commands get
  a newline in the edit buffer instead of the confusing PS2 `>` prompt.
  Chained with smart-enter via `zstyle ':zsh-no-ps2:' accept-line smart-enter`.
  Source: https://github.com/romkatv/zsh-no-ps2

## Alias Categories

| Category   | Examples                                                    |
| ---------- | ----------------------------------------------------------- |
| Navigation | `cd=z`, `..=z ..`, `dots`, `reps`, `conf`                  |
| System     | `c=clear+tmux`, `b=bat`, `l=ls -la`, `tree`                |
| Brew       | `bu=update+upgrade(greedy-auto-updates)+cleanup`            |
| Dev        | `n=nvim`, `lg=lazygit`, `ghd=gh dash`, `cl=claude`, `clr=claude --resume` |
| Zk         | `kd=daily`, `kis=idea`, `ks=search`                        |
| Suffix     | `.pdf→Skim`, `.jpg→Preview`, `.mp4→VLC`                    |
| Global     | `H=head`, `L=bat`, `G=rg`, `C=pbcopy`, `J=jq`             |

## Homebrew Env Vars (in `01-z1-env-vars-gen.zsh`)

| Variable                  | Value                    | Effect                                      |
| ------------------------- | ------------------------ | ------------------------------------------- |
| `HOMEBREW_NO_ANALYTICS`   | `1`                      | Disable analytics                           |
| `HOMEBREW_CASK_OPTS`      | `--appdir=/Applications` | Default cask install location               |
| `HOMEBREW_UPGRADE_GREEDY` | `1`                      | `brew upgrade` includes auto-updating casks |
| `HOMEBREW_NO_ENV_HINTS`   | `1`                      | Suppress "Hide these hints" boilerplate     |
| `HOMEBREW_AUTOREMOVE`     | `1`                      | Auto-remove orphaned deps on upgrade        |

## Cross-Tool Integration

| Tool   | Integration                                        |
| ------ | -------------------------------------------------- |
| tmux   | `tmux-resize` before TUI apps, `c` clears history |
| zoxide | Replaces `cd`, used in all nav aliases             |
| fzf    | Ctrl-T (files), Ctrl-R (history), Alt-C (dirs)    |
| yazi   | `y` wrapper preserves cwd on exit                  |
| zk     | `k`/`ki` functions with template sync              |
| sesh   | `sesh-reset` for session recovery                  |
| uv     | `ua` activates nearest Python venv                 |

## Development Notes

- Reload: `zr` function (tmux-aware, refreshes all panes)
- Profile startup: `ZSH_PROFILE=1 zsh`
- Measure: `time zsh -i -c exit` (~24ms typical)
- Functions support `-h`/`--help` (grep `##?` lines for docs)
- History: 20k in-memory, 100k on-disk, no cross-session sharing
- FZF theme: Catppuccin Mocha (aligned with project-wide theme)
- Flush memoized caches: `rm ~/.cache/zsh/memoized/*.zsh`
