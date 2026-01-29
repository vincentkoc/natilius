# Automation

Use Natilius with Terraform, Ansible, and CI/CD.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SKIP_SUDO` | `false` | Skip sudo prompts |
| `NONINTERACTIVE` | `false` | No prompts at all |
| `DRY_RUN` | `false` | Preview mode |
| `QUIET_MODE` | `false` | Errors only |

### Fully Automated Run

```bash
SKIP_SUDO=true \
NONINTERACTIVE=true \
QUIET_MODE=true \
natilius setup
```

## Terraform

```hcl
resource "null_resource" "mac_setup" {
  connection {
    type        = "ssh"
    host        = var.mac_host
    user        = var.mac_user
    private_key = file(var.ssh_key_path)
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

## Ansible

```yaml
---
- name: Setup Mac
  hosts: macs

  tasks:
    - name: Install Natilius
      shell: |
        curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true bash

    - name: Run setup
      shell: NONINTERACTIVE=true ~/.natilius/natilius.sh setup
```

## GitHub Actions

```yaml
- name: Setup Mac
  run: |
    SKIP_SUDO=true NONINTERACTIVE=true natilius --quiet setup
```

## Idempotency

Natilius is safe to run multiple times:

```bash
natilius setup  # First run: installs everything
natilius setup  # Second run: skips installed items
```
