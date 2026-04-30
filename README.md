# Dotfiles (macOS)

- [Dotfiles (macOS)](#dotfiles-macos)
  - [Personal dotfiles - philosophy](#personal-dotfiles---philosophy)
  - [Commands](#commands)
  - [Fresh macOS setup](#fresh-macos-setup)
  - [Day-to-day refresh](#day-to-day-refresh)
  - [Inspiration](#inspiration)

## Personal dotfiles - philosophy

**Warning:** _these dotfiles are currently a work in progress (not yet complete). Feel free to take Inspiration from
them, but best not to use them as is._

This is a repo of my personal dotfiles for `macOS`. The main philosophy is to use

- A [modern Unix](https://github.com/ibraheemdev/modern-unix) workflow.
- The [`XDG`](https://wiki.archlinux.org/title/XDG_user_directories) directory specification.

## Commands

There are two commands. Both are idempotent; pick by where you are.

| Command       | Use it when                                                                  | What it does                                                                                                                                                                  |
| ------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `./bootstrap` | Fresh Mac, OR not sure of state.                                             | Installs Homebrew + Dropbox cask, opens Dropbox, waits for sign-in (one human pause), waits for the dotfiles repo to sync, then `exec`s `./install` from the synced location. |
| `./install`   | You're already in `~/Dropbox/repos/dotfiles` and just want a dotbot refresh. | Runs [`dotbot`](https://github.com/anishathalye/dotbot): symlinks, Brewfile, npm, macOS defaults.                                                                             |

Flags (both commands accept):

- `--no-hints` — suppress post-install reminders.

Make aliases (no behavioral difference): `make bootstrap`, `make dotbot_install`.

`./bootstrap` re-runs are cheap because every phase has a skip-check (Homebrew installed? Dropbox cask installed? app
running? signed in? repo synced?). On an already-configured machine it will fast-forward through all five detection
phases and hand off to `./install`. Ctrl-C is safe at any time; the next invocation resumes at the unfinished phase.

## Fresh macOS setup

```bash
git clone --recurse-submodules --remote-submodules \
  git@github.com:shamindras/dotfiles.git ~/dotfiles-bootstrap
cd ~/dotfiles-bootstrap
./bootstrap
```

You'll be asked to sign in to Dropbox once, in the GUI window the script opens. After sign-in detection, `./bootstrap`
waits for `~/Dropbox/repos/dotfiles` to sync, then runs `./install` from there. The temp clone at `~/dotfiles-bootstrap`
is no longer needed afterward and can be removed.

## Day-to-day refresh

From the synced repo:

```bash
cd ~/Dropbox/repos/dotfiles
./install              # or: make dotbot_install
```

`./install` applies macOS system defaults (`scripts/setup/setup-macos`), which needs `sudo` and may require a
logout/reboot for some changes to take effect.

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
