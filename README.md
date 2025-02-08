# Dotfiles (macOS)

- [Dotfiles (macOS)](#dotfiles-macos)
  - [Personal dotfiles - philosophy](#personal-dotfiles---philosophy)
  - [Installation](#installation)
    - [Clone the repo and update and sync submodules](#clone-the-repo-and-update-and-sync-submodules)
    - [Run installation using `dotbot`](#run-installation-using-dotbot)
  - [Inspiration](#inspiration)

## Personal dotfiles - philosophy

**Warning:** _these dotfiles are currently a work in progress (not yet complete).
Feel free to take Inspiration from them, but best not to use them as is._

This is a repo of my personal dotfiles for `macOS`. The main philosophy is to
use

- A [modern Unix](https://github.com/ibraheemdev/modern-unix) workflow.
- The [`XDG`](https://wiki.archlinux.org/title/XDG_user_directories) directory specification.

## Installation

### Clone the repo and update and sync submodules

In order to install these dotfiles, run the following commands:

```bash
git clone --recurse-submodules --remote-submodules git@github.com:shamindras/dotfiles.git
```

### Run installation using `dotbot`

Now the installation script can be executed using
[`dotbot`](https://github.com/anishathalye/dotbot) as follows:

```bash
make dotbot_install
```

**NOTE:** The above `make dotbot_install` command is just a wrapper for
`./install`, if you prefer to run this command directly from your terminal.

## Inspiration

These dotfiles have been mainly inspired by the following people. I thank them
for openly sharing their work.

<details>
<summary>Dotfile Sources</summary>
<br>

- [Alicia Sykes' dotfiles](https://github.com/Lissy93/dotfiles).
- [Mattmc3's zshrc1 config](https://github.com/mattmc3/zshrc1/tree/main).
- [Josh Medeski's dotfiles](https://github.com/joshmedeski/dotfiles/tree/15576d333a884b4fb867a24f121162e4f4293a86).
- [Josean Martinez's dotfiles](https://github.com/joshmedeski/dotfiles/tree/15576d333a884b4fb867a24f121162e4f4293a86)
  and accompanying [YouTube videos](https://www.youtube.com/watch?v=U-omALWIBos&ab_channel=JoseanMartinez).
- [Mathias Bynen's dotfiles](https://github.com/mathiasbynens/dotfiles/blob/master/.macos)
  and in particular [his macOS dotfiles](https://mths.be/macos).
- [Kevin Suttle](http://kevinsuttle.com/) and his [macOS-Defaults project](https://github.com/kevinSuttle/macOS-Defaults),
  which aims to provide better documentation for [`~/.macos`](https://mths.be/macos). This is inspired by Mathias Bynen's `.macos` settings.
- [Dylan McDowell's zsh config](https://github.com/dylanjm/teton/blob/2eb03539fe2c9489ed6b5ade4ee4ee44d8c6f421/config/shells/zsh/zshenv.zsh)

</details>
