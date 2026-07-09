# Zsh Configuration

## Overview

Modular zsh config with custom "Z1" framework. Numbered `conf.d/` files ensure
deterministic load order. Plugin system based on
[zsh_unplugged](https://github.com/mattmc3/zsh_unplugged) (git-based, 2 plugins:
zsh-autosuggestions, zsh-syntax-highlighting). 22 autoloaded functions in `functions/`.

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
│   ├── 05-z1-editor.zsh             # Vi keybindings, zsh-no-ps2
│   ├── 06-z1-history.zsh            # History: 100k entries, no share
│   ├── 07-z1-utility.zsh            # Misc options, bracketed paste
│   ├── 08-z1-plugins.zsh            # Plugin system (zsh_unplugged-based, load/update/compile)
│   ├── 09-z1-completions.zsh        # Completion system, 50+ zstyle rules
│   ├── 10-z1-brew-apps.zsh          # zoxide, fzf, atuin (cached via __memoize_cmd)
│   ├── 11-z1-aliases.zsh            # 90+ aliases (regular, suffix, global)
│   └── 12-z1-prompt.zsh             # Simple vcs_info prompt
└── functions/                        # Autoloaded functions (22 files)
    ├── k, ki                         # Zettelkasten (zk) wrappers
    ├── y                             # Yazi wrapper (preserves cwd)
    ├── yt                            # Yazi with preloaded tabs (wash + cwd-follow shim over ~/.config/bin/yazi-tabs)
    ├── ua                            # Activate nearest uv Python venv
    ├── wash                          # Clean .DS_Store, swap, backup files
    ├── mcd                           # mkdir + cd via zoxide
    ├── colormap                      # Print terminal 256-color map
    ├── sc                            # Sesh connect (fzf picker or by name)
    ├── sn                            # Sesh new: ad-hoc session from dirs.list
    ├── sesh-reset                    # Force-recreate sesh.toml sessions
    ├── tmux-resize                   # Pre-resize tmux for TUI apps
    ├── convcomm                      # Conventional commit helper (gum)
    ├── zr                            # Reload zsh config (tmux-aware)
    ├── asr                           # Reload AeroSpace; self-heal stale server
    └── ...                           # br, rmt, up, ffc, gi, brew_rebuild
```

### Loading Order

1. `.zshenv` — sets `ZDOTDIR`, exports XDG variables, creates XDG directories
2. `.zshrc` — initializes Z1 framework, defines `z1_confd`
3. `z1_confd` — sources all `conf.d/*.zsh` in alphabetical order
4. Function calls in sequence: funcdir → directory → vi_keybindings →
   history → utility → completions → plugins → brew_apps → aliases → prompt

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
  (used for fzf init, zoxide init, atuin init) and byte-compiles each cache
  to `.zwc` so subsequent startups source the digest, not the text (~1ms)
- **Plugin system**: zsh_unplugged-based `plugin-load/update/compile` functions;
  plugins stored at `$__zsh_user_data_dir/plugins` (`~/.local/share/zsh/plugins`)
- **No .zwc pre-compilation of config files**: compiling `conf.d/*.zsh`,
  `.zshrc`, `.zshenv` gives 0ms (verified, interleaved bench) — their cost is
  execution (env exports, function defs), not parse — and would drop `.zwc`
  build artifacts into the repo (`~/.config/zsh` symlinks to `config/zsh/`).
  The memoized caches ARE compiled (see Memoization above): they're large,
  sourced every startup, and live in `~/.cache` (no repo pollution).

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
ZLE widgets omit `-h` handling since they operate on `$BUFFER`, not `$1`.

## XDG Integration

XDG base directory variables are exported in `.zshenv` so they're available
to all zsh invocations (interactive, scripts, cron, `zsh -c`).

`00-z1-env-vars-xdg.zsh` sets XDG paths for tools including bat, zoxide,
gh, npm, node, cargo, tmux, ipython, python, R, matplotlib, scikit-learn.
All tools use proper XDG base directories. HISTFILE uses
`XDG_STATE_HOME/zsh/history`.

For tools without an env var (atuin logs, wget HSTS), the XDG path is
set in the tool's own config file instead: `config/atuin/config.toml`
(`[logs] dir`) and `config/wget/wgetrc` (`hsts_file`).

### Aliases are not a substitute for env vars

Shell aliases only apply to interactive zsh. Subprocesses, scripts, cron,
and launchd agents bypass them. Anything that must affect non-interactive
`wget`/`python`/etc. invocations must be an **env var** (inherited by
children) or a **config file** (read by the binary directly) — not an
alias. The `wget --hsts-file` alias in `11-z1-aliases.zsh` remains only
as defense-in-depth for the interactive path; the real fix is the
`hsts_file` directive in `wgetrc`.

### Residual non-XDG items (unfixable)

`xdg-ninja` will always flag these. They are documented here to prevent
re-investigation:

| Path                     | Tool          | Reason                                                    |
| ------------------------ | ------------- | --------------------------------------------------------- |
| `~/.ssh`                 | openssh       | Hardcoded by ssh daemons (DropBear, OpenSSH).             |
| `~/.Trash`               | macOS         | System directory; no override on macOS.                   |
| `~/.dropbox`             | Dropbox       | App-controlled; [dropbox/nautilus-dropbox#5][iss-dropbox].|
| `~/.vscode`              | VSCode        | [microsoft/vscode#3884][iss-vscode].                      |
| `~/.positron`            | Positron      | VSCode fork; inherits the same limitation.                |
| `~/.kindle`              | Amazon Kindle | Proprietary, no XDG support.                              |
| `~/.duckdb`              | DuckDB CLI    | No env var or flag; upstream does not support relocation. |
| `~/.Xauthority`, `~/.serverauth.*` | XQuartz / X11 | `XAUTHORITY` env var risky to set; xdg-ninja warns moving can break X11 sessions. |

[iss-dropbox]: https://github.com/dropbox/nautilus-dropbox/issues/5
[iss-vscode]: https://github.com/microsoft/vscode/issues/3884

## Editor & Keybindings (`05-z1-editor.zsh`)

- Vi mode (`bindkey -v`) with emacs-style Ctrl-A/E for line navigation
- `zsh-no-ps2`: validates syntax before execution; incomplete commands get
  a newline in the edit buffer instead of the confusing PS2 `>` prompt.
  Source: https://github.com/romkatv/zsh-no-ps2

## Alias Categories

| Category   | Examples                                                    |
| ---------- | ----------------------------------------------------------- |
| Navigation | `cd=z`, `..=z ..`, `dots`, `reps`, `conf`                  |
| System     | `c=clear+tmux`, `b=bat`, `l=ls -la`, `tree`                |
| Brew       | `bu=~/.config/bin/brew-update` (canonical pipeline)         |
| Dev        | `n=nvim`, `lg=lazygit`, `ghd=gh dash`, `cl=claude`, `clr=claude --resume`, `rq=R(quiet,no .RData)` |
| Zk         | `kd=daily`, `kis=idea`, `ks=search`                        |
| Suffix     | `.pdf→Skim`, `.jpg→Preview`, `.mp4→VLC`                    |
| Global     | `H=head`, `L=bat`, `G=rg`, `C=pbcopy`, `J=jq`             |

## Homebrew Env Vars (in `01-z1-env-vars-gen.zsh`)

| Variable                  | Value                    | Effect                                      |
| ------------------------- | ------------------------ | ------------------------------------------- |
| `HOMEBREW_NO_ANALYTICS`   | `1`                      | Disable analytics                           |
| `HOMEBREW_CASK_OPTS`      | `--appdir=/Applications` | Default cask install location               |
| `HOMEBREW_UPGRADE_GREEDY` | `1`                      | `brew upgrade` includes auto-updating casks; pkg-cask drop-outs recovered by `brew bundle install` step in `config/bin/brew-update` |
| `HOMEBREW_NO_ENV_HINTS`   | `1`                      | Suppress "Hide these hints" boilerplate     |

## Cross-Tool Integration

| Tool   | Integration                                        |
| ------ | -------------------------------------------------- |
| tmux   | `tmux-resize` before TUI apps, `c` clears history |
| zoxide | Replaces `cd`, used in all nav aliases             |
| fzf    | Ctrl-T (files), Ctrl-R (history), Alt-C (dirs)    |
| yazi   | `y` wrapper preserves cwd on exit; `yt` launches with preloaded tabs (wash by default, `-W` skips; logic in `~/.config/bin/yazi-tabs`); `yh` = home variant; `R w`/`R c` in yazi run `wash`/`clean` on cwd via `zsh -ic` |
| zk     | `k`/`ki` functions with template sync              |
| sesh   | `sc` connect: fzf-pick or `sc <name>` direct (safe reattach); `sn` ad-hoc session from dirs.list; `sesh-reset` force-recreate (`sra` = `--all`, derived from sesh.toml) |
| uv     | `ua` activates nearest Python venv                 |
| aerospace | `asr` reloads config + self-heals post-upgrade stale server; `asf` forced restart |

## Startup Performance

Documented to prevent re-investigation. Startup is ~27–33ms; the cost is
dominated by **execution, not parsing**, so byte-compiling buys little.

Where the time goes (from `ZSH_PROFILE=1 zsh`, per fresh shell):

| Cost                                              | ~Time  | Reducible?                          |
| ------------------------------------------------- | ------ | ----------------------------------- |
| `atuin uuid` fork (`ATUIN_SESSION=$(atuin uuid)`) | ~4ms   | No — see below                      |
| `compinit`                                        | ~3.4ms | Already backgrounds `.zwc` compile  |
| plugin widget/hook binding (autosugg + syntax-hl) | ~2–3ms | No — execution, not parse           |
| parse of the 3 memoized init caches               | ~1ms   | Yes — now `.zwc`-compiled            |

- **`atuin uuid` is unavoidable, incl. in tmux panes.** atuin's init forks
  `atuin uuid` whenever `ATUIN_SHLVL != SHLVL`. A new tmux pane inherits
  `ATUIN_SHLVL` from the server env but its zsh increments `SHLVL`, so the
  guard always fires — every new pane re-forks (verified: a fresh pane gets a
  new `ATUIN_SESSION`, not the inherited one). This is by design (one atuin
  session per shell-nesting level). Pinning the session or hacking the cached
  init to skip it would break history semantics / silently revert on the 20h
  cache regen — not worth ~4ms.
- **Compiling config files gives 0ms** (verified, interleaved bench):
  `conf.d/*.zsh`, `.zshrc`, `.zshenv` cost is execution, not parse, and
  compiling them would drop `.zwc` into the repo (`~/.config/zsh` symlinks to
  `config/zsh/`). Only the memoized caches are compiled (they live in
  `~/.cache`; see Memoization in File Conventions).
- `tzsh` benchmarks a fresh top-level shell; treat its variance skeptically
  (a busy system easily adds 5–10ms — hyperfine will warn about outliers).

## Development Notes

- Reload: `zr` function (tmux-aware, refreshes all panes)
- Profile startup: `ZSH_PROFILE=1 zsh`
- Measure: `time zsh -i -c exit` (~24ms typical)
- Functions support `-h`/`--help` (grep `##?` lines for docs)
- History: 20k in-memory, 100k on-disk, no cross-session sharing
- FZF theme: Catppuccin Mocha (aligned with project-wide theme)
- Flush memoized caches: `rm ~/.cache/zsh/memoized/*.zsh`
