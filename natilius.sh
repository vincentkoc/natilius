#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment (https://github.com/vincentkoc/natilius)
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

# Early macOS check will be done after parsing help/version commands

# Error handling function
# shellcheck disable=SC2329  # Function is used by trap
handle_error() {
    local line_number=$1
    local error_message=$2
    log_error "Error occurred at line $line_number: $error_message"
    log_error "Stack trace:"
    local frame=0
    while caller "$frame"; do  # Fixed: Added quotes around $frame
        ((frame++))
    done | sed 's/^/    /' | tee -a "$LOGFILE"
    exit 1
}

# Set up error handling
set -e
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

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

# Override logging functions based on verbosity settings
if [ "$QUIET_MODE" = true ]; then
    log_info() { :; }
    log_success() { :; }
    log_warning() { echo "[WARNING] $1" >&2; }
    log_error() { echo "[ERROR] $1" >&2; }
fi

if [ "$VERBOSE_MODE" = true ]; then
    log_debug() {
        echo "[DEBUG] $1" | tee -a "$LOGFILE"
    }
else
    log_debug() {
        echo "[DEBUG] $1" >> "$LOGFILE"
    }
fi

# Parse command-line arguments
INTERACTIVE_MODE=false
DRY_RUN=false
VERBOSE_MODE=false
QUIET_MODE=false
SHOW_VERSION=false
COMMAND=""

# Function to show help
show_help() {
    cat << EOF
Natilius - 🐚 Automated One-Click Mac Developer Environment

USAGE:
    natilius [OPTIONS] [COMMAND]

COMMANDS:
    setup           Run the full setup process (default)
    doctor          Run system diagnostics and checks
    list-modules    List all available modules
    version         Show version information
    help            Show this help message

OPTIONS:
    -v, --verbose       Enable verbose output
    -q, --quiet         Suppress non-error output
    -i, --interactive   Run in interactive mode
    -c, --check         Run in check/dry-run mode (no changes)
    -p, --profile NAME  Use a specific configuration profile
    --dry-run           Same as --check
    -h, --help          Show this help message

EXAMPLES:
    natilius                    # Run default setup
    natilius --check            # Dry run to see what would be done
    natilius doctor             # Run system diagnostics
    natilius list-modules       # Show available modules
    natilius -v setup           # Run setup with verbose output

For more information, visit: https://github.com/vincentkoc/natilius
EOF
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        setup)
            COMMAND="setup"
            ;;
        doctor)
            COMMAND="doctor"
            ;;
        list-modules)
            COMMAND="list-modules"
            ;;
        version|--version|-V)
            SHOW_VERSION=true
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        --interactive|-i)
            INTERACTIVE_MODE=true
            ;;
        --verbose|-v)
            VERBOSE_MODE=true
            ;;
        --quiet|-q)
            QUIET_MODE=true
            ;;
        --profile|-p)
            shift
            PROFILE="$1"
            CONFIG_FILE="$HOME/.natiliusrc.$PROFILE"
            ;;
        --dry-run|--test|--check|-c)
            DRY_RUN=true
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Use 'natilius --help' for usage information."
            exit 1
            ;;
    esac
    shift
done

# Set default command if none specified
if [ -z "$COMMAND" ] && [ "$SHOW_VERSION" = false ]; then
    COMMAND="setup"
fi

# Load user configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    cp "$NATILIUS_DIR/.natiliusrc.example" "$CONFIG_FILE"
    log_info "Created default configuration file at $CONFIG_FILE"
fi
source "$CONFIG_FILE"  # Always source the config file, even if it existed before

# Set default value for SKIP_UPDATE_CHECK
SKIP_UPDATE_CHECK=${SKIP_UPDATE_CHECK:-false}

# Version information
NATILIUS_VERSION="1.1.0"

# Function to show version
show_version() {
    echo "Natilius version $NATILIUS_VERSION"
    echo "Copyright (C) 2023 Vincent Koc (@vincent_koc)"
    echo "License: GPLv3+"
}

# Function to list modules
list_modules() {
    echo "Available Natilius Modules:"
    echo ""
    echo "System Modules:"
    for module in "$NATILIUS_DIR"/modules/system/*.sh; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module" .sh)
            echo "  - system/$module_name"
        fi
    done
    echo ""
    echo "Development Environment Modules:"
    for module in "$NATILIUS_DIR"/modules/dev_environments/*.sh; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module" .sh)
            echo "  - dev_environments/$module_name"
        fi
    done
    echo ""
    echo "Application Modules:"
    for module in "$NATILIUS_DIR"/modules/applications/*.sh; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module" .sh)
            echo "  - applications/$module_name"
        fi
    done
    echo ""
    echo "IDE Modules:"
    for module in "$NATILIUS_DIR"/modules/ide/*.sh; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module" .sh)
            echo "  - ide/$module_name"
        fi
    done
    echo ""
    echo "Preference Modules:"
    for module in "$NATILIUS_DIR"/modules/preferences/*.sh; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module" .sh)
            echo "  - preferences/$module_name"
        fi
    done
    echo ""
    echo "Other Modules:"
    if [ -f "$NATILIUS_DIR/modules/dotfiles.sh" ]; then
        echo "  - dotfiles"
    fi
    echo ""
    echo "Currently enabled modules in $CONFIG_FILE:"
    for module in "${ENABLED_MODULES[@]}"; do
        echo "  * $module"
    done
}

# Function to run doctor diagnostics
run_doctor() {
    echo "Natilius Doctor - System Diagnostics"
    echo "====================================="
    echo ""

    # Check system information
    echo "System Information:"
    echo "  macOS Version: $(sw_vers -productVersion)"
    echo "  Architecture: $(uname -m)"
    echo "  Hostname: $(hostname)"
    echo "  User: $(whoami)"
    echo ""

    # Check Xcode Command Line Tools
    echo "Development Tools:"
    if xcode-select -p &> /dev/null; then
        echo "  ✓ Xcode Command Line Tools: $(xcode-select -p)"
    else
        echo "  ✗ Xcode Command Line Tools: Not installed"
    fi

    # Check Homebrew
    if command -v brew &> /dev/null; then
        echo "  ✓ Homebrew: $(brew --version | head -n1)"
    else
        echo "  ✗ Homebrew: Not installed"
    fi

    # Check Git
    if command -v git &> /dev/null; then
        echo "  ✓ Git: $(git --version)"
    else
        echo "  ✗ Git: Not installed"
    fi
    echo ""

    # Check configuration
    echo "Configuration:"
    if [ -f "$CONFIG_FILE" ]; then
        echo "  ✓ Config file: $CONFIG_FILE"
        echo "  ✓ Enabled modules: ${#ENABLED_MODULES[@]}"
    else
        echo "  ✗ Config file: Not found at $CONFIG_FILE"
    fi
    echo ""

    # Check disk space
    echo "Disk Space:"
    df -h / | awk 'NR==2 {print "  Available: " $4 " (" $5 " used)"}'
    echo ""

    # Check network
    echo "Network:"
    if ping -c 1 -t 2 google.com &> /dev/null; then
        echo "  ✓ Internet connection: Active"
    else
        echo "  ✗ Internet connection: No connection"
    fi
    echo ""

    # Check for common issues
    echo "Common Issues:"
    issues_found=false

    # Check sudo access
    if sudo -n true 2>/dev/null; then
        echo "  ✓ Sudo access: Available without password"
    elif sudo -v 2>/dev/null; then
        echo "  ⚠ Sudo access: Requires password"
    else
        echo "  ✗ Sudo access: Not available"
        issues_found=true
    fi

    # Check SIP status
    if csrutil status | grep -q "enabled"; then
        echo "  ✓ System Integrity Protection: Enabled (recommended)"
    else
        echo "  ⚠ System Integrity Protection: Disabled"
    fi

    # Check for Rosetta on Apple Silicon
    if [ "$(uname -m)" == "arm64" ]; then
        if /usr/bin/pgrep oahd >/dev/null 2>&1; then
            echo "  ✓ Rosetta 2: Installed"
        else
            echo "  ⚠ Rosetta 2: Not installed (may be needed for some apps)"
        fi
    fi

    if [ "$issues_found" = false ]; then
        echo "  ✓ No critical issues found"
    fi
    echo ""

    echo "Recommendations:"
    if ! xcode-select -p &> /dev/null; then
        echo "  • Install Xcode Command Line Tools: xcode-select --install"
    fi
    if ! command -v brew &> /dev/null; then
        echo "  • Install Homebrew: See https://brew.sh"
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "  • Create configuration: cp $NATILIUS_DIR/.natiliusrc.example ~/.natiliusrc"
    fi
    echo ""
}

# Handle version flag
if [ "$SHOW_VERSION" = true ]; then
    show_version
    exit 0
fi

# Check if running on macOS (after help/version commands)
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is only supported on macOS."
    echo "Other operating systems are not supported yet."
    exit 1
fi

# Handle specific commands
if [ "$COMMAND" = "doctor" ]; then
    run_doctor
    exit 0
fi

if [ "$COMMAND" = "list-modules" ]; then
    list_modules
    exit 0
fi

# After sourcing the config file
log_info "Loaded configuration from $CONFIG_FILE"
log_info "Enabled modules: ${ENABLED_MODULES[*]}"

# After loading configuration and before any system-modifying operations:
if [ "$DRY_RUN" = true ]; then
    log_info "Running in check/dry-run mode. No system changes will be made."
    echo ""
    echo "The following modules would be executed:"
    for module in "${ENABLED_MODULES[@]}"; do
        echo "  - $module"
    done
    echo ""
    echo "To actually run the setup, remove the --check flag."
    exit 0
fi

# Start logging
log_info "Logging enabled..."
log_info "Log file is located at [$LOGFILE]"
export LOGFILE

# Check for updates
check_for_updates

# Rotate logs
rotate_logs

# Display the ASCII intro
echo -e "\033[0;33m"
cat << "EOF"
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣾⣿⣿⣿⠀⢸⣿⣿⣿⣿⣶⣶⣤⣀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⢀⣴⡇⢀⣾⣿⣿⣿⣿⣿⠀⣾⣿⣿⣿⣿⣿⣿⠿⠓⠀⠀⠀⠀
 ⠀⠀⠀⠀⣰⣿⣿⣿⡀⢸⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⠁⣠⣄⠀⠀⠀⠀
 ⠀⠀⠀⢠⣿⣿⣿⣿⣇⠀⢻⣿⣿⣿⣿⣿⠀⢻⣿⣿⣿⡿⢃⣠⣾⣿⣿⣧⡀⠀⠀
 ⠀⠀⠀⢸⣿⣿⣿⣿⣿⣧⠈⢿⣿⡿⠛⢉⠀⠀⠉⠙⠛⣠⣿⣿⣿⣿⣿⣷⠀⠀
 ⠀⠀⠠⣾⣿⣿⣿⣿⣿⣧⠈⠋⢀⣴⣧⠀⣿⡏⢠⡀⢸⣿⣿⣿⣿⣿⣿⣿⡇⠀
 ⠀⠀⣀⠙⢿⣿⣿⣿⣿⣿⠇⢠⣿⣿⡄⠹⠃⠼⠃⠈⠉⠛⠛⠛⠛⠛⠻⠇⠀
 ⠀⢸⡟⢠⣤⠉⠛⠿⢿⣿⠀⢸⣿⡿⠋⣠⣤⣄⠀⣾⣿⣣⣶⣶⣶⣦⡄⠀⠀⠀
 ⠀⠸⠀⣾⠏⣸⣷⠂⣠⣤⠀⠘⢁⣴⣾⣿⣿⣿⡆⠘⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
 ⠀⠀⠀⠛⠀⣿⡟⠀⢻⡿⠀⠈⠻⣿⣿⣿⣿⣿⡇⠀⢹⣿⠿⠋⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⣿⠇⠀⠀⡘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀
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

if [ "$INTERACTIVE_MODE" = true ]; then
    read -r -p "Press Enter to continue or Ctrl+C to abort..." | tee -a "$LOGFILE"
else
    log_info "Running in non-interactive mode. Proceeding automatically."
fi

echo

# Skip sudo validation if SKIP_SUDO is set (for CI environments)
if [[ -n "${SKIP_SUDO}" ]]; then
    log_info "Skipping sudo validation (SKIP_SUDO is set)"
else
    # Attempt to get sudo privileges
    log_info "Attempting to validate sudo privileges..."
    log_debug "Current user: $(whoami)"
    log_debug "Current directory: $(pwd)"
    log_debug "Script location: $0"
    log_debug "NATILIUS_DIR: $NATILIUS_DIR"
    log_debug "LOGFILE: $LOGFILE"
    if sudo -v; then
        log_success "Sudo privileges validated successfully."
        keep_sudo_alive
    else
        log_error "Failed to validate sudo privileges. Error code: $?"
        log_error "Please ensure you have sudo access and try again."
        exit 1
    fi
fi

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
log_info "Starting to run selected modules..."
for module in "${SELECTED_MODULES[@]}"; do
    MODULE_PATH="$NATILIUS_DIR/modules/$module.sh"
    if [ -f "$MODULE_PATH" ]; then
        log_info "Running module: $module"
        refresh_sudo
        source "$MODULE_PATH"
        log_info "Finished running module: $module"
    else
        log_warning "Module not found: $module"
        log_info "Searched in: $MODULE_PATH"
    fi
done
log_info "Finished running all selected modules."

# Run IDE setup after all other modules
if [[ " ${SELECTED_MODULES[*]} " =~ " ide_setup " ]]; then
    log_info "Running IDE setup module"
    source "$NATILIUS_DIR/modules/ide/ide_setup.sh"
fi

# Stop the sudo keep-alive process
log_info "Stopping sudo keep-alive process..."
stop_sudo_keep_alive
log_info "Sudo keep-alive process stopped."

# Add a small delay to allow for process cleanup
sleep 1

# Conclusion
echo -e "\n" | tee -a "$LOGFILE"
echo -e "\033[0;32m[ 🐚 ]\033[0m \033[0;36mNatilius install script has completed!\033[0m" | tee -a "$LOGFILE"
echo -e "\033[0;33m" | tee -a "$LOGFILE"
cat << EOF | tee -a "$LOGFILE"
 Thanks for using Natilius :)
 Your logfile is saved at $LOGFILE

 You are welcome to leave feedback, comments, and issues
 directly on GitHub at (https://github.com/vincentkoc/natilius).

 I also welcome PRs and suggestions to speed up the
 setup of your development environment.

 Thanks
 Vince

EOF
echo -e "\033[0m" | tee -a "$LOGFILE"

# Ensure all output is flushed
sync

# Clean exit
exit 0
