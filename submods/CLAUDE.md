# Submodules

Git submodules used by this dotfiles repo.

## Docs

- [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## Directory structure

`submods/<category>/<name>/`

### Current categories

| Category   | Purpose                         | Contents                  |
| ---------- | ------------------------------- | ------------------------- |
| `core/`    | Dotbot installer + plugins      | dotbot, dotbot-brew       |
| `plugins/` | Runtime plugins loaded by tools | tpm (tmux plugin manager) |

### Future categories (create on-demand)

| Category    | Purpose                     | Nesting convention         |
| ----------- | --------------------------- | -------------------------- |
| `themes/`   | Upstream color scheme repos | `themes/<palette>/<tool>/` |
| `examples/` | Reference dotfiles repos    | `examples/<author>/`       |

Theme submodules use **palette-first** nesting. Example:
- `themes/catppuccin/bat/` (catppuccin/bat repo)
- `themes/dracula/newsboat/` (dracula/newsboat repo)

## Submodule operations

### Adding a submodule

```bash
git submodule add <url> submods/<category>/<name>
```

### Removing a submodule

```bash
git submodule deinit -f submods/<category>/<name>
git rm -f submods/<category>/<name>
rm -rf .git/modules/submods/<category>/<name>
```
