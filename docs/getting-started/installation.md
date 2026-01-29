# Installation

Detailed installation instructions for Natilius.

## Installation Methods

### Option 1: Homebrew (Recommended)

```bash
brew install vincentkoc/tap/natilius
```

This is the cleanest method—Homebrew manages updates and uninstallation.

### Option 2: Installer Script

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
```

The installer:

- Clones Natilius to `~/.natilius`
- Adds `natilius` command to `/usr/local/bin`
- Installs shell completions (bash/zsh)
- Creates default config at `~/.natiliusrc`

### Option 3: Manual Installation

```bash
git clone https://github.com/vincentkoc/natilius.git ~/.natilius
cd ~/.natilius
./install.sh
```

## Verify Installation

```bash
# Check natilius is available
which natilius

# Show version
natilius version

# Run diagnostics
natilius doctor
```

## Uninstallation

=== "Homebrew"

    ```bash
    brew uninstall natilius
    ```

=== "Script Install"

    ```bash
    ~/.natilius/uninstall.sh
    ```

    Or remotely:

    ```bash
    curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/uninstall.sh | bash
    ```

!!! note
    Uninstalling Natilius does **not** remove software it installed (Homebrew packages, apps, etc.). It only removes Natilius itself.

## Updating

=== "Homebrew"

    ```bash
    brew upgrade natilius
    ```

=== "Script Install"

    ```bash
    cd ~/.natilius && git pull
    ```

## Troubleshooting Installation

### "Command not found: natilius"

The command isn't in your PATH:

```bash
# Restart your shell
exec $SHELL

# Or add to PATH manually
export PATH="/usr/local/bin:$PATH"
```

### "Permission denied"

The installer can't write to `/usr/local/bin`:

```bash
sudo chown -R $(whoami) /usr/local/bin
```

### Homebrew not found (Apple Silicon)

On M1/M2/M3 Macs, Homebrew installs to `/opt/homebrew`:

```bash
# Add to ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"

# Reload
source ~/.zshrc
```
