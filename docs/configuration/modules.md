# Modules

Modules are self-contained scripts that handle specific parts of your setup. Enable them in `ENABLED_MODULES`.

## System Modules

| Module                 | Description                                        |
| ---------------------- | -------------------------------------------------- |
| `system/system_update` | macOS updates, Xcode CLI tools, Rosetta 2          |
| `system/directories`   | Create custom directories, Time Machine exclusions |
| `system/security`      | FileVault, Firewall, Gatekeeper hardening          |
| `system/cleanup`       | Clear caches, restart Dock/Finder                  |

## Application Modules

| Module                  | Description                        |
| ----------------------- | ---------------------------------- |
| `applications/homebrew` | Homebrew taps, packages, and casks |
| `applications/apps`     | Mac App Store apps via `mas`       |
| `applications/espanso`  | Text expansion tool                |

## Development Environments

| Module                     | Version Variable  |
| -------------------------- | ----------------- |
| `dev_environments/python`  | `PYTHONVER`       |
| `dev_environments/node`    | `NODEVER`         |
| `dev_environments/ruby`    | `RUBYVER`         |
| `dev_environments/go`      | `GOVER`           |
| `dev_environments/rust`    | (stable)          |
| `dev_environments/java`    | `JDKVER`          |
| `dev_environments/php`     | `PHPVER`          |
| `dev_environments/flutter` | `FLUTTER_CHANNEL` |

## IDE Modules

| Module                | Config Flag               |
| --------------------- | ------------------------- |
| `ide/ide_setup`       | Orchestrates IDE installs |
| `ide/vscode_setup`    | `INSTALL_VSCODE`          |
| `ide/jetbrains_setup` | `INSTALL_JETBRAINS`       |
| `ide/sublime_setup`   | `INSTALL_SUBLIME`         |
| `ide/zed_setup`       | `INSTALL_ZED`             |

## Preference Modules

| Module                           | Description                     |
| -------------------------------- | ------------------------------- |
| `preferences/mac_preferences`    | Finder, Dock, keyboard settings |
| `preferences/system_preferences` | System-level macOS preferences  |

## Other

| Module     | Description                       |
| ---------- | --------------------------------- |
| `dotfiles` | Dotfile backup/restore via Mackup |

## Recommended Order

```bash
ENABLED_MODULES=(
    # 1. System foundation
    "system/system_update"
    "system/directories"
    "system/security"

    # 2. Package management
    "applications/homebrew"
    "applications/apps"

    # 3. Development environments
    "dev_environments/python"
    "dev_environments/node"

    # 4. IDEs
    "ide/ide_setup"

    # 5. Preferences and cleanup
    "preferences/mac_preferences"
    "dotfiles"
    "system/cleanup"
)
```

!!! warning
Run `system/system_update` first (installs Xcode CLI tools) and `system/cleanup` last.

## Listing Modules

```bash
natilius list-modules
```

## Disabling Modules

Comment out or remove modules you don't need:

```bash
ENABLED_MODULES=(
    "system/system_update"
    "applications/homebrew"
    # "dev_environments/ruby"  # Disabled
    "dev_environments/python"
)
```
