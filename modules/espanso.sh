#!/bin/bash

# Espanso Module

log_info "Setting up Espanso..."

# Check if Espanso is installed
if ! command -v espanso &> /dev/null; then
    log_warning "Espanso is not installed. Please install Espanso and rerun this script."
    log_warning "Skipping Espanso setup..."
else
    log_success "Espanso is installed at $(which espanso)"

    # Register Espanso service
    log_info "Registering Espanso service..."
    espanso service register | tee -a "$LOGFILE"

    # Install Espanso extensions
    log_info "Installing Espanso extensions..."
    espanso install accented-words 2>/dev/null || true
    espanso install misspell-en-uk 2>/dev/null || true
    espanso install misspell-en 2>/dev/null || true
    espanso install numeronyms 2>/dev/null || true
    log_success "Installed Espanso extensions"

    # Restart Espanso service
    log_info "Restarting Espanso service..."
    espanso restart | tee -a "$LOGFILE"
    log_success "Espanso service restarted"
fi
