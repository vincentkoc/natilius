#!/bin/bash

# Node.js Development Environment Module

log_info "Setting up Node.js environment..."

# Install nodenv if not installed
if ! command -v nodenv &> /dev/null; then
    brew install nodenv
fi

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# Install Node.js version
nodenv install -s "$NODEVER"
nodenv global "$NODEVER"
log_success "Set global Node.js version to $NODEVER"

# Install global npm packages
npm install -g npm
npm install -g yarn

log_success "Node.js environment setup complete"
