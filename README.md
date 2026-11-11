# Dotfiles (macOS)

- [Dotfiles (macOS)](#dotfiles-macos)
  - [Personal dotfiles - philosophy](#personal-dotfiles---philosophy)
  - [Commands](#commands)
  - [Fresh macOS setup](#fresh-macos-setup)
  - [Day-to-day](#day-to-day)
  - [Inspiration](#inspiration)

## Personal dotfiles - philosophy

**Warning:** _these dotfiles are currently a work in progress (not yet complete). Feel free to take Inspiration from
them, but best not to use them as is._

This is a repo of my personal dotfiles for `macOS`. The main philosophy is to use

- A [modern Unix](https://github.com/ibraheemdev/modern-unix) workflow.
- The [`XDG`](https://wiki.archlinux.org/title/XDG_user_directories) directory specification.

## Commands

| Command                     | Use it when                       | What it does                                                                                                                              |
| --------------------------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `./bootstrap --profile <p>` | Fresh Mac (any clone path).       | Installs Homebrew if missing, loads it into the same run, then runs `./install`. Needs no SSH key and no Dropbox.                         |
| `./install`                 | Re-run on a Mac already set up.   | Links configs, installs packages one module at a time, runs setup steps. Reads the profile from `~/.config/dotfiles` after the first run. |
| `just doctor`               | Before anything, or when in doubt | Read-only health report, using only what macOS ships. Ends with a block to paste into a conversation.                                     |

Profiles are `home` and `work`. Flags: `--links-only` (links only), `--dry-run` (change nothing, print the plan),
`--no-hints`.

Everything installed is declared once in [`manifest.json`](manifest.json). `just manifest_render` turns it into
`generated/<profile>/` (Brewfile, dotbot config, the app registry Hammerspoon reads, shell values, sesh config), and
[`generated/compare.md`](generated/compare.md) shows how home and work differ. A package that fails to install never
stops the rest: failures are listed at the end.

## Fresh macOS setup

```bash
git clone https://github.com/shamindras/dotfiles.git ~/repos/dotfiles
~/repos/dotfiles/scripts/ops/doctor            # optional: see what the Mac has first
~/repos/dotfiles/bootstrap --profile home      # or --profile work
```

At home, Dropbox (notes, books, media only) is installed and opened at the very end; nothing waits for it. After signing
in, and once it has synced (a first sync can take hours), run `just dropbox_finish`.

## Day-to-day

```bash
cd ~/repos/dotfiles
./install                 # links, packages, setup steps (macOS defaults need sudo)
just test                 # static checks and sandbox tests (never touch the real HOME)
just update-all           # move the pinned versions; a weekly CI job does this as a PR
```

Daily Homebrew upgrades run through `brew-update` (`bu`, or the leader `r → b`), which reports packages installed or
removed by hand instead of rewriting any file.

How the overhaul was planned and run (a graph of nodes, each closed by a verify loop) is in
[`docs/plan/`](docs/plan/README.md); decisions live in [`docs/decisions/`](docs/decisions/README.md).

## Inspiration

These dotfiles have been mainly inspired by the following people. I thank them for openly sharing their work.

<details>
<summary>Dotfile Sources</summary>
<br>

- [Alicia Sykes' dotfiles](https://github.com/Lissy93/dotfiles).
- [Mattmc3's zshrc1 config](https://github.com/mattmc3/zshrc1/tree/main).
- [Josh Medeski's dotfiles](https://github.com/joshmedeski/dotfiles/tree/15576d333a884b4fb867a24f121162e4f4293a86).
- [Josean Martinez's dotfiles](https://github.com/joshmedeski/dotfiles/tree/15576d333a884b4fb867a24f121162e4f4293a86)
  and accompanying [YouTube videos](https://www.youtube.com/watch?v=U-omALWIBos&ab_channel=JoseanMartinez).
- [Shivan's zk config](https://github.com/shivan-s/dotfiles/tree/main/zk)
- [Mathias Bynen's dotfiles](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and in particular
  [his macOS dotfiles](https://mths.be/macos).
- [Kevin Suttle](http://kevinsuttle.com/) and his
  [macOS-Defaults project](https://github.com/kevinSuttle/macOS-Defaults), which aims to provide better documentation
  for [`~/.macos`](https://mths.be/macos). This is inspired by Mathias Bynen's `.macos` settings.
- [Dylan McDowell's zsh config](https://github.com/dylanjm/teton/blob/2eb03539fe2c9489ed6b5ade4ee4ee44d8c6f421/config/shells/zsh/zshenv.zsh)
- [Linkarzu's neovim markdown setup](https://linkarzu.com/posts/neovim/markdown-setup-2025/) and his
  [dotfiles](https://github.com/linkarzu/dotfiles-latest/tree/main/neovim/neobean).

</details>
