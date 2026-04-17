# R Configuration

- **Docs**: <https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html>
- **Installed version**: R 4.5.3 (verified 2026-04-15, installed via `r-app` cask)

This directory contains documentation only — no runtime R config. R env vars
are set via zsh (`config/zsh/conf.d/00-z1-env-vars-xdg.zsh`).

## Why `r-app` cask (not `r` formula)

The `r-app` cask installs CRAN's official macOS framework R at
`/Library/Frameworks/R.framework`. This is required because:

- **CRAN binary packages**: `install.packages()` uses pre-compiled binaries
  that match the framework build. The Homebrew `r` formula has different ABI
  (OpenBLAS, GCC) — all packages would recompile from source (slow, fragile).
- **Editor detection**: Positron, RStudio, and VSCode auto-detect framework R.
  The formula version requires manual PATH/config to be found.
- **Trade-off**: `r-app`'s CLI R uses macOS `libedit` instead of GNU readline,
  so terminal R has no command history. Use IDE consoles for interactive work
  where history matters.

## What this setup actually does

One env var, set in `config/zsh/conf.d/00-z1-env-vars-xdg.zsh`:

```zsh
export R_LIBS_USER="$XDG_DATA_HOME/r/library/%v"
```

R expands `%v` to the minor version (e.g. `4.5`), so packages install to
`~/.local/share/r/library/4.5/`. `install.conf.yaml` pre-creates the versioned
directory — R silently drops `R_LIBS_USER` from `.libPaths()` if the dir does
not exist.

## What this setup does NOT do

`R_HISTFILE` is intentionally **not set**. Empirical verification (2026-04-17):

| IDE / context        | Writes to `R_HISTFILE`? | Actual history mechanism                         |
| -------------------- | ----------------------- | ------------------------------------------------ |
| Terminal R (r-app)   | no                      | libedit — no history at all                      |
| RStudio              | no (documented)         | `~/Library/Application Support/RStudio/` DB      |
| Positron (ark)       | no (not in ark source)  | Jupyter protocol history + Positron storage     |
| VSCode (vscode-R)    | no                      | spawns r-app `R` in VSCode terminal — same libedit limitation |

Setting `R_HISTFILE` has no effect in any of these contexts, so it is omitted.

## XDG Layout

| Artifact       | Location                              | Managed by          |
| -------------- | ------------------------------------- | ------------------- |
| User library   | `$XDG_DATA_HOME/r/library/4.5/`       | R via `R_LIBS_USER` |
| User env file  | not used (`R_ENVIRON_USER` unset)     | —                   |
| User Rprofile  | not managed (preserves renv compat)   | —                   |
| History        | not stored (r-app has no readline)    | —                   |
| Workspace      | `.RData` suppressed via `rq` alias    | `--no-save` flag    |

## Startup Precedence (reference)

```
1. Renviron.site  ([R_HOME]/etc/Renviron.site)
2. User Renviron  (R_ENVIRON_USER → unset; searches cwd then HOME; nothing found)
3. Rprofile.site  ([R_HOME]/etc/Rprofile.site)
4. User Rprofile  (R_PROFILE_USER → unset; searches cwd then HOME — this is
                   intentional so renv's project-level .Rprofile still works)
5. .RData         (if present in cwd; suppressed by rq alias)
6. .First()       (if defined in Rprofile)
7. .First.sys()   (loads default packages)
```

`R_PROFILE_USER` is deliberately not set — setting it disables R's cwd search
for project-level `.Rprofile`, which breaks renv.

## Shell Alias

```zsh
alias rq='R -q --no-save --no-restore-data'
```

- `-q`: suppresses startup banner
- `--no-save`: skip `.RData` workspace save on exit
- `--no-restore-data`: skip `.RData` restore on startup
- Terminal history does not work (r-app lacks readline); use IDE consoles

## Known Limitations / Gaps

- **No terminal history**: `r-app` uses libedit (not GNU readline). Terminal
  R cannot save or restore command history. `R_HISTFILE` is a no-op here.
  Use an IDE console for interactive work where history matters.
- **`~/.RData` gap**: `rq` prevents `.RData` creation, but plain `R` run in
  `$HOME` (answering "y" to "Save workspace?") will still write `~/.RData`.
  Not currently enforced globally.
- **`~/.Rprofile` fallback**: R falls back to `~/.Rprofile` if cwd has no
  `.Rprofile`. Not set intentionally (renv). If one ever appears in `$HOME`,
  R will read it — delete it manually if unwanted.
- **Versioned library dir must exist**: R only adds `R_LIBS_USER` to
  `.libPaths()` if the directory exists. `install.conf.yaml` creates it
  after R is installed. After an R major.minor upgrade, re-run `./install`
  to create the new versioned dir.
- **GUI launches from Dock/Spotlight**: do not inherit zsh env vars, so
  `R_LIBS_USER` is not set. Launch IDEs from a terminal for XDG compliance.

## First-Time Migration

Delete any stale R files from HOME (if present):

```bash
rm -f ~/.Rhistory ~/.RData ~/.Rprofile ~/.Renviron ~/.Rapp.history
```
