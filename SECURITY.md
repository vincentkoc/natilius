# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in Natilius, please report it responsibly.

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Email security concerns to: **security@vincentkoc.com**
3. Or use [GitHub Security Advisories](https://github.com/vincentkoc/natilius/security/advisories/new)

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

| Action | Timeframe |
|--------|-----------|
| Initial response | 48 hours |
| Vulnerability assessment | 1 week |
| Fix development | 2-4 weeks |
| Public disclosure | After fix is released |

## Security Measures in Natilius

### What Natilius Does

- **FileVault** — Enables full-disk encryption
- **Firewall** — Enables application firewall with stealth mode
- **Gatekeeper** — Ensures only signed apps can run
- **Secure Keyboard Entry** — Protects against keyloggers in Terminal
- **Guest Account** — Disables guest access
- **Screen Lock** — Requires password immediately after sleep

### What We Don't Do

- Store or transmit credentials
- Collect telemetry or analytics
- Phone home (except optional update checks)
- Modify system files outside of documented preferences

## Best Practices for Users

1. **Review before running** — Read `~/.natiliusrc` before executing
2. **Use dry-run mode** — `natilius --check` to preview changes
3. **Keep backups** — Time Machine or equivalent before major changes
4. **Pin versions** — Use specific version tags, not `main` branch in automation
5. **Audit packages** — Review `BREWPACKAGES` and `BREWCASKS` in your config

## Code Security

- All shell scripts pass [ShellCheck](https://www.shellcheck.net/) analysis
- No use of `eval` with user input (security fix applied)
- Network operations use HTTPS
- Optional checksum verification for downloads

## Dependency Security

Natilius installs software from:
- **Homebrew** — Community-maintained, signed packages
- **Mac App Store** — Apple-verified apps
- **Official sources** — Language version managers (pyenv, nodenv, etc.)

We recommend reviewing installed packages periodically:
```bash
brew list
mas list
```

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who report valid vulnerabilities (with permission).
