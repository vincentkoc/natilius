<p align="center">
  <img src="docs/assets/artwork-icon.png" alt="Natilius" width="100"/>
</p>

<h1 align="center">Natilius</h1>

<p align="center">
  <strong>Your Mac, ready to code. One command.</strong>
</p>

<p align="center">
  <a href="https://github.com/vincentkoc/natilius/actions/workflows/ci.yml"><img src="https://github.com/vincentkoc/natilius/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/vincentkoc/natilius/releases"><img src="https://img.shields.io/github/v/release/vincentkoc/natilius?include_prereleases" alt="Release"></a>
  <a href="https://github.com/vincentkoc/natilius/blob/main/LICENSE"><img src="https://img.shields.io/github/license/vincentkoc/natilius" alt="License"></a>
  <a href="https://github.com/vincentkoc/natilius/stargazers"><img src="https://img.shields.io/github/stars/vincentkoc/natilius" alt="Stars"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-blue" alt="macOS">
</p>

<p align="center">
  <a href="https://vincentkoc.github.io/natilius">Documentation</a> ·
  <a href="https://vincentkoc.github.io/natilius/getting-started/quickstart/">Quick Start</a> ·
  <a href="https://github.com/vincentkoc/natilius/discussions">Community</a>
</p>

<p align="center">
  <img src="docs/assets/demo.gif" alt="Natilius Demo" width="700"/>
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

- 🍺 **Homebrew** — 100+ curated packages and casks
- 🐍 **Languages** — Python, Node, Ruby, Go, Rust, Java (version-managed)
- 🐳 **DevOps** — Docker, Kubernetes, Terraform, cloud CLIs
- 🔧 **IDEs** — VS Code, Cursor, JetBrains, Sublime, Zed
- 🔒 **Security** — FileVault, Firewall, Gatekeeper, privacy settings
- ⚙️ **Profiles** — Minimal, DevOps, Developer, or build your own

## Commands

```bash
natilius init                    # Interactive setup wizard
natilius setup                   # Run full setup
natilius setup --check           # Preview changes (dry run)
natilius doctor                  # Check system status
natilius --profile devops setup  # Use a specific profile
```

## Documentation

Profiles, configuration, modules, Terraform integration, enterprise/MDM setup, and more.

**📖 [Read the docs →](https://vincentkoc.github.io/natilius)**

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Found a bug?** [Open an issue](https://github.com/vincentkoc/natilius/issues) · **Questions?** [Start a discussion](https://github.com/vincentkoc/natilius/discussions) · **Like it?** [Star us ⭐](https://github.com/vincentkoc/natilius)

<p align="center">
  <sub>Made with care by <a href="https://github.com/vincentkoc">Vincent Koc</a> · <a href="LICENSE">GPL-3.0</a></sub>
</p>
