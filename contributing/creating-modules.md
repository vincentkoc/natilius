# Creating Modules

Modules are self-contained scripts for specific setup tasks.

## Template

```bash
#!/bin/bash

# natilius - Module Name
# Brief description
#
# Copyright (C) 2024 Vincent Koc
# License: GPL-3.0-or-later

# MODULE: category/module_name
# Dependencies: homebrew
# Config: MY_VERSION

log_info "Starting module_name setup..."

# Check prerequisites
if ! command -v required_tool &> /dev/null; then
    log_warning "required_tool not found, skipping"
    return 0
fi

# Idempotent check
if command -v mytool &> /dev/null; then
    log_success "Already installed, skipping"
    return 0
fi

# Install
log_info "Installing..."
brew install mytool

log_success "module_name setup complete"
```

## Guidelines

1. **Be idempotent** — Safe to run multiple times
2. **Check prerequisites** — Verify dependencies
3. **Use logging** — `log_info`, `log_success`, `log_warning`, `log_error`
4. **Handle errors** — Don't crash the setup
5. **Document** — Dependencies and config in header

## Adding Your Module

1. Create: `modules/category/my_module.sh`
2. Add to `natilius.sh` module list
3. Document in `docs/configuration/modules.md`
4. Add tests

## Example

```bash
#!/bin/bash

# natilius - MyTool Setup

log_info "Setting up MyTool..."

VERSION="${MYTOOL_VERSION:-latest}"

if command -v mytool &> /dev/null; then
    log_success "MyTool already installed"
    return 0
fi

brew install mytool || {
    log_error "Failed to install MyTool"
    return 1
}

log_success "MyTool setup complete"
```
