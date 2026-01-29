#!/bin/bash

# natilius - Uninstall Script
# Removes Natilius and optionally its configuration

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"
BIN_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# ============================================================================
# Uninstall Functions
# ============================================================================
remove_cli() {
    log_info "Removing natilius command..."

    if [[ -f "$BIN_DIR/natilius" ]]; then
        sudo rm -f "$BIN_DIR/natilius"
        log_success "Removed $BIN_DIR/natilius"
    else
        log_info "No CLI found at $BIN_DIR/natilius"
    fi
}

remove_completions() {
    log_info "Removing shell completions..."

    # Bash completions
    local bash_locations=(
        "/opt/homebrew/etc/bash_completion.d/natilius"
        "/usr/local/etc/bash_completion.d/natilius"
        "$HOME/.local/share/bash-completion/completions/natilius"
    )

    for loc in "${bash_locations[@]}"; do
        if [[ -f "$loc" ]]; then
            if [[ "$loc" == "$HOME"* ]]; then
                rm -f "$loc"
            else
                sudo rm -f "$loc"
            fi
            log_success "Removed $loc"
        fi
    done

    # Zsh completions
    local zsh_locations=(
        "/opt/homebrew/share/zsh/site-functions/_natilius"
        "/usr/local/share/zsh/site-functions/_natilius"
        "$HOME/.zsh/completions/_natilius"
    )

    for loc in "${zsh_locations[@]}"; do
        if [[ -f "$loc" ]]; then
            if [[ "$loc" == "$HOME"* ]]; then
                rm -f "$loc"
            else
                sudo rm -f "$loc"
            fi
            log_success "Removed $loc"
        fi
    done
}

remove_natilius_home() {
    log_info "Removing Natilius installation..."

    if [[ -d "$NATILIUS_HOME" ]]; then
        rm -rf "$NATILIUS_HOME"
        log_success "Removed $NATILIUS_HOME"
    else
        log_info "No installation found at $NATILIUS_HOME"
    fi
}

remove_config() {
    local config_files=(
        "$HOME/.natiliusrc"
        "$HOME/.natiliusrc.base"
        "$HOME/.natiliusrc.minimal"
        "$HOME/.natiliusrc.devops"
        "$HOME/.natiliusrc.developer"
    )

    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]]; then
            rm -f "$config"
            log_success "Removed $config"
        fi
    done
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo ""
    echo -e "${YELLOW}🐚 Natilius Uninstaller${NC}"
    echo ""

    # Check if installed via Homebrew
    if command -v brew &> /dev/null && brew list natilius &> /dev/null 2>&1; then
        log_warning "Natilius was installed via Homebrew"
        echo "  Run: brew uninstall natilius"
        echo ""
        exit 0
    fi

    echo "This will remove:"
    echo "  - Natilius CLI command ($BIN_DIR/natilius)"
    echo "  - Natilius installation ($NATILIUS_HOME)"
    echo "  - Shell completions"
    echo ""

    read -r -p "Remove configuration files too? (~/.natiliusrc*) [y/N] " remove_configs
    echo ""

    read -r -p "Proceed with uninstall? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Uninstall cancelled"
        exit 0
    fi

    echo ""
    remove_cli
    remove_completions
    remove_natilius_home

    if [[ "$remove_configs" =~ ^[Yy]$ ]]; then
        log_info "Removing configuration files..."
        remove_config
    else
        log_info "Keeping configuration files (~/.natiliusrc*)"
    fi

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Natilius has been uninstalled${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Note: This does not remove software installed BY Natilius"
    echo "  (Homebrew packages, apps, dev environments, etc.)"
    echo ""
}

main "$@"
