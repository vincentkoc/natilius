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

# Apps Module

log_info "Installing Mac App Store applications..."

# Ensure mas is installed
if ! command -v mas &> /dev/null; then
    if ! brew install mas; then
        log_error "Could not install mas."
        return 1
    fi
    log_success "Installed mas"
fi

# Install apps
app_failures=0
for app_id in "${APPSTORE[@]}"; do
    if mas install "$app_id"; then
        log_success "Installed App Store app with ID: $app_id"
    else
        log_error "App Store installation failed for ID: $app_id"
        app_failures=$((app_failures + 1))
    fi
done

if [ "$app_failures" -ne 0 ]; then
    log_error "$app_failures App Store installation(s) failed."
    return 1
fi
