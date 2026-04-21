# Quick Start

Get your Mac set up for development in 5 minutes.

## Install Natilius

/// tab | Homebrew

```bash
brew install vincentkoc/tap/natilius
```

///

/// tab | Script

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
```

///

/// tab | Manual

```bash
git clone https://github.com/vincentkoc/natilius.git ~/.natilius
cd ~/.natilius && make install
```

///

## Run Setup

**Step 1: Check your system**

```bash
natilius doctor
```

This verifies your Mac is ready and shows any issues.

**Step 2: Preview changes**

```bash
natilius --check
```

See what would be installed without making changes.

**Step 3: Run setup**

```bash
natilius setup
```

Go grab a coffee—this takes 10-30 minutes depending on your config.

## Using Profiles

Profiles are pre-configured setups for different roles:

```bash
# Quick onboarding - essentials only
natilius --profile minimal

# Kubernetes, Terraform, cloud tools
natilius --profile devops

# Full dev environment
natilius --profile developer
```

| Profile     | Best For               | Includes                                           |
| ----------- | ---------------------- | -------------------------------------------------- |
| `minimal`   | Quick onboarding       | Git, Homebrew, VS Code, essential CLI tools        |
| `devops`    | Platform/SRE engineers | K8s, Terraform, Docker, cloud CLIs, Python, Go     |
| `developer` | Full-stack developers  | Multiple languages, IDEs, databases, all dev tools |

## Customize Your Setup

Edit `~/.natiliusrc` to control what gets installed:

```bash
nano ~/.natiliusrc
```

Key settings:

```bash
# Enable/disable modules
ENABLED_MODULES=(
    "system/system_update"
    "applications/homebrew"
    "dev_environments/python"
    "ide/ide_setup"
)

# Pin language versions
PYTHONVER="3.11.0"
NODEVER="20.10.0"

# Choose your IDE
INSTALL_VSCODE=true
INSTALL_JETBRAINS=false
```

## What's Next?

- [Configuration Guide](../configuration/index.md) — Customize every aspect
- [Available Modules](../configuration/modules.md) — See all modules
- [Automation Guide](../guides/automation.md) — Use with Terraform, Ansible
- [Troubleshooting](../guides/troubleshooting.md) — Common issues
