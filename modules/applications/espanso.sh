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
