# Natilius 🐚

<p align="center">
  <img src="assets/natilius_image.png" alt="Natilius Logo" width="200"/>
</p>

<p align="center">
  <strong>Automated One-Click Mac Developer Environment Setup</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#usage">Usage</a> •
  <a href="#customization">Customization</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/vincentkoc/natilius" alt="License">
  <img src="https://img.shields.io/github/stars/vincentkoc/natilius" alt="Stars">
  <img src="https://img.shields.io/github/forks/vincentkoc/natilius" alt="Forks">
  <img src="https://img.shields.io/github/issues/vincentkoc/natilius" alt="Issues">
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

## Installation

To install Natilius, follow these steps:

1. Open Terminal on your Mac.
2. Run the following command to download and install Natilius:

   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
   ```

3. Follow the on-screen prompts to complete the installation.

## Quick Start

After installing Natilius, you can quickly set up your Mac development environment:

### Basic Setup
```bash
# Run the full setup
natilius setup

# Or run interactively to choose modules
natilius --interactive setup
```

### Check Before Installing
```bash
# See what would be installed without making changes
natilius --check

# Run system diagnostics
natilius doctor

# List all available modules
natilius list-modules
```

## Usage

Natilius provides a comprehensive CLI interface with multiple commands and options:

### Commands

```bash
natilius setup           # Run the full setup process (default)
natilius doctor          # Run system diagnostics and health checks
natilius list-modules    # List all available modules
natilius version         # Show version information
natilius help            # Show help message
```

### Options

```bash
-v, --verbose       # Enable verbose output
-q, --quiet         # Suppress non-error output
-i, --interactive   # Run in interactive mode
-c, --check         # Run in check/dry-run mode (no changes)
-p, --profile NAME  # Use a specific configuration profile
--dry-run           # Same as --check
-h, --help          # Show help message
```

### Examples

```bash
# Basic usage
natilius                    # Run default setup
natilius --check            # Dry run to see what would be done
natilius doctor             # Run system diagnostics
natilius list-modules       # Show available modules

# Advanced usage
natilius -v setup           # Run setup with verbose output
natilius -i setup           # Run setup in interactive mode
natilius -p work setup      # Use 'work' profile configuration
natilius --quiet setup      # Run setup with minimal output
```

### System Diagnostics

The `doctor` command provides comprehensive system analysis:

- ✅ System information (macOS version, architecture)
- ✅ Development tools verification (Xcode, Homebrew, Git)
- ✅ Configuration validation
- ✅ Disk space monitoring
- ✅ Network connectivity testing
- ✅ Security settings analysis
- ✅ Apple Silicon compatibility (Rosetta 2)

### Shell Completions

Natilius includes shell completions for enhanced productivity:

```bash
# Bash
source completions/natilius-completion.bash

# Zsh
source completions/natilius-completion.zsh
```

For more detailed usage instructions, run `natilius help`.

## Development

### Prerequisites

- macOS (for full testing)
- Homebrew (recommended)
- Git

### Quick Development Setup

```bash
# Clone and setup
git clone https://github.com/vincentkoc/natilius.git
cd natilius
make dev-setup
```

### Development Commands

```bash
make help           # Show all available commands
make test           # Run unit tests
make test-all       # Run all tests
make lint           # Run shellcheck linting
make precommit      # Run pre-commit hooks
make coverage       # Generate coverage report
make check-version  # Check version consistency
make release-check  # Check if ready for release
```

### VS Code Development

Natilius includes a complete VS Code devcontainer setup:

1. Open the repository in VS Code
2. Click "Reopen in Container" when prompted
3. Everything will be automatically configured!

### Testing

Natilius uses BATS (Bash Automated Testing System) for testing:

```bash
# Run specific test suites
make test              # Unit tests
make integration-test  # Integration tests
make test-config       # Configuration tests

# Coverage analysis
make coverage
```

## Contributing

We welcome contributions! Whether it's bug reports, feature requests, or code contributions, please feel free to contribute.

### Development Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test-all`
5. Run linting: `make lint`
6. Submit a pull request

See our [Contributing Guide](CONTRIBUTING.md) for more details.

## License

Natilius is open-source software licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

Natilius stands on the shoulders of giants. We'd like to thank:

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- And all the amazing open-source projects that make Natilius possible.

## Support

If you find Natilius useful, please consider starring the repository on GitHub. It helps others discover the project and motivates further development.

For issues, feature requests, or questions, please use the [GitHub Issues](https://github.com/vincentkoc/natilius/issues) page.

## Roadmap

- [ ] Add support for more development environments and applications
- [ ] Implement a GUI for easier customization
- [ ] Create a web-based configuration generator
- [ ] Add support for Linux distributions

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/vincentkoc">Vincent Koc</a>
</p>
