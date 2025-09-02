#!/bin/bash

setup_zed() {
    if ! command -v zed &> /dev/null; then
        log_info "Zed not found. Installing..."
        brew install --cask zed
    fi

    if command -v zed &> /dev/null; then
        log_info "Setting up Zed..."
        # Zed doesn't have a CLI for extension management yet, so we'll just log a message
        log_info "Zed detected. Please manually install extensions for: ${ENABLED_DEV_ENVS[*]}"
        log_success "Zed setup completed"
    else
        log_warning "Failed to install Zed"
    fi
}
