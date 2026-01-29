# Natilius

**Set up your Mac for development in minutes, not hours.**

---

## What is Natilius?

Natilius automates Mac developer environment setup. Install 100+ tools, apps, and configurations with one command.

```bash
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | bash
natilius setup
```

That's it. Go grab a coffee while Natilius configures everything.

---

## Features

| Feature | Description |
|---------|-------------|
| **One Command Setup** | Install 100+ tools, apps, and configurations |
| **Modular Design** | Enable only what you need |
| **Role-Based Profiles** | Pre-configured for DevOps, Frontend, Backend |
| **Idempotent** | Safe to run multiple times |
| **Terraform Ready** | Built for automation and CI/CD |
| **Security Hardened** | FileVault, Firewall, Gatekeeper |

---

## What Gets Installed

=== "Languages"

    - **Python** — pyenv, pipenv, virtualenv
    - **Node.js** — nodenv, npm, yarn
    - **Ruby** — rbenv, bundler
    - **Go** — goenv
    - **Rust** — rustup, cargo
    - **Java** — jenv, Temurin JDK

=== "DevOps"

    - **Containers** — Docker, docker-compose
    - **Kubernetes** — kubectl, helm, k9s
    - **IaC** — Terraform, Ansible
    - **Cloud** — AWS CLI, Azure CLI

=== "Tools"

    - **Editors** — VS Code, JetBrains, Sublime
    - **Terminal** — iTerm2, tmux
    - **Git** — git, gh CLI, git-lfs
    - **Utilities** — jq, fzf, bat, htop

=== "Apps"

    - **Productivity** — Alfred, 1Password, Notion
    - **Communication** — Slack, Zoom
    - **Browsers** — Firefox, Brave
    - **And 50+ more...**

---

## Quick Start

### Install

=== "One-liner"

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
    ```

=== "Homebrew"

    ```bash
    brew install vincentkoc/tap/natilius
    ```

=== "Manual"

    ```bash
    git clone https://github.com/vincentkoc/natilius.git ~/.natilius
    cd ~/.natilius && ./install.sh
    ```

### Run

```bash
natilius doctor    # Check your system
natilius --check   # Preview changes
natilius setup     # Install everything
```

### Use Profiles

```bash
natilius --profile minimal    # Essentials only
natilius --profile devops     # K8s, Terraform, cloud tools
natilius --profile developer  # Full dev environment
```

---

## System Requirements

- **macOS** 13 (Ventura) or later
- **Architecture** Intel or Apple Silicon (M1/M2/M3/M4)
- **Disk Space** ~10GB for full install
- **Internet** Required for initial setup

---

## Next Steps

- [Quick Start Guide](getting-started/quickstart.md)
- [Configuration Reference](configuration/index.md)
- [Available Modules](configuration/modules.md)
