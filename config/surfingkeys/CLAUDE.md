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
| `localhost:2718`    | `a,m`           | Other Sites      |
| `shamindras.com`   | `f`             | Other Sites      |

## Development Notes

- JavaScript config; Vimium-compatible mappings for consistency
- Load into Surfingkeys extension settings manually
