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
    brew install mas
    log_success "Installed mas"
fi

# Install apps
for app_id in "${APPSTORE[@]}"; do
    mas install "$app_id" || true
    log_success "Installed App Store app with ID: $app_id"
done
