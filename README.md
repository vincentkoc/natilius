<p align="center">
  <img src="assets/natilius_image.png" alt="Natilius" width="180"/>
</p>

<h1 align="center">Natilius</h1>

<p align="center">
  <strong>Set up your Mac for development in minutes, not hours.</strong>
</p>

<p align="center">
  <a href="https://github.com/vincentkoc/natilius/actions/workflows/ci.yml"><img src="https://github.com/vincentkoc/natilius/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/vincentkoc/natilius/releases"><img src="https://img.shields.io/github/v/release/vincentkoc/natilius?include_prereleases" alt="Release"></a>
  <a href="https://github.com/vincentkoc/natilius/blob/main/LICENSE"><img src="https://img.shields.io/github/license/vincentkoc/natilius" alt="License"></a>
  <a href="https://github.com/vincentkoc/natilius/stargazers"><img src="https://img.shields.io/github/stars/vincentkoc/natilius" alt="Stars"></a>
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-features">Features</a> •
  <a href="#-installation">Installation</a> •
  <a href="#%EF%B8%8F-configuration">Configuration</a> •
  <a href="#-profiles">Profiles</a> •
  <a href="docs/README.md">Documentation</a>
</p>

---

## Why Natilius?

Setting up a new Mac for development is tedious. Installing Homebrew, configuring languages, setting up IDEs, tweaking system preferences—it takes hours of clicking and typing.

**Natilius automates all of it.**

```bash
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | bash
natilius setup
```

That's it. Go grab a coffee while Natilius sets up your entire development environment.

---

## Quick Start

### One-Line Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
```

### Or via Homebrew

```bash
brew install vincentkoc/tap/natilius
```

### Then Run

```bash
natilius doctor    # Check your system
natilius --check   # Preview what will be installed
natilius setup     # Install everything
```

---

## Features

| Feature | Description |
|---------|-------------|
| **One Command Setup** | Install 100+ tools, apps, and configurations with a single command |
| **Modular Design** | Enable only what you need—skip what you don't |
| **Role-Based Profiles** | Pre-configured setups for DevOps, Frontend, Backend, or minimal installs |
| **Idempotent** | Run it multiple times safely—it only installs what's missing |
| **Terraform Ready** | Built for automation—works with Terraform, Ansible, and CI/CD |
| **macOS Hardened** | Configures FileVault, Firewall, Gatekeeper, and privacy settings |

### What Gets Installed

<details>
<summary><strong>Development Environments</strong></summary>

- **Python** — pyenv, pipenv, virtualenv, popular packages
- **Node.js** — nodenv, npm, yarn, pnpm
- **Ruby** — rbenv, bundler
- **Go** — goenv, popular tools
- **Rust** — rustup, cargo
- **Java** — jenv, Temurin JDK, Maven, Gradle
- **PHP** — Composer, Laravel installer

</details>

<details>
<summary><strong>DevOps & Cloud</strong></summary>

- **Containers** — Docker, docker-compose, ctop
- **Kubernetes** — kubectl, kubectx, helm, k9s, minikube, lens
- **Infrastructure** — Terraform, tflint, tfsec, Ansible
- **Cloud CLIs** — AWS CLI, Azure CLI

</details>

<details>
<summary><strong>Developer Tools</strong></summary>

- **Editors** — VS Code, Cursor, JetBrains IDEs, Sublime Text, Zed
- **Terminal** — iTerm2, tmux, zsh completions
- **Git** — git, gh CLI, git-lfs, tig, diff-so-fancy
- **Utilities** — jq, fzf, ripgrep, bat, eza, htop

</details>

<details>
<summary><strong>Applications</strong></summary>

- **Productivity** — Alfred, 1Password, Notion, Obsidian
- **Communication** — Slack, Zoom
- **Browsers** — Firefox, Brave
- **And 50+ more...**

</details>

---

## Installation

### Option 1: Homebrew (Recommended)

```bash
brew install vincentkoc/tap/natilius
```

### Option 2: Installer Script

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
```

This installs:
- Natilius to `~/.natilius`
- `natilius` command to your PATH
- Shell completions (bash/zsh)
- Default config at `~/.natiliusrc`

### Option 3: Manual

```bash
git clone https://github.com/vincentkoc/natilius.git ~/.natilius
cd ~/.natilius && ./install.sh
```

### Uninstall

```bash
# Homebrew
brew uninstall natilius

# Script install
~/.natilius/uninstall.sh
```

---

## Usage

```bash
natilius [command] [options]
```

### Commands

| Command | Description |
|---------|-------------|
| `setup` | Run the full setup (default) |
| `doctor` | Check system readiness and diagnose issues |
| `list-modules` | Show all available modules |
| `version` | Show version information |
| `help` | Show help message |

### Options

| Option | Description |
|--------|-------------|
| `-p, --profile NAME` | Use a specific profile (minimal, devops, developer) |
| `-c, --check` | Dry run—preview changes without installing |
| `-i, --interactive` | Choose modules interactively |
| `-v, --verbose` | Show detailed output |
| `-q, --quiet` | Suppress non-error output |

### Examples

```bash
# Preview what would be installed
natilius --check

# Use the DevOps profile
natilius --profile devops

# Interactive module selection
natilius --interactive

# Quiet mode for automation
natilius --quiet setup
```

---

## Configuration

Natilius is configured via `~/.natiliusrc`. This file controls:
- Which modules run
- What packages to install
- Language versions
- IDE preferences

### Quick Config

```bash
# Edit your config
nano ~/.natiliusrc

# Or use a profile as a starting point
cp ~/.natilius/profiles/devops.natiliusrc ~/.natiliusrc
```

### Key Settings

```bash
# Enable/disable modules
ENABLED_MODULES=(
    "system/system_update"
    "applications/homebrew"
    "dev_environments/python"
    "dev_environments/node"
    "ide/ide_setup"
)

# Language versions
PYTHONVER="3.11.0"
NODEVER="20.10.0"
GOVER="1.21.0"

# IDE preferences
INSTALL_VSCODE=true
INSTALL_JETBRAINS=false
```

See [Configuration Reference](docs/configuration.md) for all options.

---

## Profiles

Profiles are pre-configured setups for different roles. Use them as-is or as a starting point.

| Profile | Best For | Includes |
|---------|----------|----------|
| `minimal` | Quick onboarding | Git, Homebrew, VS Code, essential CLI tools |
| `devops` | Platform/SRE engineers | Kubernetes, Terraform, Docker, cloud CLIs, Python, Go |
| `developer` | Full-stack developers | Multiple languages, IDEs, databases, all dev tools |

### Using Profiles

```bash
# Use a profile directly
natilius --profile devops

# Or copy to customize
cp ~/.natilius/profiles/devops.natiliusrc ~/.natiliusrc
nano ~/.natiliusrc
natilius setup
```

### Profile Inheritance

Create custom profiles that extend the base:

```bash
# ~/.natiliusrc.myteam
source ~/.natiliusrc.base
ENABLED_MODULES+=("dev_environments/rust")
BREWPACKAGES+=("my-custom-tool")
```

---

## Automation & Terraform

Natilius is built for infrastructure-as-code workflows.

### Environment Variables

| Variable | Description |
|----------|-------------|
| `SKIP_SUDO=true` | Skip sudo prompts (CI/CD) |
| `NONINTERACTIVE=true` | No prompts at all |
| `DRY_RUN=true` | Preview mode |
| `QUIET_MODE=true` | Minimal output |

### Terraform Example

```hcl
resource "null_resource" "mac_setup" {
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s devops"
    ]
  }
}
```

### CI/CD Example

```yaml
- name: Setup Mac
  run: |
    SKIP_SUDO=true NONINTERACTIVE=true natilius --quiet setup
```

See [Automation Guide](docs/automation.md) for more examples.

---

## System Requirements

- **macOS** 13 (Ventura) or later
- **Architecture** Intel or Apple Silicon (M1/M2/M3/M4)
- **Disk Space** ~10GB for full install
- **Internet** Required for initial setup

---

## Documentation

| Document | Description |
|----------|-------------|
| [Configuration Reference](docs/configuration.md) | All config options explained |
| [Module Guide](docs/modules.md) | Available modules and what they do |
| [Automation Guide](docs/automation.md) | Terraform, Ansible, CI/CD integration |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and solutions |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Quick Reference](QUICK_REFERENCE.md) | Cheat sheet for experienced users |

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

```bash
# Development setup
git clone https://github.com/vincentkoc/natilius.git
cd natilius
make dev-setup

# Run tests
make test

# Run linter
make lint
```

---

## Support

- **Issues**: [GitHub Issues](https://github.com/vincentkoc/natilius/issues)
- **Discussions**: [GitHub Discussions](https://github.com/vincentkoc/natilius/discussions)

If Natilius saves you time, consider [starring the repo](https://github.com/vincentkoc/natilius) — it helps others discover the project.

---

## License

[GPL-3.0](LICENSE) — Natilius is free and open source.

---

<p align="center">
  Made with care by <a href="https://github.com/vincentkoc">Vincent Koc</a>
</p>
