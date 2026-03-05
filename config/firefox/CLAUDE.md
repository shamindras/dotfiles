# firefox

## Docs

- Mozilla user.js reference: <https://kb.mozillazine.org/User.js_file>
- userChrome.css: <https://www.userchrome.org>
- Right-click cleanup: <https://joshua.hu/firefox-making-right-click-not-suck>

## Installed version

- Firefox 148.0

## File structure

| Path                  | Purpose                                      |
| --------------------- | -------------------------------------------- |
| `user.js`             | about:config preference overrides            |
| `chrome/userChrome.css` | Context menu CSS rules (hide unwanted items) |

## Key settings

| Section              | Summary                                              |
| -------------------- | ---------------------------------------------------- |
| Privacy & Telemetry  | Disable studies, health reports, telemetry, DNT on   |
| AI/ML                | All 15 AI/ML prefs disabled                          |
| Search & URL Bar     | All suggestions, shortcuts, sponsored content off    |
| New Tab Page         | No Pocket, no sponsored content/top sites            |
| Network              | No DNS prefetch, no speculative connections           |
| Sidebar & Tabs       | Vertical tabs, sidebar right, smart groups off       |
| Media                | PiP toggle off                                       |
| PDF Viewer           | page-fit zoom, no sidebar, spread mode               |
| UI                   | No about:config warning, bookmarks hidden, dark      |
| Session & Auth       | Restore session, don't save passwords                |
| Context Menu Cleanup | Remove 9 bloat items via about:config                |
| userChrome.css       | Enable legacy stylesheet loading                     |

## Development notes

- Firefox's macOS sandbox blocks symlinks — files are **copied** (rsync)
  into the profile directory, not symlinked
- After editing configs: `just firefox_sync` then restart Firefox
- The setup script (`scripts/setup-firefox`) finds the default profile
  automatically from `profiles.ini`
- `print.enabled` stays true (Cmd+P works); "Print..." context menu item
  is hidden via userChrome.css instead
