# Contributing to Natilius

Thank you for your interest in contributing to Natilius! This guide will help you get started.

## Quick Start

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/natilius.git
cd natilius

# Set up development environment
make dev-setup

# Create a branch
git checkout -b feature/your-feature

# Make changes, then test
make test
make lint

# Commit and push
git add .
git commit -m "feat: add your feature"
git push origin feature/your-feature
```

Then open a Pull Request on GitHub.

---

## Development Setup

### Prerequisites

- macOS (for full testing)
- Git
- Homebrew (recommended)

### Install Development Dependencies

```bash
make dev-setup
```

This installs:
- `bats-core` — Bash testing framework
- `shellcheck` — Shell script linter
- `pre-commit` — Git hooks for code quality

### Project Structure

```
natilius/
├── natilius.sh              # Main entry point
├── install.sh               # Installer script
├── uninstall.sh             # Uninstaller script
├── lib/                     # Shared library functions
│   ├── utils.sh             # Core utilities
│   ├── logging.sh           # Logging functions
│   ├── config_validator.sh  # Config validation
│   └── network_utils.sh     # Network operations
├── modules/                 # Feature modules
│   ├── system/              # System modules
│   ├── applications/        # App installation modules
│   ├── dev_environments/    # Language setup modules
│   ├── ide/                 # IDE setup modules
│   └── preferences/         # System preferences
├── profiles/                # Pre-built config profiles
├── tests/                   # Test suites
├── docs/                    # Documentation
└── completions/             # Shell completions
```

---

## Code Standards

### Shell Script Guidelines

1. **Use Bash 3.2+** — macOS ships with Bash 3.2
2. **Pass ShellCheck** — All scripts must pass `shellcheck -x`
3. **Use `set -euo pipefail`** — For robust error handling
4. **Quote variables** — Always quote `"$variables"`
5. **Use `[[` over `[`** — More robust conditionals

### Style Guide

```bash
# Function naming: lowercase with underscores
my_function_name() {
    local var_name="value"  # Local variables
    # ...
}

# Constants: uppercase
readonly MY_CONSTANT="value"

# Prefer long options for clarity in scripts
curl --silent --fail --location "$url"  # Not: curl -sfL

# Error messages to stderr
log_error "Something went wrong" >&2
```

### Commit Messages

Follow [Conventional Commits](https://conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation only
- `style:` — Formatting, no code change
- `refactor:` — Code change that neither fixes nor adds
- `test:` — Adding or updating tests
- `chore:` — Maintenance tasks

**Examples:**
```
feat(python): add support for Python 3.12
fix(homebrew): handle missing taps gracefully
docs(readme): update installation instructions
```

---

## Testing

### Running Tests

```bash
# All tests
make test-all

# Unit tests only
make test

# Integration tests
make integration-test

# Config validation tests
make test-config

# Specific test file
bats tests/test_natilius.bats
```

### Writing Tests

Tests use [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

```bash
# tests/test_example.bats

setup() {
    # Runs before each test
    source lib/utils.sh
}

teardown() {
    # Runs after each test
}

@test "my_function returns success" {
    run my_function "arg1"
    [ "$status" -eq 0 ]
}

@test "my_function outputs expected result" {
    run my_function "input"
    [ "$output" = "expected output" ]
}
```

### Test Coverage

```bash
make coverage
```

---

## Creating Modules

Modules are self-contained scripts that handle specific setup tasks.

### Module Template

```bash
#!/bin/bash

# natilius - Module Name
# Description of what this module does
#
# Copyright (C) 2024 Vincent Koc (@vincent_koc)
# License: GPL-3.0-or-later

# ============================================================================
# MODULE: module_name
# Description: Brief description
# Dependencies: homebrew (optional - list required modules)
# Config: VARIABLE_NAME (optional - list config variables used)
# ============================================================================

log_info "Starting module_name setup..."

# Check prerequisites
if ! command -v required_tool &> /dev/null; then
    log_warning "required_tool not found, skipping module"
    return 0
fi

# Idempotent check
if [ -f "$HOME/.already_configured" ]; then
    log_success "module_name already configured, skipping"
else
    # Main logic here
    log_success "module_name setup complete"
fi
```

### Module Guidelines

1. **Be idempotent** — Safe to run multiple times
2. **Check prerequisites** — Verify dependencies exist
3. **Use logging** — `log_info`, `log_success`, `log_warning`, `log_error`
4. **Handle errors gracefully** — Don't crash the entire setup
5. **Document dependencies** — List required modules in header

---

## Pull Request Process

### Before Submitting

1. **Test thoroughly**
   ```bash
   make test-all
   make lint
   ```

2. **Update documentation** if needed

3. **Add tests** for new functionality

4. **Run pre-commit hooks**
   ```bash
   make precommit
   ```

### PR Guidelines

- **One feature per PR** — Keep changes focused
- **Descriptive title** — Use conventional commit format
- **Fill out PR template** — Describe changes and testing
- **Link issues** — Reference related issues with `Fixes #123`

---

## Reporting Issues

### Bug Reports

Include:
1. macOS version (`sw_vers`)
2. Architecture (`uname -m`)
3. Natilius version (`natilius version`)
4. Steps to reproduce
5. Expected vs actual behavior
6. Relevant log output

### Feature Requests

Include:
1. Use case description
2. Proposed solution
3. Alternatives considered

---

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 License.

---

Thank you for contributing!
