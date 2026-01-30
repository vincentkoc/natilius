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
set -o pipefail
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# Get the directory of the script (follow symlinks)
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SOURCE" ]; do
    SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"

# Set NATILIUS_DIR relative to the script location
NATILIUS_DIR="$SCRIPT_DIR"
CONFIG_FILE="$HOME/.natiliusrc"

# Set LOGFILE (use ~/.natilius/logs for user-writable location)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$HOME/.natilius/logs"
LOGFILE="$LOG_DIR/natilius-setup-$TIMESTAMP.log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Source utility functions and logging
source "$NATILIUS_DIR/lib/utils.sh"
source "$NATILIUS_DIR/lib/logging.sh"
source "$NATILIUS_DIR/lib/network_utils.sh"
source "$NATILIUS_DIR/lib/mdm_utils.sh"

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
    init            Interactive setup wizard (creates ~/.natiliusrc)
    setup           Run the full setup process
    doctor          Run system diagnostics and checks
    modules         List all available modules
    profiles        List available configuration profiles
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
    natilius init               # Interactive setup wizard
    natilius setup              # Run full setup
    natilius setup --check      # Dry run (preview changes)
    natilius doctor             # Run system diagnostics
    natilius profiles           # List available profiles
    natilius -p devops setup    # Run setup with devops profile

ENVIRONMENT VARIABLES:
    Override config values with NATILIUS_ prefix:
      NATILIUS_PYTHONVER=3.12.0     Override Python version
      NATILIUS_NODEVER=22.0.0       Override Node.js version
      NATILIUS_INSTALL_VSCODE=false Disable VS Code installation

    Automation variables:
      SKIP_SUDO=true                Skip sudo prompts (CI/CD)
      NONINTERACTIVE=true           No prompts at all
      DRY_RUN=true                  Preview mode

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
        modules|list-modules)
            COMMAND="modules"
            ;;
        profiles)
            COMMAND="profiles"
            ;;
        init)
            COMMAND="init"
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
            echo -e "\033[1;31m✗\033[0m Unknown parameter: $1"
            echo -e "  \033[2mUse 'natilius --help' for usage information.\033[0m"
            exit 1
            ;;
    esac
    shift
done

# If no command specified, show help (safe default)
if [ -z "$COMMAND" ] && [ "$SHOW_VERSION" = false ]; then
    show_help
    exit 0
fi

# Load user configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    cp "$NATILIUS_DIR/.natiliusrc.example" "$CONFIG_FILE"
    log_info "Created default configuration file at $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

# Apply environment variable overrides
# Environment variables with NATILIUS_ prefix override config file values
# Example: NATILIUS_PYTHONVER=3.12.0 natilius setup
apply_env_overrides() {
    # Version overrides (use if-then to avoid set -e issues)
    if [ -n "${NATILIUS_JDKVER:-}" ]; then JDKVER="$NATILIUS_JDKVER"; fi
    if [ -n "${NATILIUS_PYTHONVER:-}" ]; then PYTHONVER="$NATILIUS_PYTHONVER"; fi
    if [ -n "${NATILIUS_RUBYVER:-}" ]; then RUBYVER="$NATILIUS_RUBYVER"; fi
    if [ -n "${NATILIUS_NODEVER:-}" ]; then NODEVER="$NATILIUS_NODEVER"; fi
    if [ -n "${NATILIUS_GOVER:-}" ]; then GOVER="$NATILIUS_GOVER"; fi
    if [ -n "${NATILIUS_PHPVER:-}" ]; then PHPVER="$NATILIUS_PHPVER"; fi
    if [ -n "${NATILIUS_FLUTTER_CHANNEL:-}" ]; then FLUTTER_CHANNEL="$NATILIUS_FLUTTER_CHANNEL"; fi

    # Boolean overrides
    if [ -n "${NATILIUS_SKIP_UPDATE_CHECK:-}" ]; then SKIP_UPDATE_CHECK="$NATILIUS_SKIP_UPDATE_CHECK"; fi
    if [ -n "${NATILIUS_INSTALL_VSCODE:-}" ]; then INSTALL_VSCODE="$NATILIUS_INSTALL_VSCODE"; fi
    if [ -n "${NATILIUS_INSTALL_CURSOR:-}" ]; then INSTALL_CURSOR="$NATILIUS_INSTALL_CURSOR"; fi
    if [ -n "${NATILIUS_INSTALL_JETBRAINS:-}" ]; then INSTALL_JETBRAINS="$NATILIUS_INSTALL_JETBRAINS"; fi
    if [ -n "${NATILIUS_INSTALL_SUBLIME:-}" ]; then INSTALL_SUBLIME="$NATILIUS_INSTALL_SUBLIME"; fi
    if [ -n "${NATILIUS_INSTALL_ZED:-}" ]; then INSTALL_ZED="$NATILIUS_INSTALL_ZED"; fi

    # Enterprise/MDM overrides
    if [ -n "${NATILIUS_ENTERPRISE_MODE:-}" ]; then ENTERPRISE_MODE="$NATILIUS_ENTERPRISE_MODE"; fi
    if [ -n "${NATILIUS_RESPECT_MDM_POLICIES:-}" ]; then RESPECT_MDM_POLICIES="$NATILIUS_RESPECT_MDM_POLICIES"; fi
    if [ -n "${NATILIUS_JAMF_RECON_ON_COMPLETE:-}" ]; then JAMF_RECON_ON_COMPLETE="$NATILIUS_JAMF_RECON_ON_COMPLETE"; fi

    # String overrides (exported for use by modules)
    # shellcheck disable=SC2034  # COUNTRYCODE used by modules
    if [ -n "${NATILIUS_COUNTRYCODE:-}" ]; then COUNTRYCODE="$NATILIUS_COUNTRYCODE"; fi
}

apply_env_overrides

# Set default value for SKIP_UPDATE_CHECK
SKIP_UPDATE_CHECK=${SKIP_UPDATE_CHECK:-false}

# Version information
NATILIUS_VERSION="1.4.0"

# Colors for terminal output
CYAN='\033[1;36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# Function to show banner
show_banner() {
    echo ""
    echo -e "  ${CYAN}┃${RESET} ${BOLD}🐚 natilius${RESET}"
    echo -e "  ${CYAN}┃${RESET} ${DIM}Mac Developer Environment Setup${RESET}"
    echo -e "  ${CYAN}┃${RESET} ${DIM}v${NATILIUS_VERSION}${RESET}"
    echo ""
}

# Function to show version
show_version() {
    show_banner
    echo -e "  ${DIM}Copyright (C) 2024 Vincent Koc (@vincent_koc)${RESET}"
    echo -e "  ${DIM}License: GPLv3+${RESET}"
    echo ""
}

# Function to list available profiles
list_profiles() {
    show_banner
    echo -e "  ${BOLD}Built-in Profiles${RESET}"
    echo ""

    # Check for profile files in profiles directory
    if [ -d "$NATILIUS_DIR/profiles" ]; then
        for profile in "$NATILIUS_DIR"/profiles/*.natiliusrc; do
            if [ -f "$profile" ]; then
                profile_name=$(basename "$profile" .natiliusrc)
                # Extract description from profile if available
                description=$(grep -m1 "^# Description:" "$profile" 2>/dev/null | sed 's/^# Description: //' || echo "")
                echo -e "  ${CYAN}●${RESET} ${BOLD}$profile_name${RESET}"
                if [ -n "$description" ]; then
                    echo -e "    $description"
                fi
            fi
        done
    fi

    # Check for user profiles in home directory
    echo ""
    echo -e "  ${BOLD}User Profiles${RESET}"
    local found_user_profiles=false
    for profile in "$HOME"/.natiliusrc.*; do
        if [ -f "$profile" ]; then
            profile_name=$(basename "$profile" | sed 's/^\.natiliusrc\.//')
            # Extract description from user profile if available
            description=$(grep -m1 "^# Description:" "$profile" 2>/dev/null | sed 's/^# Description: //' || echo "")
            echo -e "  ${CYAN}●${RESET} ${BOLD}$profile_name${RESET}"
            if [ -n "$description" ]; then
                echo -e "    $description"
            fi
            echo -e "    ${DIM}$profile${RESET}"
            found_user_profiles=true
        fi
    done

    if [ "$found_user_profiles" = false ]; then
        echo -e "    ${DIM}No custom profiles found${RESET}"
        echo ""
        echo -e "  ${BOLD}Create a Profile${RESET}"
        echo -e "    ${DIM}Copy a built-in profile to customize:${RESET}"
        echo -e "    ${CYAN}→${RESET} cp $NATILIUS_DIR/profiles/devops.natiliusrc ~/.natiliusrc.myprofile"
        echo ""
        echo -e "    ${DIM}Or download from GitHub:${RESET}"
        echo -e "    ${CYAN}→${RESET} curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/.natiliusrc.example -o ~/.natiliusrc"
        echo ""
        echo -e "    ${DIM}Browse profiles: https://github.com/vincentkoc/natilius/tree/main/profiles${RESET}"
    fi

    echo ""
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${DIM}Usage: natilius --profile <name> setup${RESET}"
    echo ""
}

# Function to run interactive init
run_init() {
    local GREEN='\033[1;32m'
    local YELLOW='\033[1;33m'
    local has_gum=false

    # Check if gum is installed
    if command -v gum &> /dev/null; then
        has_gum=true
    fi

    show_banner
    echo -e "  ${BOLD}Interactive Setup${RESET}"
    echo -e "  ${DIM}Let's create your configuration file${RESET}"
    echo ""

    # Check if config already exists
    if [ -f "$HOME/.natiliusrc" ]; then
        echo -e "  ${YELLOW}⚠${RESET}  Config file already exists: ~/.natiliusrc"
        echo ""
        if [ "$has_gum" = true ]; then
            if ! gum confirm "  Overwrite existing configuration?"; then
                echo ""
                echo -e "  ${DIM}Cancelled. Your existing config was not modified.${RESET}"
                echo ""
                exit 0
            fi
        else
            read -r -p "  Overwrite existing configuration? [y/N] " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo ""
                echo -e "  ${DIM}Cancelled. Your existing config was not modified.${RESET}"
                echo ""
                exit 0
            fi
        fi
        echo ""
    fi

    # Select profile
    echo -e "  ${BOLD}Select a Profile${RESET}"
    echo ""

    local selected_profile
    if [ "$has_gum" = true ]; then
        selected_profile=$(gum choose --header "  What best describes your role?" \
            "minimal    - Essential tools only (git, brew, shell)" \
            "devops     - Kubernetes, Terraform, cloud CLIs" \
            "developer  - Full dev environment (all languages + IDEs)" \
            "full       - Everything! All tools, apps, languages (edit to customize)" \
            "custom     - Start with an empty config")
        selected_profile=$(echo "$selected_profile" | awk '{print $1}')
    else
        echo "  What best describes your role?"
        echo ""
        echo "    1) minimal    - Essential tools only"
        echo "    2) devops     - Kubernetes, Terraform, cloud CLIs"
        echo "    3) developer  - Full dev environment"
        echo "    4) full       - Everything! (edit to customize)"
        echo "    5) custom     - Start with an empty config"
        echo ""
        read -r -p "  Select [1-5]: " choice
        case "$choice" in
            1) selected_profile="minimal" ;;
            2) selected_profile="devops" ;;
            3) selected_profile="developer" ;;
            4) selected_profile="full" ;;
            5) selected_profile="custom" ;;
            *) selected_profile="minimal" ;;
        esac
    fi
    echo ""

    # Copy the selected profile
    local source_file
    if [ "$selected_profile" = "full" ]; then
        source_file="$NATILIUS_DIR/.natiliusrc.example"
    elif [ "$selected_profile" = "custom" ]; then
        source_file=""  # Will create minimal config
    else
        source_file="$NATILIUS_DIR/profiles/${selected_profile}.natiliusrc"
    fi

    if [ -z "$source_file" ]; then
        # Custom: will create a minimal config
        :
    elif [ ! -f "$source_file" ]; then
        echo -e "  ${YELLOW}⚠${RESET}  Profile not found, using full example config"
        source_file="$NATILIUS_DIR/.natiliusrc.example"
    fi

    # Ask about IDE preferences
    echo -e "  ${BOLD}IDE Preferences${RESET}"
    echo ""

    local install_vscode=false
    local install_cursor=false
    local install_jetbrains=false

    if [ "$has_gum" = true ]; then
        local ide_choices
        ide_choices=$(gum choose --no-limit --header "  Select IDEs to install (space to select, enter to confirm):" \
            "VS Code" \
            "Cursor" \
            "JetBrains IDEs" \
            "None")

        [[ "$ide_choices" == *"VS Code"* ]] && install_vscode=true
        [[ "$ide_choices" == *"Cursor"* ]] && install_cursor=true
        [[ "$ide_choices" == *"JetBrains"* ]] && install_jetbrains=true
    else
        read -r -p "  Install VS Code? [Y/n] " ans
        [[ ! "$ans" =~ ^[Nn]$ ]] && install_vscode=true

        read -r -p "  Install Cursor? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] && install_cursor=true

        read -r -p "  Install JetBrains IDEs? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] && install_jetbrains=true
    fi
    echo ""

    # Copy config file or create minimal one
    if [ -z "$source_file" ]; then
        # Custom: create minimal config
        cat > "$HOME/.natiliusrc" << 'MINIMAL_EOF'
# Natilius Configuration (Custom)
# Add modules and packages as needed

ENABLED_MODULES=(
    "system/system_update"
    "applications/homebrew"
)

BREWPACKAGES=(
    "git"
    "curl"
    "wget"
)

BREWCASKS=()
MINIMAL_EOF
    else
        cp "$source_file" "$HOME/.natiliusrc"
    fi

    # Update IDE settings in config
    if grep -q "INSTALL_VSCODE=" "$HOME/.natiliusrc"; then
        sed -i '' "s/INSTALL_VSCODE=.*/INSTALL_VSCODE=$install_vscode/" "$HOME/.natiliusrc"
    else
        echo "INSTALL_VSCODE=$install_vscode" >> "$HOME/.natiliusrc"
    fi

    if grep -q "INSTALL_CURSOR=" "$HOME/.natiliusrc"; then
        sed -i '' "s/INSTALL_CURSOR=.*/INSTALL_CURSOR=$install_cursor/" "$HOME/.natiliusrc"
    else
        echo "INSTALL_CURSOR=$install_cursor" >> "$HOME/.natiliusrc"
    fi

    if grep -q "INSTALL_JETBRAINS=" "$HOME/.natiliusrc"; then
        sed -i '' "s/INSTALL_JETBRAINS=.*/INSTALL_JETBRAINS=$install_jetbrains/" "$HOME/.natiliusrc"
    else
        echo "INSTALL_JETBRAINS=$install_jetbrains" >> "$HOME/.natiliusrc"
    fi

    # Add description header
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M")
    sed -i '' "1s/^/# Description: Custom config created via natilius init ($timestamp)\n/" "$HOME/.natiliusrc"

    # Show summary
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${GREEN}✓${RESET} Configuration created!"
    echo ""
    echo -e "  ${BOLD}Summary${RESET}"
    echo -e "    Profile: ${CYAN}$selected_profile${RESET}"
    echo -e "    Config:  ${DIM}~/.natiliusrc${RESET}"
    echo ""
    echo -e "  ${BOLD}IDEs${RESET}"
    [ "$install_vscode" = true ] && echo -e "    ${GREEN}●${RESET} VS Code"
    [ "$install_cursor" = true ] && echo -e "    ${GREEN}●${RESET} Cursor"
    [ "$install_jetbrains" = true ] && echo -e "    ${GREEN}●${RESET} JetBrains IDEs"
    [ "$install_vscode" = false ] && [ "$install_cursor" = false ] && [ "$install_jetbrains" = false ] && echo -e "    ${DIM}None selected${RESET}"
    echo ""

    echo -e "  ${BOLD}Next Steps${RESET}"
    echo -e "    ${CYAN}1.${RESET} Open in your editor to review and customize:"
    echo -e "       ${DIM}code ~/.natiliusrc${RESET}  or  ${DIM}nano ~/.natiliusrc${RESET}"
    echo -e "    ${CYAN}2.${RESET} Preview what will be installed:"
    echo -e "       ${DIM}natilius setup --check${RESET}"
    echo -e "    ${CYAN}3.${RESET} Run the setup when ready:"
    echo -e "       ${DIM}natilius setup${RESET}"
    echo ""

    if [ "$selected_profile" = "full" ]; then
        echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "  ${YELLOW}Tip:${RESET} 'full' includes everything! Open the config"
        echo -e "  to remove packages/apps you don't need."
        echo ""
    fi

    # Offer to install gum if not present
    if [ "$has_gum" = false ]; then
        echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "  ${DIM}Tip: Install 'gum' for a better experience:${RESET}"
        echo -e "  ${CYAN}→${RESET} brew install gum"
        echo ""
    fi
}

# Function to list modules
list_modules() {
    local GREEN='\033[1;32m'

    show_banner

    # Helper function to list modules in a category
    list_category() {
        local category_name="$1"
        local category_path="$2"

        if [ -d "$category_path" ]; then
            local count
            count=$(find "$category_path" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                echo -e "  ${BOLD}$category_name${RESET} ${DIM}($count)${RESET}"
                for module in "$category_path"/*.sh; do
                    if [ -f "$module" ]; then
                        module_name=$(basename "$module" .sh)
                        # Check if enabled
                        if printf '%s\n' "${ENABLED_MODULES[@]}" | grep -q "^.*/$module_name$"; then
                            echo -e "    ${GREEN}●${RESET} $module_name"
                        else
                            echo -e "    ${DIM}○${RESET} $module_name"
                        fi
                    fi
                done
                echo ""
            fi
        fi
    }

    list_category "System" "$NATILIUS_DIR/modules/system"
    list_category "Applications" "$NATILIUS_DIR/modules/applications"
    list_category "Dev Environments" "$NATILIUS_DIR/modules/dev_environments"
    list_category "IDE" "$NATILIUS_DIR/modules/ide"
    list_category "Preferences" "$NATILIUS_DIR/modules/preferences"

    # Other modules
    if [ -f "$NATILIUS_DIR/modules/dotfiles.sh" ]; then
        echo -e "  ${BOLD}Other${RESET}"
        if printf '%s\n' "${ENABLED_MODULES[@]}" | grep -q "^dotfiles$"; then
            echo -e "    ${GREEN}●${RESET} dotfiles"
        else
            echo -e "    ${DIM}○${RESET} dotfiles"
        fi
        echo ""
    fi

    echo -e "  ${DIM}● enabled  ○ disabled${RESET}"
    echo -e "  ${DIM}Configure in ~/.natiliusrc${RESET}"
    echo ""
}

# Function to run doctor diagnostics
run_doctor() {
    local GREEN='\033[1;32m'
    local RED='\033[1;31m'
    local YELLOW='\033[1;33m'

    show_banner
    echo -e "  ${BOLD}System Information${RESET}"
    echo -e "    ${DIM}macOS${RESET}       $(sw_vers -productVersion)"
    echo -e "    ${DIM}Arch${RESET}        $(uname -m)"
    echo -e "    ${DIM}Host${RESET}        $(hostname)"
    echo -e "    ${DIM}User${RESET}        $(whoami)"
    echo ""

    echo -e "  ${BOLD}Development Tools${RESET}"
    if xcode-select -p &> /dev/null; then
        echo -e "    ${GREEN}✓${RESET} Xcode CLI Tools"
    else
        echo -e "    ${RED}✗${RESET} Xcode CLI Tools ${DIM}(not installed)${RESET}"
    fi
    if command -v brew &> /dev/null; then
        echo -e "    ${GREEN}✓${RESET} Homebrew $(brew --version | head -n1 | awk '{print $2}')"
    else
        echo -e "    ${RED}✗${RESET} Homebrew ${DIM}(not installed)${RESET}"
    fi
    if command -v git &> /dev/null; then
        echo -e "    ${GREEN}✓${RESET} Git $(git --version | awk '{print $3}')"
    else
        echo -e "    ${RED}✗${RESET} Git ${DIM}(not installed)${RESET}"
    fi
    echo ""

    echo -e "  ${BOLD}Configuration${RESET}"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "    ${GREEN}✓${RESET} Config file found"
        echo -e "      ${DIM}$CONFIG_FILE${RESET}"
        echo -e "    ${GREEN}✓${RESET} ${#ENABLED_MODULES[@]} modules enabled"

        # Validate configuration schema
        echo ""
        echo -e "  ${BOLD}Config Validation${RESET}"
        # Source config validator
        if [ -f "$NATILIUS_DIR/lib/config_validator.sh" ]; then
            # shellcheck disable=SC1091
            source "$NATILIUS_DIR/lib/config_validator.sh"
            validate_config "$CONFIG_FILE"
        else
            echo -e "    ${YELLOW}⚠${RESET} Config validator not found"
        fi
    else
        echo -e "    ${RED}✗${RESET} Config file ${DIM}(not found)${RESET}"
    fi
    echo ""

    echo -e "  ${BOLD}System Status${RESET}"
    df -h / | awk -v dim="${DIM}" -v reset="${RESET}" -v green="${GREEN}" \
        'NR==2 {print "    " green "✓" reset " Disk: " $4 " available " dim "(" $5 " used)" reset}'

    if ping -c 1 -t 2 google.com &> /dev/null; then
        echo -e "    ${GREEN}✓${RESET} Network: Connected"
    else
        echo -e "    ${RED}✗${RESET} Network: ${DIM}(no connection)${RESET}"
    fi

    if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
        echo -e "    ${YELLOW}⚠${RESET} Sudo: Skipped"
    elif sudo -n true 2>/dev/null; then
        echo -e "    ${GREEN}✓${RESET} Sudo: Available"
    else
        echo -e "    ${YELLOW}⚠${RESET} Sudo: Requires password"
    fi

    if csrutil status | grep -q "enabled"; then
        echo -e "    ${GREEN}✓${RESET} SIP: Enabled"
    else
        echo -e "    ${YELLOW}⚠${RESET} SIP: Disabled"
    fi

    if [ "$(uname -m)" == "arm64" ]; then
        if /usr/bin/pgrep oahd >/dev/null 2>&1; then
            echo -e "    ${GREEN}✓${RESET} Rosetta 2: Installed"
        else
            echo -e "    ${YELLOW}⚠${RESET} Rosetta 2: ${DIM}(not installed)${RESET}"
        fi
    fi
    echo ""

    # MDM/Enterprise section
    echo -e "  ${BOLD}Enterprise/MDM${RESET}"
    local mdm_provider
    mdm_provider=$(get_mdm_provider)
    local mdm_provider_name
    mdm_provider_name=$(get_mdm_provider_name)

    # Show MDM enrollment status
    if is_mdm_enrolled; then
        echo -e "    ${GREEN}✓${RESET} MDM: Enrolled ${DIM}($mdm_provider_name)${RESET}"

        # Show MDM server URL
        local mdm_url
        mdm_url=$(get_mdm_server_url)
        if [ -n "$mdm_url" ]; then
            echo -e "      ${DIM}$mdm_url${RESET}"
        fi
    else
        echo -e "    ${DIM}○${RESET} MDM: Not enrolled"
    fi

    # Check DEP/ABM enrollment
    if is_dep_enrolled; then
        echo -e "    ${GREEN}✓${RESET} DEP/ABM: Enrolled"
    else
        echo -e "    ${DIM}○${RESET} DEP/ABM: Not enrolled"
    fi

    # Provider-specific checks
    case "$mdm_provider" in
        jamf)
            local jamf_version
            jamf_version=$(get_jamf_version)
            if [ -n "$jamf_version" ]; then
                echo -e "    ${GREEN}✓${RESET} Jamf Agent: $jamf_version"
            fi
            if has_jamf_connect; then
                echo -e "    ${GREEN}✓${RESET} Jamf Connect: Installed"
            fi
            if has_jamf_protect; then
                echo -e "    ${GREEN}✓${RESET} Jamf Protect: Running"
            fi
            ;;
        jumpcloud)
            if [ -f "/opt/jc/bin/jumpcloud-agent" ]; then
                echo -e "    ${GREEN}✓${RESET} JumpCloud Agent: Installed"
            fi
            local jc_key
            jc_key=$(get_jumpcloud_system_key)
            if [ -n "$jc_key" ]; then
                echo -e "      ${DIM}System Key: ${jc_key:0:8}...${RESET}"
            fi
            ;;
        kandji)
            echo -e "    ${GREEN}✓${RESET} Kandji Agent: Detected"
            ;;
        intune)
            if has_company_portal; then
                echo -e "    ${GREEN}✓${RESET} Company Portal: Installed"
            fi
            ;;
    esac
    echo ""

    # Collect recommendations
    local recommendations=()
    if ! xcode-select -p &> /dev/null; then
        recommendations+=("Install Xcode CLI: xcode-select --install")
    fi
    if ! command -v brew &> /dev/null; then
        recommendations+=("Install Homebrew: https://brew.sh")
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        recommendations+=("Create config: cp .natiliusrc.example ~/.natiliusrc")
    fi

    # Only show recommendations if there are any
    if [ ${#recommendations[@]} -gt 0 ]; then
        echo -e "  ${BOLD}Recommendations${RESET}"
        for rec in "${recommendations[@]}"; do
            echo -e "    ${CYAN}→${RESET} $rec"
        done
        echo ""
    fi
}

# Handle version flag
if [ "$SHOW_VERSION" = true ]; then
    show_version
    exit 0
fi

# Check if running on macOS (after help/version commands)
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "\033[1;31m✗\033[0m This script is only supported on macOS."
    echo -e "  \033[2mOther operating systems are not supported yet.\033[0m"
    exit 1
fi

# Handle specific commands
if [ "$COMMAND" = "doctor" ]; then
    run_doctor
    exit 0
fi

if [ "$COMMAND" = "modules" ]; then
    list_modules
    exit 0
fi

if [ "$COMMAND" = "profiles" ]; then
    list_profiles
    exit 0
fi

if [ "$COMMAND" = "init" ]; then
    run_init
    exit 0
fi

# After loading configuration and before any system-modifying operations:
if [ "$DRY_RUN" = true ]; then
    show_banner
    echo -e "  ${BOLD}Dry-run Mode${RESET}"
    echo -e "  ${DIM}No changes will be made to your system.${RESET}"
    echo ""

    # Show config source
    echo -e "  ${BOLD}Configuration${RESET}"
    if [ -n "$PROFILE" ]; then
        echo -e "    Profile: ${CYAN}$PROFILE${RESET}"
    fi
    echo -e "    ${DIM}$CONFIG_FILE${RESET}"
    echo ""

    # Show modules
    echo -e "  ${BOLD}Modules${RESET} ${DIM}(${#ENABLED_MODULES[@]})${RESET}"
    for module in "${ENABLED_MODULES[@]}"; do
        echo -e "    ${CYAN}●${RESET} $module"
    done
    echo ""

    # Show Homebrew taps if defined
    if [ ${#BREWTAPS[@]} -gt 0 ]; then
        echo -e "  ${BOLD}Homebrew Taps${RESET} ${DIM}(${#BREWTAPS[@]})${RESET}"
        for tap in "${BREWTAPS[@]}"; do
            echo -e "    ${DIM}$tap${RESET}"
        done
        echo ""
    fi

    # Show Homebrew packages if defined
    if [ ${#BREWPACKAGES[@]} -gt 0 ]; then
        echo -e "  ${BOLD}Homebrew Packages${RESET} ${DIM}(${#BREWPACKAGES[@]})${RESET}"
        pkg_count=0
        for pkg in "${BREWPACKAGES[@]}"; do
            if [ $pkg_count -lt 10 ]; then
                echo -e "    ${DIM}$pkg${RESET}"
            fi
            ((pkg_count++))
        done
        if [ ${#BREWPACKAGES[@]} -gt 10 ]; then
            echo -e "    ${DIM}... and $((${#BREWPACKAGES[@]} - 10)) more${RESET}"
        fi
        echo ""
    fi

    # Show Homebrew casks if defined
    if [ ${#BREWCASKS[@]} -gt 0 ]; then
        echo -e "  ${BOLD}Applications (Casks)${RESET} ${DIM}(${#BREWCASKS[@]})${RESET}"
        cask_count=0
        for cask in "${BREWCASKS[@]}"; do
            if [ $cask_count -lt 10 ]; then
                echo -e "    ${DIM}$cask${RESET}"
            fi
            ((cask_count++))
        done
        if [ ${#BREWCASKS[@]} -gt 10 ]; then
            echo -e "    ${DIM}... and $((${#BREWCASKS[@]} - 10)) more${RESET}"
        fi
        echo ""
    fi

    # Show language versions if dev environments enabled
    show_versions=false
    for module in "${ENABLED_MODULES[@]}"; do
        if [[ "$module" == dev_environments/* ]]; then
            show_versions=true
            break
        fi
    done

    if [ "$show_versions" = true ]; then
        echo -e "  ${BOLD}Language Versions${RESET}"
        [ -n "$PYTHONVER" ] && echo -e "    Python: ${DIM}$PYTHONVER${RESET}"
        [ -n "$NODEVER" ] && echo -e "    Node.js: ${DIM}$NODEVER${RESET}"
        [ -n "$RUBYVER" ] && echo -e "    Ruby: ${DIM}$RUBYVER${RESET}"
        [ -n "$GOVER" ] && echo -e "    Go: ${DIM}$GOVER${RESET}"
        [ -n "$JDKVER" ] && echo -e "    JDK: ${DIM}$JDKVER${RESET}"
        [ -n "$PHPVER" ] && echo -e "    PHP: ${DIM}$PHPVER${RESET}"
        echo ""
    fi

    # Show IDE settings (variables set in config file)
    # shellcheck disable=SC2153
    echo -e "  ${BOLD}IDE Settings${RESET}"
    [ "${INSTALL_VSCODE:-false}" = true ] && echo -e "    ${CYAN}●${RESET} VS Code"
    [ "${INSTALL_CURSOR:-false}" = true ] && echo -e "    ${CYAN}●${RESET} Cursor"
    [ "${INSTALL_JETBRAINS:-false}" = true ] && echo -e "    ${CYAN}●${RESET} JetBrains IDEs"
    [ "${INSTALL_SUBLIME:-false}" = true ] && echo -e "    ${CYAN}●${RESET} Sublime Text"
    [ "${INSTALL_ZED:-false}" = true ] && echo -e "    ${CYAN}●${RESET} Zed"
    echo ""

    # Show directories to create
    if [ ${#DIRS[@]} -gt 0 ]; then
        echo -e "  ${BOLD}Directories${RESET} ${DIM}(${#DIRS[@]})${RESET}"
        for dir in "${DIRS[@]}"; do
            echo -e "    ${DIM}$dir${RESET}"
        done
        echo ""
    fi

    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${DIM}Remove --check flag to apply changes.${RESET}"
    echo ""
    exit 0
fi

# Display styled banner first
show_banner
if [ -n "$PROFILE" ]; then
    echo -e "  ${BOLD}Profile:${RESET} $PROFILE"
    echo -e "    ${DIM}$CONFIG_FILE${RESET}"
else
    echo -e "  ${BOLD}Profile:${RESET} default"
fi
echo -e "  ${BOLD}Modules:${RESET} ${#ENABLED_MODULES[@]} enabled"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Show warning
RED='\033[1;31m'
echo -e "  ${RED}⚠${RESET}  ${BOLD}${RED}WARNING${RESET}"
echo -e "  ${DIM}This will make changes to your system.${RESET}"
echo -e "  ${DIM}Ensure you have a backup before proceeding.${RESET}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    read -r -p "  Press Enter to continue or Ctrl+C to abort..." | tee -a "$LOGFILE"
fi

echo ""

# Export logfile and rotate logs
export LOGFILE
rotate_logs

# Check for updates (silent by default, warnings only)
check_for_updates

echo ""

echo

# Skip sudo validation if SKIP_SUDO is true (for CI environments)
if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
    log_info "Skipping sudo validation ${DIM}(SKIP_SUDO=true)${RESET}"
elif [[ "${NONINTERACTIVE:-false}" == "true" ]]; then
    if [[ "${NATILIUS_DEBUG:-false}" == "true" ]]; then
        log_info "Debug: tty=$(tty 2>/dev/null || echo 'none')"
        log_info "Debug: stdin_is_tty=$([ -t 0 ] && echo yes || echo no)"
        log_info "Debug: stdout_is_tty=$([ -t 1 ] && echo yes || echo no)"
        log_info "Debug: sudo_n=$(command sudo -n true >/dev/null 2>&1 && echo ok || echo fail)"
        log_info "Debug: user=$(whoami) uid=$(id -u) euid=$(id -u)"
        log_info "Debug: sudo_tickets=$(sudo -l -n 2>/dev/null | head -n 1)"
    fi
    if (set +e; trap - ERR; command sudo -n true 2>/dev/null); then
        log_success "Sudo privileges validated ${DIM}(non-interactive)${RESET}"
        keep_sudo_alive
    else
        # If we still have a TTY, allow one-time refresh even in non-interactive mode.
        if [ -r /dev/tty ]; then
            log_info "Requesting sudo credentials ${DIM}(non-interactive)${RESET}"
            if (set +e; trap - ERR; command sudo -v < /dev/tty); then
                if command sudo -n true 2>/dev/null; then
                    log_success "Sudo privileges validated"
                    keep_sudo_alive
                else
                    log_error "Sudo credentials not available in non-interactive mode."
                    echo -e "  ${DIM}For unattended use, set SKIP_SUDO=true or configure NOPASSWD.${RESET}"
                    exit 1
                fi
            else
                log_error "Sudo credentials not available in non-interactive mode."
                echo -e "  ${DIM}Run once in an interactive terminal to authorize sudo.${RESET}"
                echo -e "  ${DIM}For unattended use, set SKIP_SUDO=true or configure NOPASSWD.${RESET}"
                exit 1
            fi
        else
            log_error "Sudo credentials not available in non-interactive mode."
            echo -e "  ${DIM}Run once in an interactive terminal to authorize sudo.${RESET}"
            echo -e "  ${DIM}For unattended use, set SKIP_SUDO=true or configure NOPASSWD.${RESET}"
            exit 1
        fi
    fi
else
    # Attempt to get sudo privileges
    # Check if we already have passwordless sudo
    if sudo -n true 2>/dev/null; then
        log_success "Sudo privileges validated ${DIM}(passwordless)${RESET}"
        keep_sudo_alive
    else
        log_info "Validating sudo privileges ${DIM}(password may be required)${RESET}"
        log_debug "Current user: $(whoami)"
        log_debug "Current directory: $(pwd)"
        log_debug "Script location: $0"
        log_debug "NATILIUS_DIR: $NATILIUS_DIR"
        log_debug "LOGFILE: $LOGFILE"
        if sudo -v; then
            log_success "Sudo privileges validated"
            keep_sudo_alive
        else
            log_error "Failed to validate sudo privileges"
            echo -e "  ${DIM}Ensure you have sudo access and try again.${RESET}"
            echo -e "  ${DIM}For unattended use, set SKIP_SUDO=true or configure NOPASSWD.${RESET}"
            exit 1
        fi
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
