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

# System Cleanup Module

log_info "Performing system cleanup and optimization..."

# Homebrew cleanup
if command -v brew &> /dev/null; then
    log_info "Running Homebrew cleanup..."
    brew cleanup -s | tee -a "$LOGFILE"
    brew autoremove | tee -a "$LOGFILE"
else
    log_info "Homebrew not found. Skipping Homebrew cleanup."
fi

# NPM cache clean
if command -v npm &> /dev/null; then
    log_info "Cleaning NPM cache..."
    npm cache clean --force | tee -a "$LOGFILE"
else
    log_info "NPM not found. Skipping NPM cache cleanup."
fi

# Yarn cache clean
if command -v yarn &> /dev/null; then
    log_info "Cleaning Yarn cache..."
    yarn cache clean | tee -a "$LOGFILE"
else
    log_info "Yarn not found. Skipping Yarn cache cleanup."
fi

# PIP cache purge
if command -v pip &> /dev/null; then
    log_info "Purging Pip cache..."
    pip cache purge | tee -a "$LOGFILE"
else
    log_info "Pip not found. Skipping Pip cache purge."
fi

# Remove temporary files
log_info "Removing temporary files and caches..."
rm -rf "$HOME/Library/Caches/"* 2>/dev/null || log_info "Failed to remove some user caches"

# Function to safely remove system caches
remove_system_caches() {
    local dir="$1"
    sudo find "$dir" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' item; do
        if sudo rm -rf "$item" 2>/dev/null; then
            log_info "Removed: $item"
        else
            log_warning "Failed to remove: $item (possibly in use)"
        fi
    done
}

refresh_sudo
remove_system_caches "/Library/Caches"
remove_system_caches "/System/Library/Caches"

sudo rm -rf /private/var/folders/* 2>/dev/null || log_warning "Failed to remove some private folders"
sudo rm -rf /private/var/tmp/* 2>/dev/null || log_warning "Failed to remove some private tmp files"
sudo rm -rf /var/log/asl/*.asl 2>/dev/null || log_warning "Failed to remove some ASL logs"

# Clear system and application logs
log_info "Clearing system and application logs..."
sudo rm -rf /var/log/*log /var/log/*.out 2>/dev/null || log_warning "Failed to remove some system logs"
sudo rm -rf /Library/Logs/* 2>/dev/null || log_warning "Failed to remove some library logs"
rm -rf "$HOME/Library/Logs/"* 2>/dev/null || log_info "Failed to remove some user logs"

# Clear XCode derived data and archives (if XCode is installed)
if [ -d "$HOME/Library/Developer/Xcode" ]; then
    log_info "Clearing XCode derived data and archives..."
    rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/* 2>/dev/null || log_info "Failed to remove some XCode derived data"
    rm -rf "$HOME/Library/Developer/Xcode/Archives"/* 2>/dev/null || log_info "Failed to remove some XCode archives"
fi

log_success "System cleanup and optimization complete"
