#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment (https://github.com/vincent_koc/natilius)
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

set -e
trap 'handle_error $LINENO' ERR

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set NATILIUS_DIR relative to the script location
NATILIUS_DIR="$SCRIPT_DIR"
CONFIG_FILE="$HOME/.natiliusrc"

# Set LOGFILE
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="$NATILIUS_DIR/logs/natilius-setup-$TIMESTAMP.log"

# Create logs directory if it doesn't exist
mkdir -p "$NATILIUS_DIR/logs"

# Source utility functions and logging
source "$NATILIUS_DIR/lib/utils.sh"
source "$NATILIUS_DIR/lib/logging.sh"

handle_error() {
    log_error "Error occurred at line $1."
    exit 1
}

INTERACTIVE_MODE=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --interactive|-i)
            INTERACTIVE_MODE=true
            ;;
        --profile|-p)
            shift
            PROFILE="$1"
            CONFIG_FILE="$HOME/.natiliusrc.$PROFILE"
            ;;
        *)
            log_warning "Unknown parameter passed: $1"
            ;;
    esac
    shift
done

# Load user configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    cp "$NATILIUS_DIR/.natiliusrc.example" "$CONFIG_FILE"
    log_info "Created default configuration file at $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

# Set default value for SKIP_UPDATE_CHECK
SKIP_UPDATE_CHECK=${SKIP_UPDATE_CHECK:-false}

# Start logging
log_info "Logging enabled..."
log_info "Log file is located at [$LOGFILE]"
export LOGFILE

# Check for updates
check_for_updates

# Display the ASCII intro
echo -e "\033[0;33m"
cat << "EOF"
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣾⣿⣿⣿⠀⢸⣿⣿⣿⣿⣶⣶⣤⣀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⢀⣴⡇⢀⣾⣿⣿⣿⣿⣿⠀⣾⣿⣿⣿⣿⣿⣿⣿⠿⠓⠀⠀⠀⠀
 ⠀⠀⠀⠀⣰⣿⣿⡀⢸⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⠟⠁⣠⣄⠀⠀⠀⠀
 ⠀⠀⠀⢠⣿⣿⣿⣇⠀⢻⣿⣿⣿⣿⣿⠀⢻⣿⣿⣿⡿⢃⣠⣾⣿⣿⣧⡀⠀⠀
 ⠀⠀⠀⢸⣿⣿⣿⣿⣆⠘⢿⣿⡿⠛⢉⠀⠀⠉⠙⠛⣠⣿⣿⣿⣿⣿⣿⣷⠀⠀
 ⠀⠀⠠⣾⣿⣿⣿⣿⣿⣧⠈⠋⢀⣴⣧⠀⣿⡏⢠⡀⢸⣿⣿⣿⣿⣿⣿⣿⡇⠀
 ⠀⠀⣀⠙⢿⣿⣿⣿⣿⣿⠇⢠��⣿⣿⡄⠹⠃⠼⠃⠈⠉⠛⠛⠛⠛⠛⠻⠇⠀
 ⠀⢸⡟⢠⣤⠉⠛⠿⢿⣿⠀⢸⣿⡿⠋⣠⣤⣄⠀⣾⣿⣣⣶⣶⣶⣦⡄⠀⠀⠀
 ⠀⠸⠀⣾⠏⣸⣷⠂⣠⣤⠀⠘⢁⣴⣾⣿⣿⣿⡆⠘⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
 ⠀⠀⠀⠛⠀⣿⡟⠀⢻⣿⡄⠸⣿⣿⣿⣿⣿⣿⣿⡀⠘⣿⣿⣿⣿⠟⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⣿⠇⠀⠀⢻⡿⠀⠈⠻⣿⣿⣿⣿⣿⡇⠀⢹⣿⠿⠋⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠋⠀⠀⠀⡘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀
                   _ _ _
              _   (_) (_)
  ____   ____| |_  _| |_ _   _  ___
 |  _ \ / _  |  _)| | | | | | |/___)
 | | | ( ( | | |__| | | | |_| |___ |
 |_| |_|\_||_|\___)_|_|_|\____(___/

 Welcome to Natilius

 Natilius is an automated script to help speed up
 development on a Mac machine by scaffolding
 all your key development apps, settings, dotfiles
 configuration, and have you up and running in no
 time. Developed by Vincent Koc (@vincent_koc)

 This script assumes iCloud as the primary
 location for dotfiles and configuration.

 Starting Natilius...
EOF

echo -e "\033[0m"

echo -e "\033[1;33m⚠️  WARNING: This script will make changes to your system. Use at your own risk.\033[0m" | tee -a "$LOGFILE"
echo -e "\033[1;33m⚠️  Ensure you have a complete backup before proceeding.\033[0m" | tee -a "$LOGFILE"
echo -e "\033[1;33m⚠️  Review the script and configuration before running.\033[0m" | tee -a "$LOGFILE"
echo
read -r -p "Press Enter to continue or Ctrl+C to abort..." | tee -a "$LOGFILE"
echo

# Prompt for sudo password at the start
log_info "Please provide your password to proceed with sudo privileges (may auto-skip)..."
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

log_success "Sudo password validated"

# Interactive Mode
if [ "$INTERACTIVE_MODE" = true ]; then
    log_info "Interactive mode enabled. Please select which modules to run."
    # List available modules
    AVAILABLE_MODULES=()
    MODULE_PATHS=()
    INDEX=1
    echo "Available modules:"
    for module_file in $(find "$NATILIUS_DIR/modules" -name "*.sh" | sort); do
        module_name=$(echo "$module_file" | sed "s#$NATILIUS_DIR/modules/##;s#\.sh\$##")
        echo "[$INDEX] $module_name"
        AVAILABLE_MODULES+=("$module_name")
        MODULE_PATHS+=("$module_file")
        INDEX=$((INDEX + 1))
    done

    echo "Enter the numbers of the modules you want to run, separated by spaces (e.g., 1 3 5):"
    read -r SELECTED_MODULE_INDICES

    # Build the module list based on user selection
    SELECTED_MODULES=()
    for index in $SELECTED_MODULE_INDICES; do
        if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le "${#AVAILABLE_MODULES[@]}" ]; then
            SELECTED_MODULES+=("${AVAILABLE_MODULES[$((index - 1))]}")
        else
            log_warning "Invalid selection: $index"
        fi
    done

    if [ "${#SELECTED_MODULES[@]}" -eq 0 ]; then
        log_warning "No valid modules selected. Exiting."
        exit 1
    fi
else
    # Use modules from configuration
    SELECTED_MODULES=("${ENABLED_MODULES[@]}")
fi

# Run selected modules
for module in "${SELECTED_MODULES[@]}"; do
    MODULE_PATH="$NATILIUS_DIR/modules/$module.sh"
    if [ -f "$MODULE_PATH" ]; then
        log_info "Running module: $module"
        source "$MODULE_PATH"
    else
        log_warning "Module not found: $module"
        log_info "Searched in: $MODULE_PATH"
    fi
done

# Conclusion
echo -e | tee -a "$LOGFILE"
echo -e | tee -a "$LOGFILE"
echo -e "\033[0;32m[ 🐚 ]\033[0m \033[0;36mNatilius install script has completed!\033[0m" | tee -a "$LOGFILE"
echo -e "\033[0;33m"
cat << EOF
 Thanks for using Natilius :)
 Your logfile is saved at $LOGFILE

 You are welcome to leave feedback, comments, and issues
 directly on GitHub at (https://github.com/vincent_koc/natilius).

 I also welcome PRs and suggestions to speed up the
 setup of your development environment.

 Thanks
 Vince

EOF
echo -e "\033[0m"
