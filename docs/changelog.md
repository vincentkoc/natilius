# Changelog

All notable changes to Natilius are documented here.

## [1.3.0] - 2024-01-XX

### Added
- Role-based profile templates (minimal, devops, developer)
- Profile inheritance system with `base.natiliusrc`
- Terraform provisioning script (`scripts/terraform-provision.sh`)
- Homebrew tap distribution (`brew install vincentkoc/tap/natilius`)
- Shell completions (bash, zsh, fish)
- Uninstaller script
- Comprehensive documentation site

### Changed
- Improved installer with PATH setup and completions
- Enhanced security in `directories.sh` (removed unsafe `eval`)

### Security
- Fixed potential command injection in directory expansion

---

## [1.2.0] - 2024-XX-XX

### Added
- Doctor command for system diagnostics
- Dry-run mode (`--check` flag)
- Verbose and quiet modes
- Network retry logic with exponential backoff

### Changed
- Improved error handling with stack traces
- Better macOS version detection

---

## [1.1.0] - 2024-XX-XX

### Added
- Module system with enable/disable support
- Configuration file (`.natiliusrc`)
- Logging to timestamped files
- Security hardening module (FileVault, Firewall, Gatekeeper)

### Changed
- Refactored to modular architecture
- Improved Homebrew integration

---

## [1.0.0] - 2024-XX-XX

### Added
- Initial release
- Core module system
- Homebrew installation
- Development environment setup (Python, Node, Ruby, Go, Rust)
- IDE configurations (VS Code, JetBrains)
- macOS preferences automation
- Dotfiles management

---

## Version Format

We use [Semantic Versioning](https://semver.org/):

- **MAJOR** — Breaking changes
- **MINOR** — New features (backwards compatible)
- **PATCH** — Bug fixes (backwards compatible)
