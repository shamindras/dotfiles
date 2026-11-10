# Decisions

The knowledge graph for the profile-driven bootstrap: one fact per file. Notes are append-only. To change one, add a new
note whose `supersedes` names the old file; never edit an accepted note. `scripts/test/check-docs` lints the front
matter and links, and `scripts/test/check-invariants` runs each invariant's `verify` command.

| Note                                                                | Type      | Title                                          |
| ------------------------------------------------------------------- | --------- | ---------------------------------------------- |
| [adr-01-repos-dir](adr-01-repos-dir.md)                             | adr       | Repos live in ~/repos                          |
| [adr-02-repos-dir-var](adr-02-repos-dir-var.md)                     | adr       | REPOS_DIR replaces DROPBOX_REPOS_DIR           |
| [adr-03-no-git-in-dropbox](adr-03-no-git-in-dropbox.md)             | adr       | No git repos in Dropbox                        |
| [adr-04-engine](adr-04-engine.md)                                   | adr       | Homebrew, dotbot, manifest                     |
| [adr-05-work-modules](adr-05-work-modules.md)                       | adr       | Work modules on day one                        |
| [adr-06-git-identity](adr-06-git-identity.md)                       | adr       | Git identity is untracked                      |
| [adr-07-home-github-auth](adr-07-home-github-auth.md)               | adr       | Home GitHub auth: fresh key per Mac            |
| [adr-08-work-github-auth](adr-08-work-github-auth.md)               | adr       | Work GitHub auth: HTTPS pull-only first        |
| [adr-09-no-brewfile-dump](adr-09-no-brewfile-dump.md)               | adr       | No Brewfile auto-dump                          |
| [adr-10-notes-at-work](adr-10-notes-at-work.md)                     | adr       | Notes at work in ~/notes                       |
| [adr-11-macos-settings](adr-11-macos-settings.md)                   | adr       | macOS settings per profile                     |
| [adr-12-testing](adr-12-testing.md)                                 | adr       | Testing in three layers, no VM                 |
| [adr-13-dead-weight](adr-13-dead-weight.md)                         | adr       | Delete the dead weight                         |
| [adr-14-decision-memory](adr-14-decision-memory.md)                 | adr       | Decisions live in docs/decisions               |
| [adr-15-keeping-fresh](adr-15-keeping-fresh.md)                     | adr       | Weekly update PR and mise scoreboard           |
| [inv-bootstrap-no-dropbox](inv-bootstrap-no-dropbox.md)             | invariant | Bootstrap needs no Dropbox                     |
| [inv-bootstrap-no-ssh-key](inv-bootstrap-no-ssh-key.md)             | invariant | Bootstrap needs no SSH key                     |
| [inv-generated-matches-manifest](inv-generated-matches-manifest.md) | invariant | Generated files match the manifest             |
| [inv-home-parity](inv-home-parity.md)                               | invariant | Rendered home equals today's install           |
| [inv-no-link-into-cloudstorage](inv-no-link-into-cloudstorage.md)   | invariant | No link resolves into CloudStorage             |
| [inv-no-profile-branches](inv-no-profile-branches.md)               | invariant | No file branches on the profile name           |
| [inv-off-unit-leaves-nothing-2](inv-off-unit-leaves-nothing-2.md)   | invariant | An off unit leaves nothing behind              |
| [inv-off-unit-leaves-nothing](inv-off-unit-leaves-nothing.md)       | invariant | An off unit leaves nothing behind (superseded) |
| [pattern-ratchet-loop](pattern-ratchet-loop.md)                     | pattern   | Ratchet loop per node                          |
| [pattern-values-not-branches](pattern-values-not-branches.md)       | pattern   | Values, not branches                           |
| [vocab-expected-fail](vocab-expected-fail.md)                       | vocab     | Expected failure (XFAIL)                       |
