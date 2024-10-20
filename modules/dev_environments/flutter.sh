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

# Flutter Development Environment Module

log_info "Setting up Flutter environment..."

# Check if Flutter is installed; if not, install it
if ! command -v flutter &> /dev/null; then
    log_info "Flutter not found. Installing Flutter..."
    brew install --cask flutter
    log_success "Flutter installed"
else
    log_success "Flutter is already installed."
    flutter --version | tee -a "$LOGFILE"
fi

# Enable beta channel if specified
if [ "$FLUTTER_CHANNEL" = "beta" ]; then
    log_info "Switching to Flutter beta channel..."
    flutter channel beta
    flutter upgrade
fi

# Accept Android licenses
if command -v sdkmanager &> /dev/null; then
    log_info "Accepting Android SDK licenses..."
    yes | sdkmanager --licenses
    log_success "Android SDK licenses accepted"
fi

# Run flutter doctor
log_info "Running flutter doctor..."
flutter doctor | tee -a "$LOGFILE"

log_success "Flutter environment setup complete"
