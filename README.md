# Dotfiles (macOS)

My macOS dotfiles, for a personal Mac and a work Mac. They follow a
[modern Unix](https://github.com/ibraheemdev/modern-unix) workflow and the
[XDG](https://wiki.archlinux.org/title/XDG_user_directories) directory specification.

## How it works

- Every tool is declared once, in [`manifest.json`](manifest.json).
- Two profiles, `home` and `work`, choose what each Mac gets. `generated/<profile>/` is rendered from the manifest
  (`just manifest_render`) and is never edited by hand.
- `./install` is safe to re-run. Packages install one module at a time, and a package that fails never stops the rest:
  failures are listed at the end.
- `just doctor` is a read-only health report. Run it first on a new Mac.

| Profile difference      | home                   | work                     |
| ----------------------- | ---------------------- | ------------------------ |
| Personal apps and fonts | installed              | off                      |
| Office and Teams apps   | managed here           | external (already there) |
| Git commit signing      | on                     | off                      |
| gh as git credential    | on                     | off                      |
| Notes folder            | `~/Dropbox/notes`      | `~/notes`                |
| Dropbox                 | data only, set up last | not installed            |

The full comparison is in [`generated/compare.md`](generated/compare.md).

## Set up a personal Mac

```bash
git clone https://github.com/shamindras/dotfiles.git ~/repos/dotfiles
~/repos/dotfiles/bootstrap --profile home
```

Then open a new terminal, so the new shell and Homebrew are loaded, and finish:

1. `gh auth login --web`, then `~/repos/dotfiles/scripts/setup/setup-github-auth` (one SSH key for pushing and signing).
2. Sign in to Dropbox (notes, books and media only). Once it has synced, which can take hours the first time, run
   `just dropbox_finish` in `~/repos/dotfiles`.

## Set up a work Mac

```bash
git clone https://github.com/shamindras/dotfiles.git ~/repos/dotfiles   # HTTPS, no SSH key needed
~/repos/dotfiles/scripts/ops/doctor                    # what the Mac already has
~/repos/dotfiles/bootstrap --profile work --dry-run    # print the plan, change nothing
~/repos/dotfiles/bootstrap --profile work
```

Optionally, to push from this Mac, open a new terminal and run `gh auth login --web`, then
`~/repos/dotfiles/scripts/setup/setup-github-auth --email <work email>`.

## Day to day

```bash
./install          # re-run any time; reads the profile from ~/.config/dotfiles
bu                 # brew-update: upgrade, then report drift from the manifest
just test          # static checks and sandbox tests (never touch the real HOME)
just update-all    # move pinned versions; a weekly CI job does this as a PR
```

`./install` and `./bootstrap` also take `--links-only`, `--dry-run` and `--no-hints`.

## Go deeper

- [`CLAUDE.md`](CLAUDE.md): layout, conventions and every `just` recipe.
- [`docs/decisions/`](docs/decisions/README.md): why things are the way they are.
- [`docs/plan/`](docs/plan/README.md): how the overhaul was planned and verified.

## Credits

Thanks to everyone who openly shares their work.

<details>
<summary>Dotfiles that inspired these</summary>
<br>

- [Alicia Sykes' dotfiles](https://github.com/Lissy93/dotfiles)
- [Mattmc3's zshrc1 config](https://github.com/mattmc3/zshrc1/tree/main)
- [Josh Medeski's dotfiles](https://github.com/joshmedeski/dotfiles/tree/15576d333a884b4fb867a24f121162e4f4293a86)
- [Josean Martinez's dotfiles](https://github.com/josean-dev/dev-environment-files) and his
  [YouTube videos](https://www.youtube.com/watch?v=U-omALWIBos)
- [Shivan's zk config](https://github.com/shivan-s/dotfiles/tree/main/zk)
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles/blob/master/.macos), in particular
  [his macOS defaults](https://mths.be/macos)
- [Kevin Suttle's](https://github.com/kevinSuttle) [macOS-Defaults](https://github.com/kevinSuttle/macOS-Defaults),
  which documents the settings in Mathias Bynens' [`.macos`](https://mths.be/macos)
- [Dylan McDowell's zsh config](https://github.com/dylanjm/teton/blob/2eb03539fe2c9489ed6b5ade4ee4ee44d8c6f421/config/shells/zsh/zshenv.zsh)
- [Linkarzu's Neovim markdown setup](https://linkarzu.com/posts/neovim/markdown-setup-2025/) and his
  [dotfiles](https://github.com/linkarzu/dotfiles-latest/tree/main/neovim/neobean)

</details>

<details>
<summary>Tools these are built on</summary>
<br>

- [dotbot](https://github.com/anishathalye/dotbot), which links every config
- [Homebrew](https://brew.sh/), which installs every package

</details>
