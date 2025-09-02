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

# System Update Module

log_info "Checking and installing system updates..."

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    log_info "Xcode Command Line Tools not found. Installing..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep ".*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed 's/^ *//')
    if [ -z "$PROD" ]; then
        log_error "Failed to find Xcode Command Line Tools in available updates."
        rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        exit 1
    fi
    if ! sudo softwareupdate -i "$PROD" --verbose; then
        log_error "Failed to install Xcode Command Line Tools."
        rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        exit 1
    fi
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    log_success "Xcode Command Line Tools installed"
else
    log_success "Xcode Command Line Tools already installed"
fi

# Install Rosetta for Apple Silicon Macs
if [ "$(uname -m)" == "arm64" ]; then
    if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
        log_info "Installing Rosetta 2..."
        if ! sudo softwareupdate --install-rosetta --agree-to-license; then
            log_error "Failed to install Rosetta 2."
            exit 1
        fi
        log_success "Rosetta 2 installed"
    else
        log_success "Rosetta 2 already installed"
    fi
fi

# Function to check if a reboot is required
check_reboot_required() {
    if [ -f /var/db/.AppleSetupDone ]; then
        REBOOT_REQUIRED=$(sudo /usr/sbin/softwareupdate --history | grep "restart")
        if [ -n "$REBOOT_REQUIRED" ]; then
            log_warning "A reboot is required to complete the installation of updates."
            return 0
        fi
    fi
    return 1
}

# Check for macOS updates
log_info "Checking for macOS updates..."
if ! sudo softwareupdate --install --all --verbose; then
    log_error "Failed to install some updates. Please check the logs for details."
else
    log_success "System updates completed"
fi

# Check if a reboot is required
if check_reboot_required; then
    read -p "Do you want to restart now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restarting the system..."
        sudo shutdown -r now
    else
        log_warning "Please remember to restart your system to complete the update process."
    fi
fi
