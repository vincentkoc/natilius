# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Natilius is an automated Mac developer environment setup tool. It's a modular bash-based system that installs and configures developer tools, applications, and system settings on macOS with one command.

## Build, Test, and Development Commands

```bash
# Testing
make test              # Run unit tests (bats)
make test-cli          # Run CLI feature tests
make test-modules      # Run module tests
make integration-test  # Run integration tests
make test-config       # Run config validator tests
make test-all          # Run all tests + precommit hooks

# Run a single test file
BATS_LIB_PATH="$(pwd)/lib" bats tests/<test_file>.bats

# Code quality
make lint              # Run shellcheck on all shell scripts
make precommit         # Run pre-commit hooks (shellcheck, yaml, tests)

# Documentation
make docs              # Serve docs locally at http://127.0.0.1:8000
make docs-build        # Build documentation site

# Development
make install-deps      # Install bats-core, shellcheck, pre-commit
make dev-setup         # Full dev environment setup
make check-version     # Check version consistency across files
```

## Architecture

### Core Components

**Main Script** (`natilius.sh`): Entry point that parses arguments, loads configuration from `~/.natiliusrc`, sources library functions, and executes enabled modules in sequence.

**Library Functions** (`lib/`):
- `utils.sh` - Version management, sudo handling, update checks
- `logging.sh` - log_info, log_success, log_warning, log_error functions
- `config_validator.sh` - Configuration validation
- `network_utils.sh` - Network operations with retry logic
- `mdm_utils.sh` - MDM/enterprise detection (Jamf, Kandji)

**Module System** (`modules/`): Self-contained modules enabled via `ENABLED_MODULES` array in config:
- `system/` - system_update, directories, security, cleanup
- `applications/` - homebrew, apps, espanso
- `dev_environments/` - python, node, ruby, rust, go, java, php, flutter
- `ide/` - vscode_setup, jetbrains_setup, sublime_setup, zed_setup
- `preferences/` - mac_preferences, system_preferences
- `dotfiles.sh` - Dotfile management

**Profiles** (`profiles/`): Pre-configured module sets (minimal, devops, developer, clawdbot). Profiles source `base.natiliusrc` and override/extend settings.

**Configuration** (`~/.natiliusrc`): User config file controlling:
- `ENABLED_MODULES` array - which modules run
- `BREWPACKAGES`, `BREWCASKS`, `APPSTORE` arrays - what gets installed
- Version variables (`PYTHONVER`, `NODEVER`, etc.)
- IDE flags (`INSTALL_VSCODE`, `INSTALL_CURSOR`, etc.)

### Execution Flow

1. Script validates macOS environment
2. Loads `~/.natiliusrc` (copies from `.natiliusrc.example` if missing)
3. Sources `lib/*.sh` utilities
4. Iterates through `ENABLED_MODULES` array
5. Each module is sourced and executed
6. Logs all operations to `~/.natilius/logs/`

### Key Design Patterns

- **Idempotency**: Modules check for existing installations before acting
- **Error Handling**: `set -e` with trap for stack traces
- **Network Resilience**: Retry logic with exponential backoff in `network_utils.sh`
- **Environment Variables**: `SKIP_SUDO`, `NONINTERACTIVE`, `DRY_RUN` control behavior

## Testing Framework

Uses BATS (Bash Automated Testing System):
- `tests/test_natilius.bats` - Unit tests
- `tests/test_cli_features.bats` - CLI command tests
- `tests/test_modules.bats` - Module tests
- `tests/integration_tests.bats` - Integration tests
- `tests/test_config_validator.sh` - Config validation tests

## Automation/Terraform

`scripts/terraform-provision.sh` - Non-interactive provisioning script for Terraform/Ansible:
- Defaults `NONINTERACTIVE=true`, `SKIP_SUDO=true`, `CI=true`
- Installs Homebrew, clones natilius, sets up profile, runs setup
- Usage: `curl -fsSL .../terraform-provision.sh | bash -s <profile>`

## Code Standards

- All shell scripts must pass shellcheck (configured in `.shellcheckrc`)
- Profile/config files use `#!/bin/bash` with `# shellcheck disable=SC2034,SC2088,SC2148`
- Network operations use retry logic from `network_utils.sh`
- Functions include error handling and logging
