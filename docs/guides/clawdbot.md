# Clawdbot / Moltbot Agent Setup

Auto-provision Mac instances for running [moltbot](https://www.npmjs.com/package/moltbot) AI agents with Terraform and restore configurations via Mackup/iCloud.

## Overview

Clawdbot is a dedicated Natilius profile designed for provisioning remote Mac machines that run moltbot - a Node.js-based AI agent gateway. This guide covers:

- **Automated provisioning** via Terraform
- **Configuration restoration** via Mackup + iCloud
- **Headless operation** for CI/CD and remote setups

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Your Infrastructure                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐      SSH        ┌──────────────────────────────┐  │
│  │   Terraform  │ ───────────────▶│      Remote Mac (clawdbot)   │  │
│  │   Workstation│                 │                              │  │
│  └──────────────┘                 │  ┌────────────────────────┐  │  │
│                                   │  │  moltbot gateway       │  │  │
│                                   │  │  (Node.js >= 22)       │  │  │
│  ┌──────────────┐                 │  └────────────────────────┘  │  │
│  │    iCloud    │◀────Mackup─────▶│                              │  │
│  │   (dotfiles) │     restore     │  Chrome, 1Password, Tailscale│  │
│  └──────────────┘                 └──────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## What's Included in the Clawdbot Profile

### Core Components

| Category      | Tools                                     |
| ------------- | ----------------------------------------- |
| **Runtime**   | Node.js 24, Python (latest), pnpm, yarn   |
| **AI Agent**  | moltbot (installed globally via npm)      |
| **Security**  | 1Password, 1Password CLI, Tailscale, GPG  |
| **Browser**   | Google Chrome (for moltbot web interface) |
| **Terminal**  | iTerm2, tmux, zsh with completions        |
| **Dev Tools** | Git, GitHub CLI, claude-code, codex       |

### Enabled Modules

```bash
ENABLED_MODULES=(
    "system/system_update"      # macOS updates, Xcode CLT, Rosetta
    "system/directories"        # Create required directories
    "system/security"           # Firewall, FileVault, Gatekeeper
    "preferences/mac_preferences"
    "preferences/system_preferences"
    "applications/homebrew"     # Homebrew + packages
    "applications/apps"         # Casks + App Store
    "dev_environments/node"     # Node.js + global packages
    "dev_environments/python"   # Python + global packages
    "dotfiles"                  # Mackup restore
    "system/cleanup"            # Mole cleanup (optional)
)
```

## Quick Start

### One-Line Provisioning

SSH into your Mac and run:

```bash
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s clawdbot
```

This will:

1. Install Xcode Command Line Tools
2. Install Homebrew
3. Clone Natilius
4. Apply the clawdbot profile
5. Install all packages and configure the system

## Terraform Integration

### Basic Example

```hcl
# clawdbot.tf

variable "clawdbot_host" {
  description = "IP or hostname of the Mac to provision"
  type        = string
}

variable "clawdbot_user" {
  description = "SSH username"
  default     = "admin"
}

variable "ssh_private_key" {
  description = "Path to SSH private key"
  type        = string
}

resource "null_resource" "clawdbot_setup" {
  connection {
    type        = "ssh"
    host        = var.clawdbot_host
    user        = var.clawdbot_user
    private_key = file(var.ssh_private_key)
    timeout     = "45m"  # Allow time for Homebrew + packages
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s clawdbot"
    ]
  }
}

output "clawdbot_ready" {
  value = "Clawdbot provisioned at ${var.clawdbot_host}"
}
```

### With Mackup Restore

To automatically restore configurations from iCloud after provisioning:

```hcl
resource "null_resource" "clawdbot_setup" {
  connection {
    type        = "ssh"
    host        = var.clawdbot_host
    user        = var.clawdbot_user
    private_key = file(var.ssh_private_key)
    timeout     = "45m"
  }

  # Step 1: Provision the system
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s clawdbot"
    ]
  }

  # Step 2: Restore configs from iCloud via Mackup
  provisioner "remote-exec" {
    inline = [
      # Ensure iCloud is synced (may need manual login first time)
      "echo 'Waiting for iCloud sync...'",
      "sleep 30",

      # Restore dotfiles and app configs
      "mackup restore --force",

      # Verify moltbot is ready
      "which moltbot && moltbot --version || echo 'moltbot ready'"
    ]
  }
}
```

### Fleet Provisioning

Provision multiple clawdbot instances:

```hcl
variable "clawdbots" {
  type = map(object({
    host = string
    role = string  # e.g., "primary", "backup"
  }))
  default = {
    "clawdbot-1" = { host = "192.168.1.50", role = "primary" }
    "clawdbot-2" = { host = "192.168.1.51", role = "backup" }
  }
}

resource "null_resource" "clawdbot_fleet" {
  for_each = var.clawdbots

  connection {
    type        = "ssh"
    host        = each.value.host
    user        = var.clawdbot_user
    private_key = file(var.ssh_private_key)
    timeout     = "45m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s clawdbot"
    ]
  }

  triggers = {
    # Re-provision when profile changes
    profile_hash = filemd5("${path.module}/profiles/clawdbot.natiliusrc")
  }
}

output "clawdbot_fleet" {
  value = { for k, v in var.clawdbots : k => "${v.host} (${v.role})" }
}
```

## Mackup + iCloud Configuration

Mackup syncs application configurations to iCloud, enabling consistent settings across clawdbot instances.

### Initial Setup (Source Machine)

On your primary Mac where configs are already set up:

```bash
# 1. Install mackup
brew install mackup

# 2. Configure for iCloud
cat << 'EOF' > ~/.mackup.cfg
[storage]
engine = icloud
directory = dotfiles

[applications_to_sync]
google-chrome
iterm2
1password-cli
git
ssh
gpg
zsh
tmux

[applications_to_ignore]
# Apps that shouldn't sync
EOF

# 3. Backup configs to iCloud
mackup backup
```

### Supported Apps for Clawdbot

Mackup can sync these clawdbot-relevant configs:

| Application       | What's Synced                        |
| ----------------- | ------------------------------------ |
| **Google Chrome** | Extensions, bookmarks, settings      |
| **iTerm2**        | Profiles, color schemes, keybindings |
| **1Password CLI** | Account configurations               |
| **Git**           | `.gitconfig`, `.gitignore_global`    |
| **SSH**           | `~/.ssh/config` (not keys!)          |
| **GPG**           | Trust settings                       |
| **Zsh**           | `.zshrc`, `.zprofile`, plugins       |
| **tmux**          | `.tmux.conf`                         |

### Restore on Clawdbot

After Natilius provisioning, restore configs:

```bash
# Automatic (if NATILIUS_FORCE_DOTFILES_RESTORE=true)
NATILIUS_FORCE_DOTFILES_RESTORE=true natilius setup

# Or manual
mackup restore --force
```

### Custom Mackup Config

Create a custom `.mackup.cfg` for clawdbot-specific apps:

```ini
[storage]
engine = icloud
directory = clawdbot-dotfiles

[applications_to_sync]
google-chrome
iterm2
1password-cli
git
ssh
zsh

[applications_to_ignore]
# Desktop apps not needed on clawdbot
sublime-text
visual-studio-code
slack
discord
```

## Post-Provisioning Steps

### 1. Sign into iCloud

For Mackup restore to work, iCloud must be signed in:

```bash
# Check iCloud status
defaults read MobileMeAccounts

# If not signed in, use System Preferences > Apple ID
open "x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane"
```

### 2. Configure moltbot

After provisioning, configure moltbot:

```bash
# Create config directory (already done by Natilius)
mkdir -p ~/.config/moltbot

# Initialize moltbot configuration
moltbot init

# Or copy config from iCloud (if using Mackup)
cp ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/.config/moltbot/* ~/.config/moltbot/
```

### 3. Connect to Tailscale

For secure networking between clawdbot instances:

```bash
# Authenticate with Tailscale
tailscale up --authkey=tskey-auth-xxx

# Verify connection
tailscale status
```

### 4. Start moltbot

```bash
# Start the moltbot gateway
moltbot start

# Or run as a service (recommended)
moltbot service install
moltbot service start
```

## Environment Variables

Control clawdbot provisioning with these variables:

| Variable                          | Default | Description                  |
| --------------------------------- | ------- | ---------------------------- |
| `NATILIUS_BRANCH`                 | `main`  | Git branch for Natilius      |
| `NATILIUS_FORCE_DOTFILES_RESTORE` | `false` | Auto-restore Mackup configs  |
| `SKIP_SUDO`                       | `false` | Skip sudo operations         |
| `DRY_RUN`                         | `false` | Preview without changes      |
| `USE_MOLE_CLEANUP`                | `true`  | Run Mole cleanup after setup |

Example with all options:

```bash
NATILIUS_FORCE_DOTFILES_RESTORE=true \
DRY_RUN=false \
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s clawdbot
```

## Complete Terraform Module

A reusable module for clawdbot provisioning:

```hcl
# modules/clawdbot/main.tf

variable "host" {
  type = string
}

variable "user" {
  default = "admin"
}

variable "ssh_key_path" {
  type = string
}

variable "restore_mackup" {
  default = true
}

variable "tailscale_authkey" {
  type      = string
  sensitive = true
  default   = ""
}

resource "null_resource" "provision" {
  connection {
    type        = "ssh"
    host        = var.host
    user        = var.user
    private_key = file(var.ssh_key_path)
    timeout     = "45m"
  }

  # Provision with Natilius
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s clawdbot"
    ]
  }
}

resource "null_resource" "configure" {
  depends_on = [null_resource.provision]

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.user
    private_key = file(var.ssh_key_path)
  }

  # Restore Mackup configs
  provisioner "remote-exec" {
    inline = var.restore_mackup ? [
      "sleep 30",  # Wait for iCloud sync
      "mackup restore --force || true"
    ] : ["echo 'Skipping Mackup restore'"]
  }

  # Connect to Tailscale
  provisioner "remote-exec" {
    inline = var.tailscale_authkey != "" ? [
      "tailscale up --authkey=${var.tailscale_authkey}"
    ] : ["echo 'Skipping Tailscale setup'"]
  }
}

output "status" {
  value = "Clawdbot provisioned at ${var.host}"
}
```

Usage:

```hcl
module "clawdbot" {
  source = "./modules/clawdbot"

  host              = "192.168.1.50"
  user              = "admin"
  ssh_key_path      = "~/.ssh/clawdbot_ed25519"
  restore_mackup    = true
  tailscale_authkey = var.tailscale_key
}
```

## Troubleshooting

### iCloud Not Syncing

```bash
# Force iCloud sync
killall bird
sleep 5

# Check iCloud Drive status
ls ~/Library/Mobile\ Documents/com~apple~CloudDocs/
```

### Mackup Restore Fails

```bash
# Check Mackup config
cat ~/.mackup.cfg

# Verify iCloud path exists
ls ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/

# Run with verbose output
mackup restore --force --verbose
```

### moltbot Not Found

```bash
# Check Node.js version (needs >= 22)
node --version

# Reinstall moltbot
npm install -g moltbot

# Verify PATH
which moltbot
```

### SSH Connection Timeout

Increase timeout in Terraform:

```hcl
connection {
  timeout = "60m"
}
```

## Security Considerations

1. **SSH Keys**: Use Ed25519 keys for clawdbot access
2. **Tailscale**: Prefer Tailscale over exposing SSH to the internet
3. **1Password**: Store secrets in 1Password, access via CLI
4. **FileVault**: Enabled by default in clawdbot profile
5. **Firewall**: Enabled with stealth mode by default

## Related Documentation

- [Terraform Integration](./terraform.md) - General Terraform usage
- [Profiles](../configuration/profiles.md) - Creating custom profiles
- [Automation Guide](./automation.md) - CI/CD integration
