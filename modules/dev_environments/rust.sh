#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment
#
# Copyright (C) 2023 Vincent Koc (@vincent_koc)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#

# Rust Development Environment Module

log_info "Setting up Rust environment..."

# Function to check Rust installation and emulation status
check_rust_status() {
    local arch
    arch=$(uname -m)
    local rust_arch=""

    if command -v rustup &> /dev/null; then
        if command -v rustc &> /dev/null; then
            rust_arch=$(rustc -vV | grep host | cut -d' ' -f2)
        else
            echo "incomplete"
            return
        fi
    else
        echo "not_installed"
        return
    fi

    if [[ $arch == "arm64" ]]; then
        if [[ $rust_arch == "x86_64"* ]]; then
            echo "emulated"
        elif [[ $rust_arch == "aarch64"* ]]; then
            echo "native"
        else
            echo "unknown"
        fi
    else
        echo "installed"
    fi
}

# Function to uninstall Rust and Rustup
uninstall_rust() {
    if command -v brew &> /dev/null && brew list | grep -q "^rustup$"; then
        log_info "Uninstalling Rustup via Homebrew..."
        brew uninstall rustup
    elif command -v rustup &> /dev/null; then
        log_warning "Rustup is installed, but not via Homebrew. Manual uninstallation may be required."
        log_info "You can try running: rustup self uninstall"
        log_info "If that doesn't work, you may need to remove Rust manually."
    fi

    # Remove any leftover Rust-related directories
    log_info "Removing Rust-related directories..."
    rm -rf "$HOME/.rustup" "$HOME/.cargo"
}

# Function to install Rust
install_rust() {
    log_info "Installing Rust for ARM64..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

# Check Rust status
rust_status=$(check_rust_status)

case $rust_status in
    "emulated" | "incomplete")
        log_warning "Rust is either installed under x86_64 emulation or incomplete on this ARM64 machine."
        log_info "For optimal performance and functionality, we recommend reinstalling Rust natively for ARM64."
        read -p "Would you like to uninstall the current Rust installation and reinstall for ARM64? (Recommended) (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            uninstall_rust
            install_rust
        else
            log_info "Proceeding with current Rust installation. Note that it may not function correctly."
        fi
        ;;
    "native" | "installed")
        log_info "Rust is already installed. Proceeding with update."
        ;;
    "not_installed")
        log_info "Rust is not installed. Proceeding with installation."
        install_rust
        ;;
    "unknown")
        log_warning "Unable to determine Rust installation status. Proceeding with caution."
        ;;
esac

# Ensure Rustup is available
if ! command -v rustup &> /dev/null; then
    log_error "Rustup not found after installation attempt. Please check your system and try again."
    return 1
fi

# Update Rust
log_info "Updating Rust..."
if ! rustup update; then
    log_warning "Failed to update Rust. You may need to reinstall manually."
    return 1
fi

# Ensure a default toolchain is set
if ! rustup default &> /dev/null; then
    log_info "No default Rust toolchain set. Setting up stable toolchain..."
    rustup default stable
fi

# Now proceed with component installation
log_info "Installing Rust components..."
rustup component add rustfmt
rustup component add clippy

log_success "Rust environment setup complete"
