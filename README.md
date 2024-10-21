# Natilius 🐚

<p align="center">
  <img src="assets/natilius_image.png" alt="Natilius Logo" width="200"/>
</p>

<p align="center">
  <strong>Automated One-Click Mac Developer Environment Setup</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#customization">Customization</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/vincent_koc/natilius" alt="License">
  <img src="https://img.shields.io/github/stars/vincent_koc/natilius" alt="Stars">
  <img src="https://img.shields.io/github/forks/vincent_koc/natilius" alt="Forks">
  <img src="https://img.shields.io/github/issues/vincent_koc/natilius" alt="Issues">
</p>

Natilius is a powerful, customizable, and easy-to-use tool that automates the setup of a complete Mac development environment. With just one click, it installs and configures essential developer tools, applications, and settings, saving you hours of manual setup time.

## Features

- 🚀 **One-Click Setup**: Get your Mac ready for development in minutes, not hours.
- 🛠 **Customizable**: Easily tailor the setup to your specific needs.
- 📦 **Comprehensive**: Installs and configures a wide range of development tools and applications.
- 🔒 **Secure**: Implements best practices for macOS security settings.
- 🔄 **Idempotent**: Safely run multiple times without side effects.
- 📊 **Modular**: Easily extend or modify functionality.

## Customization

Natilius is highly customizable. Edit the `.natiliusrc` file in your home directory to tailor the installation to your needs. You can:

- Choose which development environments to set up (e.g., Python, Node.js, Ruby)
- Select which applications to install
- Configure macOS preferences
- And much more!

## What Gets Installed?

Natilius can set up a complete development environment, including:

- Xcode Command Line Tools
- Homebrew and essential formulae
- Programming languages and version managers (e.g., Python, Node.js, Ruby)
- Developer tools (e.g., Git, Docker, Visual Studio Code)
- Productivity apps (e.g., Alfred, iTerm2)
- And much more!

Check the [full list of installed software](docs/installed-software.md) for details.

## Why Natilius?

- **Time-saving**: Set up your development environment in minutes, not hours or days.
- **Consistency**: Ensure all your Macs have the same setup, great for teams.
- **Best Practices**: Implements security and performance best practices out of the box.
- **Customizable**: Easily adapt to your specific needs and preferences.
- **Open Source**: Benefit from community contributions and transparency.

## How It Works

Natilius uses a modular approach to set up your Mac:

1. **System Update**: Ensures your Mac is up-to-date and installs necessary components like Xcode CLI tools.
2. **Security**: Implements best-practice security settings for macOS.
3. **Homebrew**: Installs Homebrew and manages package installations.
4. **Development Environments**: Sets up various language environments (Python, Node.js, Ruby, etc.).
5. **Applications**: Installs and configures both CLI and GUI applications.
6. **macOS Preferences**: Configures macOS settings for optimal development experience.

Each step is customizable and can be enabled or disabled as needed.

## Contributing

We welcome contributions! Whether it's bug reports, feature requests, or code contributions, please feel free to contribute. See our [Contributing Guide](CONTRIBUTING.md) for more details on how to get started.

## License

Natilius is open-source software licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

Natilius stands on the shoulders of giants. We'd like to thank:

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- And all the amazing open-source projects that make Natilius possible.

## Support

If you find Natilius useful, please consider starring the repository on GitHub. It helps others discover the project and motivates further development.

For issues, feature requests, or questions, please use the [GitHub Issues](https://github.com/vincent_koc/natilius/issues) page.

## Roadmap

- [ ] Add support for more development environments
- [ ] Implement a GUI for easier customization
- [ ] Create a web-based configuration generator
- [ ] Add support for Linux distributions

Check our [project board](https://github.com/vincent_koc/natilius/projects) for more details on upcoming features and enhancements.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/vincent_koc">Vincent Koc</a>
</p>
