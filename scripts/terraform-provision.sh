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
#   NATILIUS_REPO_URL  - Override the repository URL (default: GitHub main)
#   NATILIUS_BRANCH    - Branch to use (default: main)
#   SKIP_SUDO          - Set to 'true' to skip sudo validation (CI/CD)
#   DRY_RUN            - Set to 'true' to run in check mode
#   QUIET_MODE         - Set to 'true' for minimal output

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
PROFILE="${1:-minimal}"
NATILIUS_REPO_URL="${NATILIUS_REPO_URL:-https://raw.githubusercontent.com/vincentkoc/natilius/main}"
NATILIUS_BRANCH="${NATILIUS_BRANCH:-main}"
NATILIUS_HOME="${NATILIUS_HOME:-$HOME/.natilius}"

# ============================================================================
# Logging
# ============================================================================
log_info()  { echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') $1"; }
log_ok()    { echo "[OK]    $(date '+%Y-%m-%d %H:%M:%S') $1"; }
log_error() { echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2; }

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
        xcode-select --install 2>/dev/null || true
        # Wait for installation
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        log_ok "Xcode CLT installed"
    fi

    log_ok "Preflight checks passed"
}

# ============================================================================
# Install Natilius
# ============================================================================
install_natilius() {
    log_info "Installing Natilius..."

    # Clone or update repository
    if [[ -d "$NATILIUS_HOME" ]]; then
        log_info "Updating existing Natilius installation..."
        cd "$NATILIUS_HOME"
        git fetch origin "$NATILIUS_BRANCH"
        git reset --hard "origin/$NATILIUS_BRANCH"
    else
        log_info "Cloning Natilius repository..."
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
        find "$NATILIUS_HOME/profiles/" -name "*.natiliusrc" -print0 2>/dev/null | xargs -0 -n1 basename | sed 's/.natiliusrc$//'
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
    local cmd="./natilius.sh"

    if [[ "${QUIET_MODE:-false}" == "true" ]]; then
        cmd="$cmd --quiet"
    fi

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        cmd="$cmd --check"
    fi

    # Execute
    log_info "Executing: $cmd"
    eval "$cmd"

    log_ok "Natilius setup complete"
}

# ============================================================================
# Main
# ============================================================================
main() {
    log_info "=== Natilius Terraform Provisioning ==="
    log_info "Profile: $PROFILE"
    log_info "Repository: $NATILIUS_REPO_URL"

    preflight_check
    install_natilius
    setup_profile
    run_natilius

    log_ok "=== Provisioning Complete ==="
}

main "$@"
