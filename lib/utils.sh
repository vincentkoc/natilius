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
    if [ "$SKIP_UPDATE_CHECK" = true ]; then
        log_info "Skipping update check as per configuration."
        return
    fi

    log_info "Checking for Natilius updates..."

    # Fetch the latest version from the remote repository
    git fetch origin main --quiet
    LATEST_VERSION=$(git describe --tags --abbrev=0 origin/main 2>/dev/null || echo "v0.0.0")
    CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

    # Remove the 'v' prefix for version comparison
    LATEST_VERSION_NUM=${LATEST_VERSION#v}
    CURRENT_VERSION_NUM=${CURRENT_VERSION#v}

    # Compare versions
    if [ "$LATEST_VERSION_NUM" != "$CURRENT_VERSION_NUM" ]; then
        log_warning "A new version of Natilius is available: $LATEST_VERSION (current: $CURRENT_VERSION)"
        log_warning "Please update Natilius to ensure you have the latest features and bug fixes."
        log_warning "You can update by running: git pull origin main"
        echo
        read -p "Do you want to continue with the current version? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Exiting. Please update Natilius and run the script again."
            exit 0
        fi
    else
        log_success "Natilius is up to date (version $CURRENT_VERSION)."
    fi
}

# Function to compare version numbers
version_compare() {
    if [[ "$1" == "$2" ]]; then  # Fixed: Added quotes around $1 and $2
        return 0
    fi
    local IFS=.
    local i ver1 ver2
    read -ra ver1 <<< "$1"  # Fixed: Use read to split the version string
    read -ra ver2 <<< "$2"  # Fixed: Use read to split the version string
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

rotate_logs() {
    local log_dir="$NATILIUS_DIR/logs"
    local max_logs=5

    # Count the number of log files
    local log_count
    log_count=$(find "$log_dir" -type f | wc -l)

    # Remove old logs if there are more than max_logs
    if [ "$log_count" -gt "$max_logs" ]; then
        find "$log_dir" -type f -print0 | \
        xargs -0 ls -t | \
        tail -n +"$((max_logs + 1))" | \
        xargs -I {} rm -- {}
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

keep_sudo_alive() {
    while true; do
        sudo -n true
        sleep 30
        kill -0 "$$" 2>/dev/null || exit
    done 2>/dev/null &
    SUDO_KEEP_ALIVE_PID=$!
}

stop_sudo_keep_alive() {
    if [ -n "$SUDO_KEEP_ALIVE_PID" ]; then
        set +e  # Temporarily disable exit on error
        kill -TERM "$SUDO_KEEP_ALIVE_PID" 2>/dev/null || true
        wait "$SUDO_KEEP_ALIVE_PID" 2>/dev/null || true
        set -e  # Re-enable exit on error
        unset SUDO_KEEP_ALIVE_PID
    fi
}

refresh_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_warning "Sudo privileges expired. Requesting password again..."
        if ! sudo -v; then
            log_error "Failed to refresh sudo privileges. Some operations may fail."
            return 1
        fi
        log_success "Sudo privileges refreshed successfully."
    fi
    return 0
}

# Function to safely rehash version managers
safe_rehash() {
    local manager="$1"
    local shim_file="$HOME/.${manager}/shims/.${manager}-shim"

    log_info "Attempting to rehash $manager..."
    if [ -f "$shim_file" ]; then
        log_warning "$manager shim file already exists. Removing it before rehash."
        rm -f "$shim_file"
    fi
    if $manager rehash 2>/dev/null; then
        log_success "$manager rehash completed successfully."
    else
        log_warning "$manager rehash encountered an issue, but we'll continue. This is not critical."
    fi
}
