# Team Setup

Standardize developer environments across your team.

## Why Standardize?

- **Faster onboarding** — New hires productive in hours
- **Fewer issues** — Everyone has the same tools
- **Security compliance** — Enforce settings team-wide

## Create a Team Profile

```bash
# team-backend.natiliusrc

source "$HOME/.natiliusrc.base"

ENABLED_MODULES=(
    "system/system_update"
    "system/security"
    "applications/homebrew"
    "dev_environments/python"
    "dev_environments/node"
    "ide/ide_setup"
    "system/cleanup"
)

# Pin versions
PYTHONVER="3.11.0"
NODEVER="20.10.0"

# Team tools
BREWPACKAGES+=(
    "mycompany/tap/mycompany-cli"
    "pre-commit"
)
```

## Distribution Options

### Dotfiles Repo

```
dotfiles/
├── natilius/
│   ├── backend.natiliusrc
│   ├── frontend.natiliusrc
│   └── devops.natiliusrc
└── install.sh
```

### Internal Script

```bash
#!/bin/bash
# https://setup.mycompany.com/mac

curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true bash
curl -fsSL https://setup.mycompany.com/team.natiliusrc -o ~/.natiliusrc
~/.natilius/natilius.sh setup
```

## Onboarding Docs

Add to your wiki:

```markdown
# Mac Setup

1. Open Terminal
2. Run: `curl -fsSL https://setup.mycompany.com/mac | bash`
3. Enter password when prompted
4. Wait ~15 minutes

Questions? Ask in #dev-support
```
