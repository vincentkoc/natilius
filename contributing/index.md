# Contributing

Thank you for your interest in contributing!

## Quick Start

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/natilius.git
cd natilius

# Setup
make dev-setup

# Create branch
git checkout -b feature/your-feature

# Make changes, test
make test && make lint

# Submit PR
git push origin feature/your-feature
```

## Ways to Contribute

- **Report Bugs** — [GitHub Issues](https://github.com/vincentkoc/natilius/issues)
- **Suggest Features** — [GitHub Discussions](https://github.com/vincentkoc/natilius/discussions)
- **Improve Docs** — Documentation PRs welcome
- **Add Modules** — See [Creating Modules](creating-modules.md)

## Guidelines

### Code Standards

- Bash 3.2+ (macOS compatibility)
- Pass ShellCheck: `make lint`
- Pass tests: `make test`
- Quote variables: `"$variable"`

### Commit Messages

Use [Conventional Commits](https://conventionalcommits.org/):

```
feat(python): add Python 3.12 support
fix(homebrew): handle missing taps
docs(readme): update installation
```

### Pull Requests

- One feature per PR
- Include tests
- Update docs if needed
- Reference related issues

## Code of Conduct

Be respectful. See [CODE_OF_CONDUCT.md](https://github.com/vincentkoc/natilius/blob/main/CODE_OF_CONDUCT.md).
