# Environment Variables

Control Natilius behavior at runtime.

## Runtime Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SKIP_SUDO` | `false` | Skip sudo validation |
| `NONINTERACTIVE` | `false` | Disable prompts |
| `DRY_RUN` | `false` | Preview mode |
| `VERBOSE_MODE` | `false` | Debug output |
| `QUIET_MODE` | `false` | Errors only |
| `SKIP_UPDATE_CHECK` | `false` | Skip update check |
| `CI` | `false` | CI environment |

## Path Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NATILIUS_HOME` | `~/.natilius` | Installation directory |

## Installer Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SKIP_RUN` | `false` | Install without running |
| `NATILIUS_BRANCH` | `main` | Git branch |

## Examples

### Fully Automated

```bash
SKIP_SUDO=true \
NONINTERACTIVE=true \
QUIET_MODE=true \
natilius setup
```

### CI/CD

```yaml
- name: Setup
  run: |
    SKIP_SUDO=true NONINTERACTIVE=true natilius setup
```

### Terraform

```hcl
provisioner "remote-exec" {
  inline = [
    "SKIP_SUDO=true NONINTERACTIVE=true natilius setup"
  ]
}
```
