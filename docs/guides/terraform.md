# Terraform Integration

Provision Mac developer environments with Terraform using the dedicated provisioning script.

## Prerequisites

For fully automated (passwordless) provisioning:

1. **SSH access** to the target Mac
2. **Passwordless sudo** (optional) - configure via:
   ```bash
   # On target Mac, add to /etc/sudoers.d/natilius
   %admin ALL=(ALL) NOPASSWD: /usr/sbin/softwareupdate, /usr/bin/xcode-select
   ```
   Or use `SKIP_SUDO=true` to skip operations requiring sudo.

3. **Xcode Command Line Tools** - The provisioner attempts automatic installation, but may require manual confirmation on first run.

## Quick Start

```hcl
resource "null_resource" "mac_setup" {
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s devops"
    ]
  }
}
```

## Environment Variables

Control provisioning behavior with environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `NATILIUS_BRANCH` | `main` | Git branch to install from |
| `NONINTERACTIVE` | `true` | Skip all prompts (auto-set) |
| `CI` | `true` | CI mode (auto-set) |
| `SKIP_SUDO` | `false` | Skip sudo operations |
| `DRY_RUN` | `false` | Preview changes without applying |
| `QUIET_MODE` | `false` | Minimal output |

## Full Example

```hcl
variable "mac_host" {
  type = string
}

variable "mac_user" {
  default = "admin"
}

variable "ssh_key_path" {
  type = string
}

variable "profile" {
  default = "devops"
}

resource "null_resource" "mac_setup" {
  connection {
    type        = "ssh"
    host        = var.mac_host
    user        = var.mac_user
    private_key = file(var.ssh_key_path)
    timeout     = "30m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s ${var.profile}"
    ]
  }
}
```

## Custom Configuration

Upload a custom `.natiliusrc` before running setup:

```hcl
resource "null_resource" "mac_setup" {
  connection {
    type        = "ssh"
    host        = var.mac_host
    user        = var.mac_user
    private_key = file(var.ssh_key_path)
  }

  # Upload custom config
  provisioner "file" {
    source      = "configs/${var.team}.natiliusrc"
    destination = "/Users/${var.mac_user}/.natiliusrc"
  }

  # Install and run
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true bash",
      "NONINTERACTIVE=true SKIP_SUDO=true ~/.natilius/natilius.sh setup"
    ]
  }
}
```

## Skip Sudo Operations

For environments where sudo isn't available or desirable:

```hcl
resource "null_resource" "mac_setup" {
  provisioner "remote-exec" {
    inline = [
      "export SKIP_SUDO=true",
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s minimal"
    ]
  }
}
```

When `SKIP_SUDO=true`:
- CLI installed to `~/.local/bin` instead of `/usr/local/bin`
- System-wide completions skipped
- Security module operations skipped
- macOS preferences requiring sudo skipped

## Multiple Macs

Provision a fleet of Macs with different profiles:

```hcl
variable "macs" {
  type = map(object({
    host    = string
    profile = string
  }))
  default = {
    "dev-1" = { host = "192.168.1.10", profile = "developer" }
    "dev-2" = { host = "192.168.1.11", profile = "devops" }
    "build" = { host = "192.168.1.12", profile = "minimal" }
  }
}

resource "null_resource" "mac_setup" {
  for_each = var.macs

  connection {
    type        = "ssh"
    host        = each.value.host
    user        = var.mac_user
    private_key = file(var.ssh_key_path)
    timeout     = "30m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s ${each.value.profile}"
    ]
  }
}

output "provisioned_macs" {
  value = [for k, v in var.macs : "${k}: ${v.host} (${v.profile})"]
}
```

## Dry Run Mode

Preview what would be installed without making changes:

```hcl
resource "null_resource" "mac_preview" {
  provisioner "remote-exec" {
    inline = [
      "export DRY_RUN=true",
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s devops"
    ]
  }
}
```

## Available Profiles

| Profile | Description |
|---------|-------------|
| `minimal` | Essential tools only (git, brew, basic CLI) |
| `developer` | Full development environment |
| `devops` | Kubernetes, Terraform, cloud CLIs |
| `clawdbot` | AI agent machines (moltbot, Node.js 24, Chrome) |

See [Profiles](../configuration/profiles.md) for details, or the [Clawdbot Guide](./clawdbot.md) for AI agent provisioning.

## Troubleshooting

### Xcode CLT Installation Hangs
The provisioner attempts silent Xcode CLT installation. If it hangs:
1. SSH to the Mac manually
2. Run `xcode-select --install` and complete the GUI prompt
3. Re-run Terraform

### Homebrew Requires Password
Homebrew installation may prompt for password on first run. Solutions:
- Pre-install Homebrew before Terraform
- Configure passwordless sudo for Homebrew
- Use `SKIP_SUDO=true` (limited functionality)

### Timeout Issues
Increase the connection timeout for slow networks or large profiles:
```hcl
connection {
  timeout = "60m"
}
```
