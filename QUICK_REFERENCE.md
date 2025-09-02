# Natilius Quick Reference 🐚

## Installation
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
```

## Basic Commands

| Command | Description |
|---------|-------------|
| `natilius` | Run default setup |
| `natilius doctor` | System diagnostics |
| `natilius list-modules` | Show available modules |
| `natilius --check` | Dry run (no changes) |
| `natilius --help` | Show help |

## Command Options

| Option | Short | Description |
|--------|-------|-------------|
| `--verbose` | `-v` | Detailed output |
| `--quiet` | `-q` | Minimal output |
| `--interactive` | `-i` | Interactive mode |
| `--check` | `-c` | Dry run mode |
| `--profile NAME` | `-p` | Use specific profile |

## Quick Examples

```bash
# Check system before setup
natilius doctor

# See what would be installed
natilius --check

# Run setup with detailed output
natilius --verbose

# Interactive module selection
natilius --interactive

# Use work profile
natilius --profile work

# Quiet installation
natilius --quiet
```

## Development Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all dev commands |
| `make test` | Run tests |
| `make lint` | Run linting |
| `make dev-setup` | Setup dev environment |
| `make coverage` | Generate coverage |

## Configuration

### Default Config Location
- `~/.natiliusrc` - Main configuration
- `~/.natiliusrc.PROFILE` - Profile-specific config

### Key Config Variables
```bash
ENABLED_MODULES=(
    "system/system_update"
    "applications/homebrew"
    "dev_environments/python"
    # ... more modules
)

PYTHONVER="3.11"
NODEVER="18.0.0"
RUBYVER="3.2.0"
```

## Troubleshooting

### Common Issues

1. **Permission denied**
   ```bash
   # Run doctor to check sudo access
   natilius doctor
   ```

2. **Module not found**
   ```bash
   # List available modules
   natilius list-modules
   ```

3. **Network issues**
   ```bash
   # Check connectivity with doctor
   natilius doctor
   ```

### Get Help
- Run `natilius doctor` for system diagnostics
- Check `natilius --help` for usage information
- Use `natilius --check` to preview changes
- Visit: https://github.com/vincentkoc/natilius/issues

## Shell Completions

### Bash
```bash
echo 'source /path/to/natilius/completions/natilius-completion.bash' >> ~/.bashrc
```

### Zsh
```bash
echo 'source /path/to/natilius/completions/natilius-completion.zsh' >> ~/.zshrc
```

---

💡 **Tip**: Always run `natilius doctor` first to check your system health!

🔍 **Tip**: Use `natilius --check` to preview what will be installed before running the actual setup!

🚀 **Tip**: Enable shell completions for tab completion of commands and options!
