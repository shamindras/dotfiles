# Emoji Prefix Mapping

When `--emoji` is active, prefix the commit description with the type's emoji.

Format: `<type>(<scope>): <emoji> <description>`

## Mapping

| Type       | Emoji | Example                                      |
|------------|-------|----------------------------------------------|
| `feat`     | ✨    | `feat(nvim): ✨ add telescope fuzzy finder`   |
| `fix`      | 🐛    | `fix(tmux): 🐛 correct session handling`      |
| `refactor` | ♻️     | `refactor(zsh): ♻️ extract helper functions`   |
| `docs`     | 📝    | `docs(claude): 📝 update skill reference`     |
| `chore`    | 📦    | `chore(brew): 📦 update brewfile`              |
| `test`     | ✅    | `test(nvim): ✅ add plugin tests`              |
| `style`    | 🎨    | `style(lua): 🎨 reformat with stylua`         |
| `ci`       | 👷    | `ci(github): 👷 add lint workflow`             |

## Rules

- Insert emoji after `<scope>): ` and before the lowercase description
- 72-char subject limit still applies (emoji counts as ~2 chars)
- If subject exceeds limit, shorten description — never drop the emoji
- Unknown type: omit emoji, warn
- Multi-commit splits: each commit gets its own type's emoji
- PR titles inherit emoji when combined with `--land`

## Step override

- **Step 6**: Apply mapping to draft the commit subject as
  `<type>(<scope>): <emoji> <description>`
