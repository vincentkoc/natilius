# 🐚 Natilius

<img src='assets/natilius_image.png' width='500'>

**Natilius** is a fully automated one-click mac developer and engineering environment bootstrapper ⚡.

It can take vanilla Mac OS X install and have it developer ready in one go, setting up:

* Create any default/project folders
* Configure various Mac OS preferences
* Install homebrew and xcode toolkit
* Install various packages and apps required
* Stand-up development enviroments (Python, Java, Go, NodeJS)
* Sync and install dotfiles/preferences with [mackup](https://github.com/lra/mackup)
* Secure your mac _(based on my earlier work on [ostemper](https://github.com/koconder/ostemper))_

## How to Run Natilius

Run the following command in your terminal:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/koconder/natilius/HEAD/natilius.sh)"
```

## Story of Natilius

This project was born after switching between many mac OS devices as an engineer and data specalist, the last switch was after water damage. This project aims to assist in the use of quickly having all the small enviromental ascepts taken-care of. This project is used in conjunction with [my mackup compatible dotfiles](https://github.com/koconder/dotfiles).

I have taken inspiration from the following other Mac config/setup scripts for Natilius:
* https://gist.github.com/bradp/bea76b16d3325f5c47d4
* https://gist.github.com/vraravam/5e28ca1720c9dddacdc0e6db61e093fe
* https://github.com/ptb/mac-setup/blob/develop/mac-setup.command
* https://gist.github.com/nickytonline/729fc106a0146345c0b90f3356a41e4d#file-my-mac-setup-sh
* https://github.com/minamarkham/formation

## License

Code is under the [GNU General Public License (GPL) v3 License](LICENSE.md).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
