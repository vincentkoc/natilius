# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Natilius is an automated Mac developer environment setup tool that configures a complete development environment with one click. It's a modular bash-based system that installs and configures developer tools, applications, and system settings on macOS.

## Build, Test, and Development Commands

### Testing
- **Run all tests**: `make test-all`
- **Run unit tests**: `make test` or `bats tests/test_natilius.bats`
- **Run integration tests**: `make integration-test` or `bats tests/integration_tests.bats`
- **Run config validator**: `make test-config` or `bash tests/test_config_validator.sh`
- **Run a single test file**: `BATS_LIB_PATH="$(pwd)/lib" bats tests/<test_file>.bats`

### Code Quality
- **Run linting**: `make lint` (runs shellcheck on all shell scripts)
- **Run pre-commit hooks**: `make precommit` (includes shellcheck, yaml validation, and tests)
- **Install dependencies**: `make install-deps` (installs pre-commit, bats-core, shellcheck)

### Development Workflow
1. Before committing: `make precommit` - This runs all linting, tests, and pre-commit hooks
2. For quick testing: `make test` - Runs unit tests only
3. For comprehensive testing: `make test-all` - Runs all test suites

## Architecture and Structure

### Core Components

1. **Main Script** (`natilius.sh`): Entry point that orchestrates the entire setup process. Handles command-line arguments, loads configuration, and executes enabled modules.

2. **Module System** (`modules/`): Modular architecture where each functionality is a separate module:
   - `system/`: System-level operations (updates, security, cleanup)
   - `dev_environments/`: Language-specific setups (Python, Node.js, Ruby, Rust, Go, Java, PHP, Flutter)
   - `applications/`: Application installations (Homebrew, GUI apps, Espanso)
   - `preferences/`: macOS and system preferences
   - `ide/`: IDE setups (VSCode, Cursor, JetBrains, Sublime, Zed)
   - `dotfiles.sh`: Dotfile management

3. **Library Functions** (`lib/`):
   - `utils.sh`: Core utility functions (version management, sudo handling, update checks)
   - `logging.sh`: Logging functions (log_info, log_success, log_warning, log_error)
   - `config_validator.sh`: Configuration validation
   - `network_utils.sh`: Network operations with retry logic

4. **Configuration System**:
   - User config stored in `~/.natiliusrc` (copied from `.natiliusrc.example` on first run)
   - Supports profiles via `--profile` flag
   - `ENABLED_MODULES` array controls which modules run
   - Module-specific variables (e.g., `PYTHONVER`, `NODEVER`)

### Key Design Patterns

1. **Error Handling**: Uses `set -e` and trap for comprehensive error handling with stack traces
2. **Logging**: All operations logged to timestamped files in `logs/` directory
3. **Idempotency**: Modules designed to be safely run multiple times
4. **Modularity**: Each module is self-contained and can be enabled/disabled independently
5. **Network Resilience**: Built-in retry logic for network operations

### Module Execution Flow

1. Script validates environment (macOS only)
2. Loads configuration from `.natiliusrc`
3. Sources utility libraries
4. Iterates through `ENABLED_MODULES` array
5. Each module is sourced and its main function executed
6. Logs all operations with timestamps

## Testing Framework

Uses BATS (Bash Automated Testing System) for testing:
- Unit tests in `tests/test_natilius.bats`
- Integration tests in `tests/integration_tests.bats`
- Config validation in `tests/test_config_validator.sh`

## Code Standards

- All shell scripts must pass shellcheck validation
- Use of shellcheck directives configured in `.shellcheckrc`
- Pre-commit hooks enforce code quality (trailing whitespace, EOF, YAML validation)
- Functions should include error handling and logging
- Network operations should use retry logic from `network_utils.sh`
