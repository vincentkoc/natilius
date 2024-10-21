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
    if [ -z "$NATILIUS_DIR" ]; then
        echo "Error: NATILIUS_DIR is not set"
        return 1
    fi

    if [ "$SKIP_UPDATE_CHECK" = true ]; then
        log_info "Update check skipped due to configuration setting."
        return 0
    fi

    log_info "Checking for Natilius updates..."

    if [ "$TEST_MODE" = true ]; then
        log_success "Natilius is up to date."
        return 0
    fi

    log_debug "Fetching tags..."
    git -C "$NATILIUS_DIR" fetch origin --tags || log_debug "Failed to fetch tags"

    log_debug "Getting current version..."
    current_version=$(git -C "$NATILIUS_DIR" describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    log_debug "Current version: $current_version"

    log_debug "Getting latest version..."
    latest_version=$(git -C "$NATILIUS_DIR" describe --tags --abbrev=0 origin/main 2>/dev/null || echo "v0.0.0")
    log_debug "Latest version: $latest_version"

    if [ "$(version_compare "$current_version" "$latest_version")" -lt 0 ]; then
        log_warning "A new version of Natilius is available: $latest_version (current: $current_version)"
        read -p "Do you want to update Natilius? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git -C "$NATILIUS_DIR" checkout main
            git -C "$NATILIUS_DIR" pull origin main
            git -C "$NATILIUS_DIR" checkout "$latest_version"
            log_success "Natilius updated to version $latest_version. Please restart the script."
            exit 0
        else
            log_info "Update skipped. Continuing with current version."
        fi
    else
        log_success "Natilius is up to date (version $current_version)."
    fi
    return 0
}

version_compare() {
    if [[ "$1" == "$2" ]]
    then
        echo 0
        return
    fi
    local IFS=.
    local i ver1 ver2
    read -ra ver1 <<< "$1"
    read -ra ver2 <<< "$2"
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo 1
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo -1
            return
        fi
    done
    echo 0
}

rotate_logs() {
    local log_dir="$NATILIUS_DIR/logs"
    local max_logs=5

    # Count the number of log files
    local log_count
    log_count=$(find "$log_dir" -maxdepth 1 -type f | wc -l)

    # Remove old logs if there are more than max_logs
    if [ "$log_count" -gt "$max_logs" ]; then
        find "$log_dir" -maxdepth 1 -type f -printf '%T@ %p\n' | \
        sort -n | \
        head -n -"$max_logs" | \
        cut -d' ' -f2- | \
        xargs rm
    fi
}

get_enabled_dev_environments() {
    local enabled_envs=()
    for module in "${ENABLED_MODULES[@]}"; do
        case $module in
            dev_environments/python) enabled_envs+=("python") ;;
            dev_environments/node) enabled_envs+=("node") ;;
            dev_environments/ruby) enabled_envs+=("ruby") ;;
            dev_environments/php) enabled_envs+=("php") ;;
            dev_environments/java) enabled_envs+=("java") ;;
            dev_environments/go) enabled_envs+=("go") ;;
            dev_environments/flutter) enabled_envs+=("flutter") ;;
            # Add more development environments as needed
        esac
    done
    echo "${enabled_envs[@]}"
}

# Function to check sudo privileges
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_error "Sudo privileges have expired. Please run the script again."
        exit 1
    fi
}

# Function to check if a reboot is required
check_reboot_required() {
    if [ -f /var/db/.AppleSetupDone ]; then
        REBOOT_REQUIRED=$(sudo /usr/sbin/softwareupdate --history | grep "restart")
        if [ -n "$REBOOT_REQUIRED" ]; then
            log_warning "A reboot is required to complete the installation of updates."
            return 0
        fi
    fi
    return 1
}
