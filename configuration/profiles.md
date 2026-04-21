# Profiles

Profiles are pre-built configurations for common use cases.

## Available Profiles

| Profile     | Best For               | Includes                                              |
| ----------- | ---------------------- | ----------------------------------------------------- |
| `minimal`   | Quick onboarding       | Git, Homebrew, VS Code, essential CLI tools           |
| `devops`    | Platform/SRE engineers | Kubernetes, Terraform, Docker, cloud CLIs, Python, Go |
| `developer` | Full-stack developers  | Multiple languages, IDEs, databases, all dev tools    |
| `clawdbot`  | AI agent machines      | Node.js 24, moltbot, Chrome, 1Password, Tailscale     |

See [Clawdbot Guide](../guides/clawdbot.md) for detailed setup instructions for AI agent provisioning.

## Using Profiles

### Direct Usage

```bash
natilius --profile devops
```

This loads `~/.natiliusrc.devops` (or the built-in profile if it doesn't exist).

### Copy and Customize

```bash
# Copy profile to your config
cp ~/.natilius/profiles/devops.natiliusrc ~/.natiliusrc

# Edit to customize
nano ~/.natiliusrc

# Run setup
natilius setup
```

### Named Profiles

Create named profiles for different contexts:

```bash
# Work setup
cp ~/.natilius/profiles/devops.natiliusrc ~/.natiliusrc.work

# Personal setup
cp ~/.natilius/profiles/developer.natiliusrc ~/.natiliusrc.personal

# Use them
natilius --profile work
natilius --profile personal
```

## Profile Inheritance

Create profiles that extend a base configuration:

```bash
# ~/.natiliusrc.myteam

# Inherit from base
source "$HOME/.natiliusrc.base"

# Add team-specific modules
ENABLED_MODULES+=("dev_environments/rust")

# Add team tools
BREWPACKAGES+=("mycompany-cli")

# Override versions
PYTHONVER="3.12.0"
```

## Creating Custom Profiles

1. **Start from a template:**

   ```bash
   cp ~/.natilius/profiles/devops.natiliusrc ~/.natiliusrc.myprofile
   ```

2. **Customize:** Edit modules, packages, and settings

3. **Test:**

   ```bash
   natilius --profile myprofile --check
   ```

4. **Share:** Commit to your dotfiles repo
