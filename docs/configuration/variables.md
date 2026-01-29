# Variables Reference

Complete reference for all `~/.natiliusrc` configuration variables.

## Core Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ENABLED_MODULES` | array | `()` | Modules to run |
| `COUNTRYCODE` | string | `"us"` | Country code |
| `SKIP_UPDATE_CHECK` | bool | `false` | Skip version check |

## Language Versions

| Variable | Type | Example | Description |
|----------|------|---------|-------------|
| `PYTHONVER` | string | `"3.11.0"` | Python version |
| `NODEVER` | string | `"20.10.0"` | Node.js version |
| `RUBYVER` | string | `"3.2.0"` | Ruby version |
| `GOVER` | string | `"1.21.0"` | Go version |
| `JDKVER` | string | `"21"` | Java version |
| `PHPVER` | string | `"8.3.0"` | PHP version |
| `FLUTTER_CHANNEL` | string | `"stable"` | Flutter channel |

!!! note
    Version strings must be full semantic versions: `"3.11.0"` not `"3.11"`.

## IDE Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `INSTALL_VSCODE` | bool | `true` | VS Code |
| `INSTALL_CURSOR` | bool | `false` | Cursor editor |
| `INSTALL_JETBRAINS` | bool | `false` | JetBrains IDEs |
| `INSTALL_SUBLIME` | bool | `false` | Sublime Text |
| `INSTALL_ZED` | bool | `false` | Zed editor |

## Directories

### DIRS

```bash
DIRS=(
    "~/.config"
    "~/GIT"
    "~/Projects"
)
```

### DIRSTOEXCLUDEFROMTIMEMACHINE

```bash
DIRSTOEXCLUDEFROMTIMEMACHINE=(
    "~/GIT"
    "~/.npm"
    "~/.cargo"
)
```

## Homebrew

### BREWTAPS

```bash
BREWTAPS=(
    "homebrew/cask"
    "github/gh"
)
```

### BREWPACKAGES

```bash
BREWPACKAGES=(
    "git"
    "jq"
    "kubectl"
)
```

### BREWCASKS

```bash
BREWCASKS=(
    "visual-studio-code"
    "docker"
    "slack"
)
```

## Mac App Store

```bash
APPSTORE=(
    "441258766"   # Magnet
    "937984704"   # Amphetamine
)
```

!!! tip
    Find app IDs with `mas search "app name"`.

## Global Packages

### GLOBAL_PYTHON_PACKAGES

```bash
GLOBAL_PYTHON_PACKAGES=(
    "pip"
    "virtualenv"
    "black"
)
```

### GLOBAL_NODE_PACKAGES

```bash
GLOBAL_NODE_PACKAGES=(
    "eslint"
    "prettier"
    "typescript"
)
```

## Environment Variables

Set at runtime:

| Variable | Default | Description |
|----------|---------|-------------|
| `NATILIUS_HOME` | `~/.natilius` | Installation directory |
| `SKIP_SUDO` | `false` | Skip sudo validation |
| `DRY_RUN` | `false` | Preview mode |
| `VERBOSE_MODE` | `false` | Detailed output |
| `QUIET_MODE` | `false` | Minimal output |
| `NONINTERACTIVE` | `false` | No prompts |

```bash
SKIP_SUDO=true DRY_RUN=true natilius setup
```
