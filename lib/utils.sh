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

# Utility Functions

get_highest_version() {
    manager="$1"
    if "$manager" versions --bare | grep . > /dev/null; then
        HIGHESTVER=$("$manager" versions --bare | sort -rV | head -n1)
    else
        HIGHESTVER=""
    fi
    echo "$HIGHESTVER"
}

get_current_version() {
    manager="$1"
    if [ "$manager" == "jenv" ] || [ "$manager" == "pyenv" ]; then
        CURRENTVER=$("$manager" version-name)
    elif [ "$manager" == "nodenv" ]; then
        CURRENTVER=$("$manager" version)
    elif [ "$manager" == "rbenv" ]; then
        CURRENTVER=$("$manager" version --bare)
    else
        echo "Unknown version manager: $manager"
        return 1
    fi
    echo "$CURRENTVER"
}

restart_system_preferences() {
    log_info "Closing System Preferences if open..."
    osascript -e 'tell application "System Preferences" to quit' &> /dev/null
    log_success "System Preferences closed"
}

check_for_updates() {
    log_info "Checking for Natilius updates..."
    git -C "$NATILIUS_DIR" fetch origin
    local behind=$(git -C "$NATILIUS_DIR" rev-list HEAD..origin/main --count)
    if [ "$behind" -gt 0 ]; then
        log_warning "Natilius is $behind commit(s) behind. Update available."
        read -p "Do you want to update Natilius? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git -C "$NATILIUS_DIR" pull origin main
            log_success "Natilius updated. Please restart the script."
            exit 0
        fi
    else
        log_success "Natilius is up to date."
    fi
}
