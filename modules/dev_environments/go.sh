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

# Go Development Environment Module

log_info "Setting up Go environment..."

# Check if goenv is installed; if not, install it
if ! command -v goenv &> /dev/null; then
    log_info "goenv not found. Installing goenv..."
    brew install goenv
fi

export PATH="$HOME/.goenv/bin:$PATH"
eval "$(goenv init -)"

# Check if desired Go version is installed
CURRENTVER=$(get_current_version goenv)
INSTALLED=false

while read -r version; do
    if [[ "$version" == "$GOVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(goenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    log_success "Go [$GOVER] is already installed."
    log_info "Skipping installation of Go."
    go version | tee -a "$LOGFILE"
else
    log_warning "Go [$GOVER] is not installed. Found [$CURRENTVER]."
    log_info "Installing Go..."
    goenv install "$GOVER" | tee -a "$LOGFILE"

    # Set GOVER as the global Go version
    goenv global "$GOVER"

    # Rehash goenv shims
    log_info "Rehashing goenv shims..."
    goenv rehash

    # Show the active Go version
    go version | tee -a "$LOGFILE"

    log_success "Go environment setup complete"
fi
