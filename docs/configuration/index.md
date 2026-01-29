# Configuration

Natilius is configured via `~/.natiliusrc`—a bash script that sets variables controlling what gets installed.

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.natiliusrc` | Primary configuration |
| `~/.natiliusrc.{name}` | Named profiles (e.g., `~/.natiliusrc.devops`) |
| `~/.natilius/profiles/` | Built-in profile templates |

## Creating Your Config

1. **Copy the example:**
   ```bash
   cp ~/.natilius/.natiliusrc.example ~/.natiliusrc
   ```

2. **Or start from a profile:**
   ```bash
   cp ~/.natilius/profiles/devops.natiliusrc ~/.natiliusrc
   ```

3. **Edit to customize:**
   ```bash
   nano ~/.natiliusrc
   ```

## Key Sections

### Enabled Modules

Controls which setup modules run:

```bash
ENABLED_MODULES=(
    "system/system_update"
    "applications/homebrew"
    "dev_environments/python"
    "ide/ide_setup"
    "system/cleanup"
)
```

See [Modules](modules.md) for the full list.

### Language Versions

Pin specific versions:

```bash
PYTHONVER="3.11.0"
NODEVER="20.10.0"
RUBYVER="3.2.0"
GOVER="1.21.0"
JDKVER="21"
```

### IDE Selection

```bash
INSTALL_VSCODE=true
INSTALL_CURSOR=false
INSTALL_JETBRAINS=true
INSTALL_SUBLIME=false
INSTALL_ZED=false
```

### Homebrew Packages

```bash
# CLI tools
BREWPACKAGES=(
    "git"
    "jq"
    "fzf"
    "kubectl"
)

# GUI apps
BREWCASKS=(
    "visual-studio-code"
    "docker"
    "slack"
)
```

See [Variables Reference](variables.md) for all options.

## Using Profiles

Use the `--profile` flag to load a named config:

```bash
natilius --profile devops
```

This loads `~/.natiliusrc.devops` instead of `~/.natiliusrc`.

See [Profiles](profiles.md) for details.

## Validating Config

Check your config for errors:

```bash
# Syntax check
bash -n ~/.natiliusrc

# Dry run
natilius --check
```
