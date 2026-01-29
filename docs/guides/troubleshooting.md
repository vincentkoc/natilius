# Troubleshooting

Common issues and solutions.

## Quick Diagnostics

```bash
natilius doctor
```

## Installation Issues

### "Command not found: natilius"

```bash
# Restart shell
exec $SHELL

# Or add to PATH
export PATH="/usr/local/bin:$PATH"
```

### "Permission denied"

```bash
sudo chown -R $(whoami) /usr/local/bin
```

### Homebrew not found (Apple Silicon)

Add to `~/.zshrc`:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Runtime Issues

### "sudo: a password is required"

Options:

1. Run interactively: `natilius setup`
2. Use `SKIP_SUDO=true` (skips security module)

### Module fails: "command not found"

Ensure `homebrew` runs first:

```bash
ENABLED_MODULES=(
    "applications/homebrew"  # First!
    "dev_environments/python"
)
```

### Version not available

```bash
# Update version managers
brew upgrade pyenv nodenv

# List available
pyenv install --list | grep "3.12"
```

## Config Issues

### "Invalid version format"

```bash
# Wrong
PYTHONVER="3.11"

# Correct
PYTHONVER="3.11.0"
```

## Apple Silicon Issues

### Rosetta 2 errors

```bash
softwareupdate --install-rosetta --agree-to-license
```

### "Bad CPU type"

```bash
# Reinstall ARM version
brew reinstall <package>
```

## Debug Mode

```bash
natilius -v setup 2>&1 | tee debug.log
```

## Check Logs

```bash
ls ~/.natilius/logs/
cat ~/.natilius/logs/natilius-setup-*.log | tail -100
```

## Reset

```bash
~/.natilius/uninstall.sh
rm ~/.natiliusrc
curl -fsSL .../install.sh | bash
```
