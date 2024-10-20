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
log_info "Running Homebrew cleanup..."
brew cleanup -s | tee -a "$LOGFILE"
brew autoremove | tee -a "$LOGFILE"

# NPM cache clean
if command -v npm &> /dev/null; then
    log_info "Cleaning NPM cache..."
    npm cache clean --force | tee -a "$LOGFILE"
fi

# Yarn cache clean
if command -v yarn &> /dev/null; then
    log_info "Cleaning Yarn cache..."
    yarn cache clean | tee -a "$LOGFILE"
fi

# PIP cache purge
if command -v pip &> /dev/null; then
    log_info "Purging Pip cache..."
    pip cache purge | tee -a "$LOGFILE"
fi

# Remove temporary files
log_info "Removing temporary files and caches..."
rm -rf "$HOME/Library/Caches/"*
sudo rm -rf /Library/Caches/*
sudo rm -rf /System/Library/Caches/*
sudo rm -rf /private/var/folders/*
sudo rm -rf /private/var/tmp/*
sudo rm -rf /var/log/asl/*.asl || true

log_success "System cleanup and optimization complete"
