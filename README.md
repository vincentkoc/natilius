# natilius

![natilius ontop of a laptop](assets/natilius_image.png)

**natilius** (🐚) is an automated one-click mac developer enviroment script.

This script is designed to setup a mac from a fresh OS X install:

* Setup any default folders
* Install xcode toolkit required to install various things
* Install homebrew
* Install various packages and apps required
* Configure development enviroment (Python, Java, Go, NodeJS)
* Setup various Mac OS preferences
* Sync and install dotfiles with [mackup](https://github.com/lra/mackup)


## Install

Run the following command in your terminal:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/koconder/natilius/HEAD/natilius.sh)"
```

## Story of natilius

This project was born after switching between many mac OS devices as an engineer and data specalist. This project aims to assist in the use of quickly having all the small enviromental ascepts taken-care of. This project is used in conjunction with [my mackup compatible dotfiles](https://github.com/koconder/dotfiles).

## License

Code is under the [GNU General Public License (GPL) v3 License](LICENSE.md).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
