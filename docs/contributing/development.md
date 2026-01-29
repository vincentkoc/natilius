# Development Setup

## Prerequisites

- macOS
- Git
- Homebrew

## Setup

```bash
git clone https://github.com/YOUR_USERNAME/natilius.git
cd natilius
make dev-setup
```

This installs bats-core, shellcheck, and pre-commit.

## Project Structure

```
natilius/
├── natilius.sh          # Main script
├── install.sh           # Installer
├── lib/                 # Libraries
├── modules/             # Feature modules
├── profiles/            # Config profiles
├── tests/               # Tests
└── docs/                # Documentation
```

## Workflow

1. Create branch: `git checkout -b feature/x`
2. Make changes
3. Test: `make test && make lint`
4. Commit: `git commit -m "feat: add x"`
5. Push and PR

## Testing

```bash
make test        # Unit tests
make test-all    # All tests
make lint        # ShellCheck
make precommit   # Pre-commit hooks
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make dev-setup` | Install dev deps |
| `make test` | Unit tests |
| `make test-all` | All tests |
| `make lint` | ShellCheck |
| `make precommit` | Pre-commit |
| `make coverage` | Coverage report |
