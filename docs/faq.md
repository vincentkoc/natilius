# FAQ

Frequently asked questions about Natilius.

---

## General

### What is Natilius?

Natilius is an automated Mac developer environment setup tool. It installs and configures 100+ development tools, applications, and system settings with a single command.

### Is it safe to run?

Yes. Natilius is:

- **Open source** — All code is visible on GitHub
- **Idempotent** — Safe to run multiple times
- **Non-destructive** — Won't overwrite existing configurations without asking
- **Dry-run capable** — Preview changes with `--check` before applying

### Does it work on Apple Silicon?

Yes. Natilius fully supports both Intel and Apple Silicon (M1/M2/M3/M4) Macs.

### What macOS versions are supported?

macOS 13 (Ventura) and later. Some features may work on older versions but aren't officially supported.

---

## Installation

### How do I install Natilius?

```bash
# One-liner
curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | bash

# Or via Homebrew
brew install vincentkoc/tap/natilius
```

### How do I uninstall?

```bash
# If installed via installer
~/.natilius/uninstall.sh

# If installed via Homebrew
brew uninstall natilius
```

### Can I install without sudo?

Yes. Set `SKIP_SUDO=true`:

```bash
SKIP_SUDO=true natilius setup
```

Note: Some features (like system preferences) require sudo.

---

## Configuration

### Where is the config file?

`~/.natiliusrc` — Copy from `.natiliusrc.example` and customize.

### How do I enable/disable modules?

Edit the `ENABLED_MODULES` array in `~/.natiliusrc`:

```bash
ENABLED_MODULES=(
    "system/updates"
    "applications/homebrew"
    # "dev_environments/python"  # Commented = disabled
)
```

### How do I use profiles?

```bash
# Use a built-in profile
natilius --profile devops

# Or create your own
cp ~/.natiliusrc ~/.natiliusrc.myprofile
natilius --profile myprofile
```

### Can I customize tool versions?

Yes. Set version variables in `.natiliusrc`:

```bash
PYTHONVER="3.12"
NODEVER="20"
RUBYVER="3.3"
```

---

## Troubleshooting

### Homebrew installation fails

1. Check your internet connection
2. Run `xcode-select --install` first
3. Try: `HOMEBREW_NO_AUTO_UPDATE=1 natilius setup`

### Permission denied errors

1. Ensure you have admin rights
2. Check if `SKIP_SUDO=true` is set unintentionally
3. Run: `sudo chown -R $(whoami) ~/.natilius`

### A module keeps failing

1. Run with verbose mode: `natilius --verbose`
2. Check logs: `ls -la ~/.natilius/logs/`
3. Run just that module in isolation
4. [Open an issue](https://github.com/vincentkoc/natilius/issues)

### How do I reset everything?

```bash
# Remove Natilius
~/.natilius/uninstall.sh

# Optionally remove installed tools
# (Be careful - this removes Homebrew and everything installed through it)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

---

## Automation

### Can I use this in CI/CD?

Yes. Use non-interactive mode:

```bash
SKIP_SUDO=true NONINTERACTIVE=true natilius setup
```

### Does it work with Terraform?

Yes. See [Terraform Guide](guides/terraform.md) for examples.

### Can I provision multiple Macs?

Yes. Combine with:

- **Terraform** — For cloud/remote Macs
- **Ansible** — For fleet management
- **MDM** — Works alongside Jamf, Kandji, etc.

---

## Contributing

### How do I add a new module?

See [Creating Modules](contributing/creating-modules.md).

### How do I report a bug?

[Open a GitHub issue](https://github.com/vincentkoc/natilius/issues/new) with:

1. macOS version
2. Natilius version (`natilius --version`)
3. Steps to reproduce
4. Error logs

### How do I request a feature?

[Start a GitHub Discussion](https://github.com/vincentkoc/natilius/discussions/new?category=ideas).
