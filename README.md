<div align="center">
  <h1>🐚 Natilius</h1>
  <p>
    <img src="assets/natilius_image.png" width="500">
  </p>
</div>

<div align="center">
  <p>
    <strong>Natilius</strong> is a fully automated one-click Mac developer<br/> and engineering environment bootstrapper ⚡
  </p>
</div>

<div align="center">
  <p>
    <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License">
    <img src="https://img.shields.io/badge/OS-macOS-blue.svg" alt="macOS">
    <img src="https://img.shields.io/badge/Version-1.0.0-green.svg" alt="Version">
  </p>
</div>

## What is Natilius?
It provides a streamlined process to set up a developer-ready environment on a vanilla Mac OS X install. Natilius takes care of various tasks, including:

- Creating default and project folders
- Configuring Mac OS preferences
- Installing Homebrew and Xcode toolkit
- Installing required packages and apps
- Setting up development environments for Python, Java (OpenJDK), Rust, Go, and NodeJS
- Syncing and installing dotfiles/preferences with [mackup](https://github.com/lra/mackup)
- Applying security enhancements based on previous work on [ostemper](https://github.com/koconder/ostemper)

## How to Run Natilius

To run Natilius, simply execute the following command in your terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/koconder/natilius/HEAD/natilius.sh)"

```

## Features

- Automatic Xcode and Homebrew setup
- Hardening and privacy-enhancing features
- Installing Brew packages, casks, and Mac apps automatically
- Setup and configure Python (pyenv), Ruby (rbenv), Java along with OpenJDK and extras like Maven, Gradle, Spark. Rust, Node.js (nodenv)
- Common developer Brew defaults like Helm, Kubernetes, Terraform, Go, R
- Mackup to manage/backup dotfiles and configuration on your Mac

## Story of Natilius

The idea for this project arose from the need to switch between multiple Mac OS devices as an engineer and data specialist. The final trigger was a switch after water damage. Natilius aims to simplify and expedite the process of setting up the development environment by taking care of all the small environmental aspects. It can be used in conjunction with [my mackup compatible dotfiles](https://github.com/koconder/dotfiles).

Natilius drew inspiration from the following Mac config/setup scripts:

- [bradp's gist](https://gist.github.com/bradp/bea76b16d3325f5c47d4)
- [vraravam's gist](https://gist.github.com/vraravam/5e28ca1720c9dddacdc0e6db61e093fe)
- [ptb's mac-setup](https://github.com/ptb/mac-setup/blob/develop/mac-setup.command)
- [nickytonline's gist](https://gist.github.com/nickytonline/729fc106a0146345c0b90f3356a41e4d#file-my-mac-setup-sh)
- [minamarkham's formation](https://github.com/minamarkham/formation)

## Contributions

Contributions are welcome! If you would like to contribute to natilius you can report bugs, suggest new features, or submit pull requests.

## License

Code is under the [GNU General Public License (GPL) v3 License](LICENSE.md).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
