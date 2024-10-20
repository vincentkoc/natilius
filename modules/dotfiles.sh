#!/bin/bash

# Dotfiles Module

log_info "Setting up dotfiles..."

# Install Mackup if not installed
if ! command -v mackup &> /dev/null; then
    brew install mackup
fi

# Copy Mackup config if not present
if [ ! -f "$HOME/.mackup.cfg" ]; then
    cat << EOF > "$HOME/.mackup.cfg"
[storage]
engine = icloud
directory = dotfiles
EOF
    log_success "Created .mackup.cfg"
fi

# Restore dotfiles
mackup restore -f
log_success "Dotfiles restored with Mackup"
