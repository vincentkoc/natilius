#!/bin/bash

# Apps Module

log_info "Installing Mac App Store applications..."

# Ensure mas is installed
if ! command -v mas &> /dev/null; then
    brew install mas
    log_success "Installed mas"
fi

# Install apps
for app_id in "${APPSTORE[@]}"; do
    mas install "$app_id" || true
    log_success "Installed App Store app with ID: $app_id"
done
