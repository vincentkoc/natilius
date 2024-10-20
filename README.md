# Natilius

Natilius is an automated script to speed up the development environment setup on a Mac machine. It scaffolds key development apps, settings, dotfiles, and configurations to have you up and running in no time.

## Features

- Modular scripts for different parts of the setup.
- Support for local defaults via a configuration file (`.natiliusrc`).
- One-liner installer for easy setup.
- Integration with Homebrew and other environment managers.

## Installation

Run the following command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/vincent_koc/natilius/main/install.sh | bash
```

## Configuration

After running the installer, you can customize your setup by editing the configuration file at `~/.natiliusrc`.

```bash
nano ~/.natiliusrc
```

You can enable or disable modules and set your preferred versions for various development environments.

## Modules

- **System Preferences**: Customize macOS system settings.
- **Security**: Apply security configurations.
- **Homebrew**: Install packages and casks.
- **Apps**: Install Mac App Store applications.
- **Development Environments**: Set up Java, Ruby, Python, Node.js, and Rust.
- **Dotfiles**: Restore dotfiles using Mackup.

## Feedback and Contributions

We welcome feedback, comments, and issues on GitHub at [https://github.com/vincent_koc/natilius](https://github.com/vincent_koc/natilius).

Pull requests and suggestions are encouraged to improve the setup of your development environment.

## License

This project is licensed under the GNU General Public License v3.0.
