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

# Directories Module

log_info "Setting up custom directories..."

# Create Directories
for dir in "${DIRS[@]}"; do
    dir_expanded=$(eval echo "$dir")
    if [ ! -d "$dir_expanded" ]; then
        mkdir -p "$dir_expanded" && log_success "Created directory: [$dir_expanded]"
    else
        log_info "Directory already exists: [$dir_expanded]"
    fi
done

# Add Time Machine Exclusions
log_info "Adding custom exclusions to Time Machine..."
for exclude_dir in "${DIRSTOEXCLUDEFROMTIMEMACHINE[@]}"; do
    exclude_dir_expanded=$(eval echo "$exclude_dir")
    sudo tmutil addexclusion "$exclude_dir_expanded" 2>/dev/null || true
    log_success "Added Time Machine exclusion for: [$exclude_dir_expanded]"
done
