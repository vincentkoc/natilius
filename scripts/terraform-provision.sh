#!/bin/bash
# Natilius Terraform Provisioning Script
# Designed for use with Terraform provisioners (local-exec, remote-exec)
#
# Usage:
#   ./terraform-provision.sh [PROFILE]
#   ./terraform-provision.sh devops
#   ./terraform-provision.sh minimal
#
# Environment Variables:
#   NATILIUS_BRANCH    - Branch to use (default: main)
#   NONINTERACTIVE     - Set to 'true' for no prompts (default: true)
#   SKIP_SUDO          - Set to 'true' to skip sudo operations (default: false)
#   DRY_RUN            - Set to 'true' to run in check mode
#   QUIET_MODE         - Set to 'true' for minimal output
#
# Prerequisites:
#   - SSH access to the Mac
#   - For passwordless operation: configure NOPASSWD sudo or set SKIP_SUDO=true

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
PROFILE="${1:-minimal}"
NATILIUS_BRANCH="${NATILIUS_BRANCH:-main}"
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"

# Default to non-interactive for automation
export NONINTERACTIVE="${NONINTERACTIVE:-true}"
export CI="${CI:-true}"
export SKIP_SUDO="${SKIP_SUDO:-false}"

# Colors
CYAN='\033[1;36m'
GREEN='\033[0;32m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# Logging
# ============================================================================
log_info()  { echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') $1"; }
log_ok()    { echo "[OK]    $(date '+%Y-%m-%d %H:%M:%S') $1"; }
log_warn()  { echo "[WARN]  $(date '+%Y-%m-%d %H:%M:%S') $1"; }
log_error() { echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2; }

show_banner() {
    echo ""
    echo -e "  ${CYAN}┃${NC} ${BOLD}🐚 natilius provisioner${NC}"
    echo -e "  ${CYAN}┃${NC} ${DIM}Mac Developer Environment Setup${NC}"
    echo ""
}

# ============================================================================
# Preflight Checks
# ============================================================================
preflight_check() {
    log_info "Running preflight checks..."

    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script only runs on macOS"
        exit 1
    fi

    # Check network connectivity
    if ! curl -fsS --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        log_error "No network connectivity to GitHub"
        exit 1
    fi

    # Check if Xcode CLT is installed (required for git/brew)
    if ! xcode-select -p &> /dev/null; then
        log_info "Installing Xcode Command Line Tools..."
        # Try non-interactive install first
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        softwareupdate -i -a 2>/dev/null || true
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

        # Fallback to interactive if needed
        if ! xcode-select -p &> /dev/null; then
            xcode-select --install 2>/dev/null || true
            log_warn "Xcode CLT installation triggered - may need manual confirmation"
            # Wait for installation (max 10 minutes)
            local timeout=600
            while ! xcode-select -p &> /dev/null && [[ $timeout -gt 0 ]]; do
                sleep 10
                timeout=$((timeout - 10))
            done
        fi
        log_ok "Xcode CLT installed"
    fi

    log_ok "Preflight checks passed"
}

# ============================================================================
# Install Homebrew
# ============================================================================
install_homebrew() {
    if command -v brew &> /dev/null; then
        log_ok "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."

    # Non-interactive Homebrew install
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for current session and persist to shell config
    local brew_path=""
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        brew_path="/opt/homebrew/bin/brew"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        brew_path="/usr/local/bin/brew"
    fi

    if [[ -n "$brew_path" ]]; then
        # Add to current session
        eval "$($brew_path shellenv)"

        # Persist to zsh config
        local shellenv_cmd="eval \"\$($brew_path shellenv)\""
        if [[ -f "$HOME/.zprofile" ]]; then
            if ! grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
                {
                    echo ""
                    echo "# Homebrew"
                    echo "$shellenv_cmd"
                } >> "$HOME/.zprofile"
            fi
        else
            {
                echo "# Homebrew"
                echo "$shellenv_cmd"
            } > "$HOME/.zprofile"
        fi

        # Persist to bash config
        if [[ -f "$HOME/.bash_profile" ]] || [[ -f "$HOME/.bashrc" ]]; then
            local bash_config="$HOME/.bash_profile"
            [[ ! -f "$bash_config" ]] && bash_config="$HOME/.bashrc"
            if ! grep -q "brew shellenv" "$bash_config" 2>/dev/null; then
                {
                    echo ""
                    echo "# Homebrew"
                    echo "$shellenv_cmd"
                } >> "$bash_config"
            fi
        fi
    fi

    log_ok "Homebrew installed"
}

# ============================================================================
# Install Natilius
# ============================================================================
install_natilius() {
    log_info "Installing Natilius..."

    # Ensure git is available
    if ! command -v git &> /dev/null; then
        log_info "Installing git via Homebrew..."
        brew install git
    fi

    # Clone or update repository
    if [[ -d "$NATILIUS_HOME/.git" ]]; then
        log_info "Updating existing Natilius installation..."
        cd "$NATILIUS_HOME"
        git fetch origin "$NATILIUS_BRANCH"
        git reset --hard "origin/$NATILIUS_BRANCH"
    else
        log_info "Cloning Natilius repository..."
        rm -rf "$NATILIUS_HOME"
        git clone --branch "$NATILIUS_BRANCH" \
            "https://github.com/vincentkoc/natilius.git" "$NATILIUS_HOME"
    fi

    log_ok "Natilius installed at $NATILIUS_HOME"
}

# ============================================================================
# Setup Profile
# ============================================================================
setup_profile() {
    log_info "Setting up profile: $PROFILE"

    local profile_source="$NATILIUS_HOME/profiles/${PROFILE}.natiliusrc"
    local base_source="$NATILIUS_HOME/profiles/base.natiliusrc"

    # Install base profile first (if exists)
    if [[ -f "$base_source" ]]; then
        cp "$base_source" "$HOME/.natiliusrc.base"
        log_ok "Base profile installed"
    fi

    # Install selected profile
    if [[ -f "$profile_source" ]]; then
        cp "$profile_source" "$HOME/.natiliusrc"
        log_ok "Profile '$PROFILE' installed"
    else
        log_error "Profile not found: $profile_source"
        log_info "Available profiles:"
        # shellcheck disable=SC2011
        ls "$NATILIUS_HOME/profiles/"*.natiliusrc 2>/dev/null | xargs -I {} basename {} .natiliusrc || true
        exit 1
    fi
}

# ============================================================================
# Run Natilius
# ============================================================================
run_natilius() {
    log_info "Running Natilius setup..."

    cd "$NATILIUS_HOME"

    # Build command with options
    local cmd="./natilius.sh setup"

    if [[ "${QUIET_MODE:-false}" == "true" ]]; then
        cmd="$cmd --quiet"
    fi

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        cmd="$cmd --check"
    fi

    # Set environment for non-interactive
    export NONINTERACTIVE=true
    export SKIP_SUDO="${SKIP_SUDO:-false}"

    # Execute
    log_info "Executing: $cmd"
    eval "$cmd"

    log_ok "Natilius setup complete"
}

# ============================================================================
# Main
# ============================================================================
main() {
    show_banner
    log_info "Profile: $PROFILE"
    log_info "Branch: $NATILIUS_BRANCH"
    log_info "Non-interactive: ${NONINTERACTIVE:-true}"
    log_info "Skip sudo: ${SKIP_SUDO:-false}"

    start_sudo_keepalive() {
        while true; do
            sudo -n -v >/dev/null 2>&1
            sleep 50
            kill -0 "$PPID" 2>/dev/null || exit
        done
    }

    # Get sudo credentials upfront for Homebrew and keep them alive
    if [[ "${SKIP_SUDO:-false}" != "true" ]]; then
        log_info "Requesting sudo credentials (will be cached for the entire run)..."
        if ! sudo -v; then
            log_error "Failed to obtain sudo credentials."
            echo -e "  ${DIM}Ensure you have sudo access and try again.${RESET}"
            echo -e "  ${DIM}For unattended use, set SKIP_SUDO=true or configure NOPASSWD.${RESET}"
            exit 1
        fi
        start_sudo_keepalive 2>/dev/null &
        SUDO_KEEPALIVE_PID=$!
        trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
    fi

    preflight_check
    install_homebrew
    install_natilius
    setup_profile

    # Get sudo credentials right before Natilius (Homebrew may have reset them)
    if [[ "${SKIP_SUDO:-false}" != "true" ]]; then
        if ! sudo -n true 2>/dev/null; then
            log_info "Requesting sudo credentials for Natilius (will be cached for the rest of the run)..."
            if ! sudo -v; then
                log_error "Failed to obtain sudo credentials."
                echo -e "  ${DIM}Ensure you have sudo access and try again.${RESET}"
                echo -e "  ${DIM}For unattended use, set SKIP_SUDO=true or configure NOPASSWD.${RESET}"
                exit 1
            fi
        fi
        export NATILIUS_SUDO_VALIDATED=true
    fi

    run_natilius

    echo ""
    echo -e "  ${CYAN}┃${NC} ${GREEN}✓${NC} ${BOLD}Provisioning Complete${NC}"
    echo ""
}

main "$@"
