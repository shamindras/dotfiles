---
description: "Promote an ad-hoc sesh directory to a permanent [[session]] in sesh.toml with its own startup script. Args: [<dir-or-name>] [--help]"
---

Follow these steps to promote a directory from the ad-hoc tier
(`config/sesh/dirs.list`) to a permanent `[[session]]` entry in
`config/sesh/sesh.toml` with a dedicated startup script. Promoted sessions
automatically join `sesh-reset --all` (its list is derived from sesh.toml).

## 1. Parse arguments

Scan `$ARGUMENTS`:

- `--help` — show this workflow summary (steps 2-8) and **stop**.
- `<dir-or-name>` — a directory path (absolute, `~/...`, or
  `${DROPBOX_DIR}/...`) or a bare name to match against dirs.list entries
  and their basenames.
- No arguments — list candidate directories (step 2) and ask the user to
  pick one.

## 2. Resolve the target directory

1. Read `config/sesh/dirs.list`; expand env-var literals
   (`${DROPBOX_DIR:-$HOME/Dropbox}`, `${HOME}`).
2. If an argument was given, resolve it against exact entries, root-glob
   children, and basenames. Ambiguous → present matches, ask.
3. Verify the directory exists and is NOT already a `[[session]]` path in
   `sesh.toml` (compare with `~/Dropbox` ↔ `~/Library/CloudStorage/Dropbox`
   prefix normalization). Already promoted → report and stop.

## 3. Survey the session design

Ask the user (one question at a time, checkbox format):

1. **Session name** — default: directory basename (sesh sanitizes `.`/`:`
   to `_`; flag if sanitization would apply).
2. **Layout** — default: the standard `default.sh` layout (claude / yazi /
   nvim / term, focus claude). Offer per-window customization: which
   windows, order, focus, and any session-specific windows (see
   `config/sesh/scripts/notes.sh`, `blog.sh` for inline-window patterns).

## 4. Generate the startup script

1. Create `config/sesh/scripts/<name>.sh` seeded from
   `config/sesh/scripts/default.sh`, but with hardcoded
   `SESSION="<name>"` and `WORK_DIR="..."` (use `${DROPBOX_DIR:-$HOME/Dropbox}`
   prefix where applicable) — match the style of the six existing scripts.
2. Apply any customizations from step 3 using `helpers.sh` functions;
   session-specific windows go inline after the shared calls.
3. `chmod +x` the script; `bash -n` it.

## 5. Register in sesh.toml

Append a `[[session]]` block (BEFORE the `[default_session]` table — TOML
array-of-tables entries must not follow it, or they'd nest incorrectly):

```toml
[[session]]
name = "<name>"
path = "<~/-form path>"
startup_command = "~/.config/sesh/scripts/<name>.sh"
```

## 6. Clean up dirs.list

Remove the directory's exact entry from `config/sesh/dirs.list` if present
(root-glob children need no removal — the picker auto-excludes sesh.toml
paths).

## 7. Update docs

- `config/sesh/CLAUDE.md`: add a row to the "Window Layout by Session"
  table; update the session count anywhere it appears.
- Note: `sesh-reset --all` and the sesh picker pick up the new session
  automatically — no other config changes.

## 8. Validate

1. `sesh list -c --json | jq .` — parses; new session present with correct
   Name/Path/StartupCommand.
2. `bash -n config/sesh/scripts/<name>.sh`.
3. Tell the user: run `sesh connect <name>` (or `sesh-reset <name>` if a
   live ad-hoc session with that name exists — the old session must be
   killed to pick up the new layout).

## Important

- Never modify the six original sessions or `default.sh`.
- Follow the Branch-First Rule (root CLAUDE.md) — this is multi-file work;
  commit via `/commit` with scope `sesh`.
