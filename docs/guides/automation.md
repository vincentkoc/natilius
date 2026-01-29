# Automation

Use Natilius with Terraform, Ansible, and CI/CD pipelines for automated Mac provisioning.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NONINTERACTIVE` | `false` | Skip all prompts |
| `SKIP_SUDO` | `false` | Skip sudo operations |
| `CI` | `false` | CI mode (implies NONINTERACTIVE) |
| `DRY_RUN` | `false` | Preview mode |
| `QUIET_MODE` | `false` | Minimal output |
| `SKIP_RUN` | `false` | Install only, don't run setup |
| `NATILIUS_BRANCH` | `main` | Git branch to use |

## Fully Automated Run

```bash
SKIP_SUDO=true \
NONINTERACTIVE=true \
QUIET_MODE=true \
natilius setup
```

## Terraform

Use the dedicated provisioning script for remote Mac setup:

```hcl
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

variable "profile" {
  default = "devops"
}
```

See [Terraform Integration](terraform.md) for full documentation.

## Ansible

```yaml
---
- name: Setup Mac Developer Environment
  hosts: macs
  vars:
    natilius_profile: devops

  tasks:
    - name: Install Natilius
      shell: |
        curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true bash
      args:
        creates: ~/.natilius/natilius.sh

    - name: Copy profile config
      copy:
        src: "profiles/{{ natilius_profile }}.natiliusrc"
        dest: ~/.natiliusrc

    - name: Run Natilius setup
      shell: NONINTERACTIVE=true SKIP_SUDO=true ~/.natilius/natilius.sh setup
      environment:
        PATH: "/opt/homebrew/bin:{{ ansible_env.PATH }}"
```

## GitHub Actions

For macOS runners:

```yaml
jobs:
  setup:
    runs-on: macos-latest
    steps:
      - name: Setup Mac with Natilius
        run: |
          curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true bash
          NONINTERACTIVE=true SKIP_SUDO=true ~/.natilius/natilius.sh --profile minimal setup
```

## One-Liner Install

For scripts and automation:

```bash
# Install and run with profile
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s devops

# Install only (no setup)
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true NONINTERACTIVE=true bash
```

## Idempotency

Natilius is safe to run multiple times:

```bash
natilius setup  # First run: installs everything
natilius setup  # Second run: skips installed items
```

All modules check for existing installations before making changes.

## Skip Sudo Mode

When `SKIP_SUDO=true`:

- CLI installed to `~/.local/bin` instead of `/usr/local/bin`
- System-wide completions skipped
- Security module operations skipped
- Some macOS preferences unavailable

Ensure `~/.local/bin` is in your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```
