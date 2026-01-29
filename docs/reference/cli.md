# CLI Reference

## Synopsis

```bash
natilius [command] [options]
```

## Commands

| Command | Description |
|---------|-------------|
| `setup` | Run the full setup (default) |
| `doctor` | Check system readiness |
| `list-modules` | Show available modules |
| `version` | Show version |
| `help` | Show help |

## Options

| Option | Description |
|--------|-------------|
| `-p, --profile NAME` | Use a specific profile |
| `-c, --check` | Dry run (preview changes) |
| `-i, --interactive` | Interactive mode |
| `-v, --verbose` | Detailed output |
| `-q, --quiet` | Suppress non-error output |

## Examples

```bash
# Basic setup
natilius

# Preview changes
natilius --check

# Use profile
natilius --profile devops

# Interactive
natilius --interactive

# Quiet mode
natilius --quiet setup

# Combine options
natilius -v --profile developer --check
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Error |
