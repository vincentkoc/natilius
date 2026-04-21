# Comparison

How Natilius compares to other Mac setup tools.

---

## Quick Comparison

| Feature             | Natilius | thoughtbot/laptop | mac-setup | strap   |
| ------------------- | -------- | ----------------- | --------- | ------- |
| One-command install | **Yes**  | **Yes**           | **Yes**   | **Yes** |
| Modular design      | **Yes**  | No                | Partial   | No      |
| Profile support     | **Yes**  | No                | No        | No      |
| Idempotent          | **Yes**  | **Yes**           | Partial   | **Yes** |
| Dry-run mode        | **Yes**  | No                | No        | No      |
| Terraform ready     | **Yes**  | No                | No        | No      |
| Active maintenance  | **Yes**  | **Yes**           | Limited   | **Yes** |
| Security hardening  | **Yes**  | No                | No        | No      |
| Custom config file  | **Yes**  | Limited           | **Yes**   | **Yes** |
| IDE setup           | **Yes**  | No                | Partial   | No      |
| macOS preferences   | **Yes**  | No                | **Yes**   | No      |

---

## Detailed Comparison

### thoughtbot/laptop

[github.com/thoughtbot/laptop](https://github.com/thoughtbot/laptop)

**Pros:**

- Well-maintained by thoughtbot
- Simple, focused approach
- Good for Ruby/Rails developers

**Cons:**

- No modular system
- Limited customization
- No profile support
- Opinionated tool choices

**Best for:** Rails developers who want a quick, opinionated setup.

---

### mac-setup

[github.com/sb2nov/mac-setup](https://github.com/sb2nov/mac-setup)

**Pros:**

- Comprehensive documentation
- Wide tool coverage

**Cons:**

- More of a guide than automation
- Requires manual steps
- Less actively maintained

**Best for:** Learning what tools to install manually.

---

### strap

[github.com/MikeMcQuaid/strap](https://github.com/MikeMcQuaid/strap)

**Pros:**

- GitHub-integrated
- Works with Brewfile
- Good for teams

**Cons:**

- Requires GitHub access
- Limited to Homebrew
- No system preferences
- No IDE configuration

**Best for:** Teams already using Brewfile.

---

### dotfiles managers

Tools like [chezmoi](https://chezmoi.io/), [GNU Stow](https://www.gnu.org/software/stow/), [yadm](https://yadm.io/)

**Pros:**

- Excellent for config file management
- Cross-platform
- Version controlled

**Cons:**

- Don't install software
- Require separate tool installation
- Steeper learning curve

**Best for:** Managing dotfiles after initial setup. Works great alongside Natilius.

---

### Ansible

[ansible.com](https://www.ansible.com/)

**Pros:**

- Industry standard
- Cross-platform
- Extremely powerful
- Great for fleets

**Cons:**

- Requires Python
- Complex YAML syntax
- Overkill for single machine
- Slower execution

**Best for:** Managing many machines or mixed OS environments.

---

## Why Natilius?

Natilius combines the best aspects:

1. **Simple like laptop** — One command to run
2. **Flexible like Ansible** — Modular, configurable
3. **Fast like shell** — Native bash, no dependencies
4. **Modern features** — Profiles, dry-run, Terraform support

### Use Natilius when you want:

- Quick setup for new Macs
- Role-based configurations (DevOps vs Frontend vs Backend)
- Terraform/automation integration
- Security hardening included
- macOS preferences automation
- IDE configuration

### Consider alternatives when you need:

- **Cross-platform** — Use Ansible or chezmoi
- **Just dotfiles** — Use chezmoi or stow
- **Just Homebrew** — Use Brewfile with strap
- **Enterprise MDM** — Use Jamf/Kandji (Natilius can complement these)

---

## Using Together

Natilius works great with other tools:

```bash
# 1. Natilius installs tools
natilius setup

# 2. Chezmoi manages dotfiles
chezmoi init --apply your-username

# 3. Mackup restores app preferences
mackup restore
```

This separation of concerns gives you the best of all worlds.
