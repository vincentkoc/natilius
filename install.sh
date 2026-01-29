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

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"
NATILIUS_REPO="https://github.com/vincentkoc/natilius.git"
NATILIUS_BRANCH="${NATILIUS_BRANCH:-main}"
BIN_DIR="/usr/local/bin"
SKIP_RUN="${SKIP_RUN:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;36m'
YELLOW='\033[0;33m'
CYAN='\033[1;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

show_banner() {
    echo ""
    echo -e "  ${CYAN}┃${NC} ${BOLD}🐚 natilius installer${NC}"
    echo -e "  ${CYAN}┃${NC} ${DIM}Mac Developer Environment Setup${NC}"
    echo ""
}

command_exists() { command -v "$1" &> /dev/null; }

# ============================================================================
# Pre-flight Checks
# ============================================================================
preflight() {
    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "Natilius only supports macOS"
        exit 1
    fi

    show_banner
    echo -e "${YELLOW}⚠️  Warning: Use at your own risk, ensure you have a backup${NC}"
    echo ""

    # Non-interactive mode for CI/CD
    if [[ "${CI:-false}" != "true" && "${NONINTERACTIVE:-false}" != "true" ]]; then
        read -r -s -p "Press enter to continue..."
        echo ""
    fi
}

# ============================================================================
# Install Dependencies
# ============================================================================
install_deps() {
    # Install Homebrew if not present
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        # Use NONINTERACTIVE for Homebrew if we're in non-interactive mode
        if [[ "${CI:-false}" == "true" || "${NONINTERACTIVE:-false}" == "true" ]]; then
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Add brew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed"
    fi

    # Install Git if not present
    if ! command_exists git; then
        log_info "Installing Git..."
        brew install git
        log_success "Git installed"
    fi
}

# ============================================================================
# Clone/Update Repository
# ============================================================================
install_natilius() {
    if [[ -d "$NATILIUS_HOME/.git" ]]; then
        log_info "Updating existing Natilius installation..."
        git -C "$NATILIUS_HOME" fetch origin "$NATILIUS_BRANCH"
        git -C "$NATILIUS_HOME" reset --hard "origin/$NATILIUS_BRANCH"
        log_success "Natilius updated"
    else
        log_info "Cloning Natilius repository..."
        git clone --branch "$NATILIUS_BRANCH" "$NATILIUS_REPO" "$NATILIUS_HOME"
        log_success "Natilius cloned to $NATILIUS_HOME"
    fi
}

# ============================================================================
# Setup CLI Command
# ============================================================================
setup_cli() {
    log_info "Setting up 'natilius' command..."

    # Use user-local bin if SKIP_SUDO is set
    if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
        BIN_DIR="$HOME/.local/bin"
    fi

    # Create bin directory if needed
    if [[ ! -d "$BIN_DIR" ]]; then
        if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
            mkdir -p "$BIN_DIR"
        else
            sudo mkdir -p "$BIN_DIR"
        fi
    fi

    # Create wrapper script
    local wrapper="$BIN_DIR/natilius"

    if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
        cat > "$wrapper" << 'WRAPPER'
#!/bin/bash
# Natilius CLI wrapper
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"
exec "$NATILIUS_HOME/natilius.sh" "$@"
WRAPPER
        chmod +x "$wrapper"
    else
        sudo tee "$wrapper" > /dev/null << 'WRAPPER'
#!/bin/bash
# Natilius CLI wrapper
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"
exec "$NATILIUS_HOME/natilius.sh" "$@"
WRAPPER
        sudo chmod +x "$wrapper"
    fi

    log_success "Command 'natilius' installed to $BIN_DIR"
}

# ============================================================================
# Install Shell Completions
# ============================================================================
install_completions() {
    log_info "Installing shell completions..."

    # Always install user-local completions
    mkdir -p "$HOME/.local/share/bash-completion/completions"
    cp "$NATILIUS_HOME/completions/natilius-completion.bash" "$HOME/.local/share/bash-completion/completions/natilius"

    mkdir -p "$HOME/.zsh/completions"
    cp "$NATILIUS_HOME/completions/natilius-completion.zsh" "$HOME/.zsh/completions/_natilius"

    # Skip system-wide completions if SKIP_SUDO
    if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
        log_success "User completions installed (SKIP_SUDO mode)"
        return
    fi

    # Bash completions (system-wide)
    local bash_completion_dir
    if [[ -d "/opt/homebrew/etc/bash_completion.d" ]]; then
        bash_completion_dir="/opt/homebrew/etc/bash_completion.d"
    elif [[ -d "/usr/local/etc/bash_completion.d" ]]; then
        bash_completion_dir="/usr/local/etc/bash_completion.d"
    fi

    if [[ -n "${bash_completion_dir:-}" ]]; then
        sudo cp "$NATILIUS_HOME/completions/natilius-completion.bash" "$bash_completion_dir/natilius" 2>/dev/null || true
    fi

    # Zsh completions (system-wide)
    local zsh_completion_dir
    if [[ -d "/opt/homebrew/share/zsh/site-functions" ]]; then
        zsh_completion_dir="/opt/homebrew/share/zsh/site-functions"
    elif [[ -d "/usr/local/share/zsh/site-functions" ]]; then
        zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fi

    if [[ -n "${zsh_completion_dir:-}" ]]; then
        sudo cp "$NATILIUS_HOME/completions/natilius-completion.zsh" "$zsh_completion_dir/_natilius" 2>/dev/null || true
    fi

    log_success "Shell completions installed"
}

# ============================================================================
# Copy Default Config
# ============================================================================
setup_config() {
    if [[ ! -f "$HOME/.natiliusrc" ]]; then
        log_info "Creating default configuration..."
        cp "$NATILIUS_HOME/.natiliusrc.example" "$HOME/.natiliusrc"
        log_success "Config created at ~/.natiliusrc"
        log_info "Edit ~/.natiliusrc to customize your setup"
    else
        log_info "Existing ~/.natiliusrc found, keeping it"
    fi
}

# ============================================================================
# Print Success Message
# ============================================================================
print_success() {
    echo ""
    echo -e "  ${CYAN}┃${NC} ${GREEN}✓${NC} ${BOLD}Natilius installed successfully!${NC}"
    echo ""
    echo -e "  ${BOLD}Quick Start${NC}"
    echo -e "    ${DIM}natilius --help${NC}        Show available commands"
    echo -e "    ${DIM}natilius doctor${NC}        Check system readiness"
    echo -e "    ${DIM}natilius --check${NC}       Dry run (preview changes)"
    echo -e "    ${DIM}natilius setup${NC}         Run full setup"
    echo ""
    echo -e "  ${BOLD}Configuration${NC}"
    echo -e "    Edit ${CYAN}~/.natiliusrc${NC} to customize your setup"
    echo -e "    Use profiles: ${DIM}natilius --profile devops${NC}"
    echo ""
    echo -e "  ${DIM}Note: Restart your shell or run 'hash -r' to use 'natilius'${NC}"
    echo ""
}

# ============================================================================
# Main
# ============================================================================
main() {
    preflight
    install_deps
    install_natilius
    setup_cli
    install_completions
    setup_config
    print_success

    # Optionally run setup immediately (skip in non-interactive mode)
    if [[ "$SKIP_RUN" != "true" && "${CI:-false}" != "true" && "${NONINTERACTIVE:-false}" != "true" ]]; then
        echo ""
        read -r -p "Run natilius setup now? [y/N] " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            "$NATILIUS_HOME/natilius.sh"
        fi
    fi
}

main "$@"
