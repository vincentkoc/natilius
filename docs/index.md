---
extra_css:
  - assets/css/home.css
---

<p align="center">
  <img src="assets/artwork-icon.png" alt="Natilius" width="100"/>
</p>

<h1 align="center">Natilius</h1>

<p align="center">
  <strong>Your Mac, ready to code. One command.</strong>
</p>

<p align="center">
  <a href="https://github.com/vincentkoc/natilius/releases"><img src="https://img.shields.io/github/v/release/vincentkoc/natilius?style=flat-square" alt="Version"></a>
  <a href="https://github.com/vincentkoc/natilius/blob/main/LICENSE"><img src="https://img.shields.io/github/license/vincentkoc/natilius?style=flat-square" alt="License"></a>
  <a href="https://github.com/vincentkoc/natilius/stargazers"><img src="https://img.shields.io/github/stars/vincentkoc/natilius?style=flat-square" alt="Stars"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-blue?style=flat-square" alt="macOS">
</p>

<p align="center">
  <img src="assets/demo.gif" alt="Natilius Demo" width="700"/>
</p>

## Install

```bash
brew install vincentkoc/tap/natilius
```

Then run:

```bash
natilius init      # Choose your profile
natilius setup     # Install everything
```

<details>
<summary>Alternative: Install via script</summary>

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh)"
```

</details>

<details>
<summary>Alternative: Install from source</summary>

```bash
git clone https://github.com/vincentkoc/natilius.git ~/.natilius
cd ~/.natilius && make install
```

</details>

## Why Natilius?

New Mac? New job? You know the drill — Homebrew, Xcode CLI tools, Python, Node, Docker, VS Code, a dozen preference tweaks... it takes hours.

**Natilius handles all of it.** One command installs your entire dev environment. It's idempotent (safe to run repeatedly), respects MDM policies, and works for solo devs or entire teams.

## What You Get

- **Homebrew** — 100+ curated packages and casks
- **Languages** — Python, Node, Ruby, Go, Rust, Java (version-managed)
- **DevOps** — Docker, Kubernetes, Terraform, cloud CLIs
- **IDEs** — VS Code, Cursor, JetBrains, Sublime, Zed
- **Security** — FileVault, Firewall, Gatekeeper, privacy settings
- **Profiles** — Minimal, DevOps, Developer, Clawdbot, or build your own

## Commands

```bash
natilius init                    # Interactive setup wizard
natilius setup                   # Run full setup
natilius setup --check           # Preview changes (dry run)
natilius doctor                  # Check system status
natilius --profile devops setup  # Use a specific profile
```

## How It Works

```
natilius setup → Load Config → Profile? → Run Modules → Done!
                                  ↓
                         System | Apps | Dev Envs | IDEs
```

## Next Steps

- [Quick Start Guide](getting-started/quickstart.md) — Detailed setup walkthrough
- [Configuration](configuration/index.md) — Customize your setup
- [Profiles](configuration/profiles.md) — Role-based configurations
- [Terraform Provisioning](guides/terraform.md) — Remote Mac automation
- [Clawdbot/AI Agents](guides/clawdbot.md) — moltbot setup with Mackup restore
- [Enterprise & MDM](enterprise.md) — Jamf, JumpCloud, Intune integration
- [FAQ](faq.md) — Common questions
