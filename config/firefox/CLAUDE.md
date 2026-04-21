# firefox

## Docs

- Mozilla user.js reference: <https://kb.mozillazine.org/User.js_file>
- Policy templates: <https://mozilla.github.io/policy-templates/>
- policies.json KB: <https://support.mozilla.org/en-US/kb/customizing-firefox-using-policiesjson>
- AI Controls: <https://support.mozilla.org/en-US/kb/firefox-ai-controls>
- userChrome.css: <https://www.userchrome.org>
- Right-click cleanup: <https://joshua.hu/firefox-making-right-click-not-suck>

## Installed version

- Firefox 149.0

## File structure

| Path                    | Purpose                                                    |
| ----------------------- | ---------------------------------------------------------- |
| `user.js`               | about:config prefs (personal, telemetry detail, perf)      |
| `policies.json`         | Enterprise policies (locked AI/telemetry/Pocket/passwords) |
| `chrome/userChrome.css` | Context menu CSS rules (hide unwanted items)               |

## Config split: policies.json vs user.js

- **policies.json** — prefs we NEVER want re-enabled (AI/ML, telemetry,
  Pocket, passwords, new tab sponsored, user messaging, Normandy). All
  locked via enterprise policies so Firefox cannot override them.
- **user.js** — personal/cosmetic prefs (sidebar, PDF, network, context
  menu, performance, UI) that don't need locking.
- No pref appears in both files.

## Key settings

### policies.json (locked)

| Policy / Section          | Summary                                                |
| ------------------------- | ------------------------------------------------------ |
| DisableFirefoxStudies     | Block Mozilla Shield studies                           |
| DisableTelemetry          | Disable core telemetry + data reporting                |
| DisablePocket             | Completely remove Pocket                               |
| PasswordManagerEnabled    | Disable built-in password manager                      |
| GenerativeAI              | Enterprise AI kill switch (Enabled=false, Locked=true) |
| NewTabPage                | New tabs open example.com                              |
| FirefoxHome               | Search only, no tiles/stories/sponsored (locked)       |
| UserMessaging             | No What's New, recommendations, onboarding (locked)    |
| browser.ai.control.*      | 6 AI Controls toggles set to "blocked" + locked        |
| browser.ml.*              | 15 ML engine prefs locked false                        |
| nimbus.rollouts           | Rollout experiments locked off                         |
| app.normandy.*            | A/B testing locked off                                 |

### user.js

| Section              | Summary                                              |
| -------------------- | ---------------------------------------------------- |
| Privacy              | DNT on, container tabs enabled                       |
| Telemetry Detail     | 12 prefs supplementing DisableTelemetry policy       |
| Search & URL Bar     | All suggestions, shortcuts, sponsored content off    |
| New Tab Page         | Sponsored checkboxes hidden                          |
| Network              | No DNS prefetch, no speculative connections           |
| Sidebar & Tabs       | Vertical tabs, sidebar right, smart groups off       |
| Media                | PiP toggle off                                       |
| PDF Viewer           | page-fit zoom, no sidebar, spread mode               |
| UI                   | No about:config warning, bookmarks hidden, dark      |
| Session & Auth       | Restore session, homepage example.com, no pw sync    |
| Security             | HTTPS-only mode enabled                              |
| Performance          | Session history 10, bfcache on, 60s save, hw video   |
| Context Menu Cleanup | Remove 9 bloat items via about:config                |
| userChrome.css       | Enable legacy stylesheet loading                     |

## Post-install checklist

`post-install-checklist.md` lists all user-installed Firefox extensions and
their sync method. Extensions using `storage.local` need manual configuration
on a new machine. The `./install` script prints a reminder pointing to this
file after dotbot completes.

**Keep in sync**: when adding, removing, or changing Firefox extension
settings, update `post-install-checklist.md` to reflect the change.

## Development notes

- Firefox's macOS sandbox blocks symlinks — files are **copied** (rsync)
  into the profile directory, not symlinked
- After editing configs: `just firefox_sync` then restart Firefox
- The setup script (`scripts/ops/setup-firefox`) finds the default profile
  automatically from `profiles.ini`
- `print.enabled` stays true (Cmd+P works); "Print..." context menu item
  is hidden via userChrome.css instead
- Firefox updates **wipe** `distribution/policies.json`; `just firefox_sync`
  re-deploys it. Always run sync after Firefox updates.
- Verify active policies at `about:policies` in Firefox
- `browser.ai.control.default = "blocked"` auto-blocks future AI features
  Firefox may add

## Drift detection

Run `just firefox_audit` to compare our defined prefs against live Firefox:
- Checks Firefox version matches this file
- Validates policies.json syntax and deployment
- For each pref in user.js, verifies Firefox has it with the expected value
- Reports value mismatches and prefs not yet applied (need Firefox restart)

**When to run**: after Firefox version updates, before planning Firefox
config work, or whenever you suspect drift.
