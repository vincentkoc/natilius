#!/bin/bash

# System Update Module

log_info "Checking and installing system updates..."

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    log_info "Xcode Command Line Tools not found. Installing..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed 's/^ *//')
    sudo softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    log_success "Xcode Command Line Tools installed"
else
    log_success "Xcode Command Line Tools already installed"
fi

# Install Rosetta for Apple Silicon Macs
if [ "$(uname -m)" == "arm64" ]; then
    if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto &> /dev/null; then
        log_info "Installing Rosetta 2..."
        sudo softwareupdate --install-rosetta --agree-to-license
        log_success "Rosetta 2 installed"
    else
        log_success "Rosetta 2 already installed"
    fi
fi

# Check for macOS updates
log_info "Checking for macOS updates..."
sudo softwareupdate --install --all --verbose
log_success "System updates completed"
