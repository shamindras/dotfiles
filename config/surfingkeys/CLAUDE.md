# Surfingkeys Configuration

- **Docs**: https://github.com/nicknisi/surfingkeys-config
- **Installed version**: N/A (browser extension)

## File Structure

| File                     | Purpose                              |
| ------------------------ | ------------------------------------ |
| `surfingkeys-config.js`  | Keybindings and omnibar settings     |

## Key Settings

- **Omnibar**: middle position, 10 max results
- **Tab navigation**: h/l for prev/next (Vimium-style)
- **Tab reorder**: `<` and `>` for left/right
- **Link hints**: Ctrl-F for safe mode on macOS
- **Rich hints**: 100ms delay for multi-key sequences

## Video Site Key Unmapping

A `baseVideoUnmapKeys` constant (`['f', 'm']`) defines common keys unmapped
on all video sites so native player shortcuts work. Sites with extra player
keys spread the base and append their own:

| Key set                                    | Keys                    | Sites                                                                                         |
| ------------------------------------------ | ----------------------- | --------------------------------------------------------------------------------------------- |
| `baseVideoUnmapKeys`                           | `['f', 'm']`              | Netflix, Amazon, Prime Video, HiAnime, AniCrush, Peacock, Paramount+, Dailymotion, iView ABC |
| `[...baseVideoUnmapKeys, 't', 'c']`           | `['f', 'm', 't', 'c']`   | YouTube                                                                                       |
| `[...baseVideoUnmapKeys, 't', 'c', 'w']`     | `['f', 'm', 't', 'c', 'w']` | Bilibili                                                                                   |
| `[...baseVideoUnmapKeys, 'c', 'j', 'k']`     | `['f', 'm', 'c', 'j', 'k']` | Crunchyroll                                                                                |

## Site-Specific Key Unmapping (Non-Video)

| Site               | Keys unmapped   | Section          |
| ------------------ | --------------- | ---------------- |
| `mail.google.com`  | `a,b,c,e,f,g,j,k,m,r,v,x,X,/` | Google Services |
| `docs.google.com`  | `p,m,/`         | Google Services  |
| `calendar.google.com` | `d,m`        | Google Services  |
| `drive.google.com` | `/`             | Google Services  |
| `duckduckgo.com`   | `/`             | Other Sites      |
| `containerstore.com` | `p`           | Other Sites      |
| `walmart.wd5.myworkdayjobs.com` | `b,m,p` | Other Sites |
| `shamindras.com`   | `f`             | Other Sites      |
| `localhost:\d+` (marimo) | see Marimo Notebooks section below | Marimo Notebooks |

## Gmail Shortcuts

### Navigation (`ag` prefix — go to view)

Auto-detects account number from URL (`/u/0/`, `/u/1/`, etc.) via `gmailNavigate()`.

| Shortcut | View      | Mnemonic      |
| -------- | --------- | ------------- |
| `aga`    | all mail  | **a**ll       |
| `agd`    | drafts    | **d**rafts    |
| `agi`    | inbox     | **i**nbox     |
| `agr`    | starred   | sta**r**red   |
| `ags`    | scheduled | **s**cheduled |
| `agt`    | sent      | sen**t**      |
| `agz`    | snoozed   | snoo**z**ed   |

### Actions (`ar` prefix — perform action)

| Shortcut | Action    | Mnemonic                         |
| -------- | --------- | -------------------------------- |
| `ara`    | reply all | **a**ction → **r**eply → **a**ll |

## Marimo Notebooks

marimo uses vim-style keybindings when `[keymap].preset = "vim"` is set in
`marimo.toml`. SK auto-disables inside focused cells, but its default
bindings fire in marimo's **command mode** (no cell focused). The config
surgically unmaps conflicting keys on any `localhost:\d+` URL — covers the
default port `2718` and any custom `--port` override.

Two constants drive the unmap:

| Constant                | Keys unmapped                                            | Reason                               |
| ----------------------- | -------------------------------------------------------- | ------------------------------------ |
| `marimoUnmapKeys`       | `a, b, d, j, k, m, u, G, /, ?, ym, ya, yf, yp, yM, o, O` | marimo command-mode + yank/omnibar   |
| `marimoCtrlUnmapKeys`   | `<Ctrl-b/g/k/l/m/n/s/w/y/z/e/q/d/t/x>`                   | SK search-engine shortcuts           |

**Kept active on marimo pages**: tab/history navigation (`h`, `l`, `H`,
`L`, `gh`, `gl`, `t`, `T`, `zz`, `zh`, `zl`, `J`, `K`), tab reorder
(`<`, `>`), and **link hints** (`f`, `F`, `gf`, `Ctrl-f`) — link hints
are how you focus a marimo cell from a cold notebook load (marimo has
no keyboard-only "focus first cell" path; an SK hint over a CodeMirror
editor lets you click into one).

> **Why not `af`?** SK's default `af` (link hints in active new tab) is
> a chord starting with `a`, but `a` is unmapped on marimo (collides
> with marimo's "add cell above"). Use `f` (your remap = "hints in new
> tab") instead.

**Out of scope** (deferred; add if needed): `127.0.0.1:\d+`, `marimo.app`
(WASM playground).

## Development Notes

- JavaScript config; Vimium-compatible mappings for consistency
- Load into the Surfingkeys extension settings manually in **each browser
  separately** (Firefox + Chrome) — there's no auto-sync from the dotfiles
  repo to the extension storage
