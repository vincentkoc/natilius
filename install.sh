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
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

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

    log_info "Starting Natilius installation..."
    echo ""
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
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

    # Create bin directory if needed
    if [[ ! -d "$BIN_DIR" ]]; then
        sudo mkdir -p "$BIN_DIR"
    fi

    # Create wrapper script (more robust than symlink for relative paths)
    local wrapper="$BIN_DIR/natilius"

    sudo tee "$wrapper" > /dev/null << 'WRAPPER'
#!/bin/bash
# Natilius CLI wrapper
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"
exec "$NATILIUS_HOME/natilius.sh" "$@"
WRAPPER

    sudo chmod +x "$wrapper"
    log_success "Command 'natilius' installed to $BIN_DIR"
}

# ============================================================================
# Install Shell Completions
# ============================================================================
install_completions() {
    log_info "Installing shell completions..."

    # Bash completions
    local bash_completion_dir
    if [[ -d "/opt/homebrew/etc/bash_completion.d" ]]; then
        bash_completion_dir="/opt/homebrew/etc/bash_completion.d"
    elif [[ -d "/usr/local/etc/bash_completion.d" ]]; then
        bash_completion_dir="/usr/local/etc/bash_completion.d"
    fi

    if [[ -n "${bash_completion_dir:-}" ]]; then
        sudo cp "$NATILIUS_HOME/completions/natilius-completion.bash" "$bash_completion_dir/natilius"
        log_success "Bash completions installed"
    fi

    # Zsh completions
    local zsh_completion_dir
    if [[ -d "/opt/homebrew/share/zsh/site-functions" ]]; then
        zsh_completion_dir="/opt/homebrew/share/zsh/site-functions"
    elif [[ -d "/usr/local/share/zsh/site-functions" ]]; then
        zsh_completion_dir="/usr/local/share/zsh/site-functions"
    fi

    if [[ -n "${zsh_completion_dir:-}" ]]; then
        sudo cp "$NATILIUS_HOME/completions/natilius-completion.zsh" "$zsh_completion_dir/_natilius"
        log_success "Zsh completions installed"
    fi

    # User-local completions (fallback)
    mkdir -p "$HOME/.local/share/bash-completion/completions"
    cp "$NATILIUS_HOME/completions/natilius-completion.bash" "$HOME/.local/share/bash-completion/completions/natilius"

    mkdir -p "$HOME/.zsh/completions"
    cp "$NATILIUS_HOME/completions/natilius-completion.zsh" "$HOME/.zsh/completions/_natilius"
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
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🐚 Natilius installed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Quick start:"
    echo "    natilius --help        # Show available commands"
    echo "    natilius doctor        # Check system readiness"
    echo "    natilius --check       # Dry run (preview changes)"
    echo "    natilius setup         # Run full setup"
    echo ""
    echo "  Configuration:"
    echo "    Edit ~/.natiliusrc to customize your setup"
    echo "    Use profiles: natilius --profile devops"
    echo ""
    echo "  Note: Restart your shell or run 'hash -r' to use 'natilius'"
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

    # Optionally run setup immediately
    if [[ "$SKIP_RUN" != "true" ]]; then
        echo ""
        read -r -p "Run natilius setup now? [y/N] " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            "$NATILIUS_HOME/natilius.sh"
        fi
    fi
}

main "$@"
