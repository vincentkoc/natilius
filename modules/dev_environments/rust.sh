#!/bin/bash

# Rust Development Environment Module

log_info "Setting up Rust environment..."

# Install rustup if not installed
if ! command -v rustup &> /dev/null; then
    brew install rustup-init
    rustup-init -y
fi

export PATH="$HOME/.cargo/bin:$PATH"

# Update Rust and install components
rustup update
rustup component add rustfmt
rustup component add clippy

log_success "Rust environment setup complete"
