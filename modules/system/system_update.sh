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
