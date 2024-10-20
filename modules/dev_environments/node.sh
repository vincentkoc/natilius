#!/bin/bash

# Node.js Development Environment Module

log_info "Setting up Node.js environment..."

# Check if nodenv is installed; if not, install it
if ! command -v nodenv &> /dev/null; then
    log_info "nodenv not found. Installing nodenv..."
    brew install nodenv
fi

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# Check if desired Node.js version is installed
CURRENTVER=$(get_current_version nodenv)
INSTALLED=false

while read -r version; do
    if [[ "$version" == "$NODEVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(nodenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    log_success "Node.js [$NODEVER] is already installed."
    log_info "Skipping installation of Node.js."
    node --version | tee -a "$LOGFILE"
    which node | tee -a "$LOGFILE"
else
    log_warning "Node.js [$NODEVER] is not installed. Found [$CURRENTVER]."
    log_info "Installing Node.js..."
    nodenv install "$NODEVER" | tee -a "$LOGFILE"

    # Set NODEVER as the local and global Node.js version
    nodenv global "$NODEVER"
    nodenv local "$NODEVER"

    # If there are other versions installed, set the highest one as the global version
    HIGHESTVER=$(get_highest_version nodenv)
    if [ "$HIGHESTVER" != "$NODEVER" ]; then
        nodenv global "$HIGHESTVER"
        log_info "Set highest Node.js version [$HIGHESTVER] as global version."
    fi

    # Show the active Node.js version
    node --version | tee -a "$LOGFILE"

    # Install global Node.js packages
    log_info "Installing global Node.js packages..."
    npm i -g "${GLOBAL_NODE_PACKAGES[@]}" | tee -a "$LOGFILE"
    log_success "Installed global Node.js packages"

    # Rehash nodenv shims
    log_info "Rehashing nodenv shims..."
    nodenv rehash

    # Verify npm and yarn paths
    log_info "Verifying npm and yarn paths..."
    nodenv which npm
    nodenv which yarn

    log_success "Node.js environment setup complete"
fi
