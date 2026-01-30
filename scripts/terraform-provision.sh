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
SCRIPT_URL="${SCRIPT_URL:-https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh}"

# Default to non-interactive for automation
export NONINTERACTIVE="${NONINTERACTIVE:-true}"
export CI="${CI:-true}"
export SKIP_SUDO="${SKIP_SUDO:-false}"
export NATILIUS_DEBUG="${NATILIUS_DEBUG:-false}"
export SET_NOPASSWD="${SET_NOPASSWD:-false}"

SUDOERS_FILE=""

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

setup_nopasswd_whitelist() {
    if [[ "${SET_NOPASSWD:-false}" != "true" ]]; then
        return
    fi

    if [[ "${SKIP_SUDO:-false}" == "true" ]]; then
        log_warn "SET_NOPASSWD=true but SKIP_SUDO=true; skipping sudoers setup."
        return
    fi

    local user="${SUDOERS_USER:-$(id -un)}"
    local ts
    ts="$(date +%s)"
    SUDOERS_FILE="/etc/sudoers.d/natilius-terraform-${ts}"

    log_info "Configuring temporary sudo NOPASSWD whitelist for user: $user"
    # Clean up any stale natilius terraform sudoers files to avoid alias collisions.
    sudo /bin/rm -f /etc/sudoers.d/natilius-terraform-* 2>/dev/null || true
    sudo /usr/bin/tee "$SUDOERS_FILE" >/dev/null <<'EOF'
# Managed by natilius terraform-provision.sh (temporary)
Defaults:__USER__ !authenticate
Cmnd_Alias NATILIUS_CMDS___TS__ = \
    /usr/sbin/chown, /bin/mkdir, /usr/bin/tee, /bin/chmod, \
    /usr/sbin/softwareupdate, /usr/sbin/networksetup, /usr/sbin/pmset, \
    /usr/sbin/spctl, /usr/bin/pkill, /usr/libexec/ApplicationFirewall/socketfilterfw, \
    /usr/sbin/fdesetup, /usr/bin/defaults, /usr/sbin/sysadminctl, \
    /usr/sbin/shutdown, /usr/sbin/tmutil, /usr/bin/find, /bin/rm
__USER__ ALL=(ALL) NOPASSWD: NATILIUS_CMDS___TS__
EOF

    sudo /bin/chmod 0440 "$SUDOERS_FILE"
    sudo /usr/sbin/visudo -cf "$SUDOERS_FILE" >/dev/null || {
        log_error "Sudoers whitelist validation failed; removing $SUDOERS_FILE"
        sudo /bin/rm -f "$SUDOERS_FILE"
        SUDOERS_FILE=""
        exit 1
    }

    # Replace placeholder with actual user and unique alias suffix
    sudo /usr/bin/sed -i '' "s/__USER__/${user}/g; s/__TS__/${ts}/g" "$SUDOERS_FILE"
    log_ok "Temporary sudo whitelist enabled (${SUDOERS_FILE})"
}

cleanup_nopasswd_whitelist() {
    if [[ -n "$SUDOERS_FILE" ]]; then
        sudo /bin/rm -f "$SUDOERS_FILE" 2>/dev/null || true
        log_ok "Removed temporary sudo whitelist (${SUDOERS_FILE})"
        SUDOERS_FILE=""
    fi
}

# If stdin isn't a TTY, re-run inside a PTY so sudo timestamps work reliably.
# When SET_NOPASSWD=true, we should avoid PTY re-exec entirely (no prompts needed).
if [[ "${SET_NOPASSWD:-false}" != "true" && -z "${NATILIUS_IN_PTY:-}" && ! -t 0 && -r /dev/tty && -n "$(command -v script 2>/dev/null)" ]]; then
    log_info "PTY bootstrap: stdin is not a TTY; re-executing inside script PTY"
    log_info "PTY bootstrap: /dev/tty=$(stat -f '%Sp %z %Sm %N' /dev/tty 2>/dev/null || echo 'unknown')"
    log_info "PTY bootstrap: tty=$(tty 2>/dev/null || echo 'none')"
    log_info "PTY bootstrap: script=$(command -v script 2>/dev/null || echo 'missing')"
    log_info "PTY bootstrap: script_ver=$(script -V 2>/dev/null || echo 'unknown')"
    export NATILIUS_IN_PTY=1
    script -q /dev/null /bin/sh -c "tmp=\$(mktemp -t natilius.XXXXXX.sh) && curl -fsSL \"$SCRIPT_URL\" > \"\$tmp\" && SCRIPT_URL=\"$SCRIPT_URL\" NATILIUS_IN_PTY=1 bash \"\$tmp\" \"$PROFILE\"; rc=\$?; rm -f \"\$tmp\"; exit \$rc" < /dev/tty
    exit $?
fi

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

    # Homebrew install: allow sudo prompt when a TTY is available (unless NOPASSWD is enabled)
    if [[ "${SET_NOPASSWD:-false}" == "true" ]]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    elif [ -t 0 ] && [[ "${SKIP_SUDO:-false}" != "true" ]]; then
        env -u NONINTERACTIVE -u CI /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

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
    if [[ "${NATILIUS_DEBUG:-false}" == "true" ]]; then
        log_info "Debug: tty=$(tty 2>/dev/null || echo 'none')"
        log_info "Debug: stdin_is_tty=$([ -t 0 ] && echo yes || echo no)"
        log_info "Debug: stdout_is_tty=$([ -t 1 ] && echo yes || echo no)"
        log_info "Debug: sudo_n=$(sudo -n true >/dev/null 2>&1 && echo ok || echo fail)"
    fi

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
    # In automation, skip system updates unless explicitly enabled.
    if [[ "${NONINTERACTIVE:-false}" == "true" ]]; then
        export SKIP_SYSTEM_UPDATES="${SKIP_SYSTEM_UPDATES:-true}"
    fi

    # Execute
    log_info "Executing: $cmd"
    if [[ "${NATILIUS_DEBUG:-false}" == "true" ]]; then
        log_info "Debug: env NONINTERACTIVE=$NONINTERACTIVE SKIP_SUDO=$SKIP_SUDO CI=$CI NATILIUS_IN_PTY=${NATILIUS_IN_PTY:-}"
    fi
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

    preflight_check
    setup_nopasswd_whitelist
    install_homebrew
    install_natilius
    setup_profile

    if [[ "${SKIP_SUDO:-false}" != "true" ]]; then
        if sudo -n true >/dev/null 2>&1; then
            log_info "Sudo ticket available after Homebrew."
        else
            if [ -t 0 ]; then
                log_warn "Sudo ticket missing after Homebrew; refreshing credentials..."
                # shellcheck disable=SC2024  # stdin redirect is intentional for sudo prompt
                if ! sudo -v < /dev/tty; then
                    log_error "Failed to refresh sudo credentials after Homebrew."
                    exit 1
                fi
                if sudo -n true >/dev/null 2>&1; then
                    log_info "Sudo ticket refreshed after Homebrew."
                else
                    log_error "Sudo ticket still unavailable after refresh."
                    exit 1
                fi
            else
                log_warn "Sudo ticket missing after Homebrew and no TTY available to refresh."
            fi
        fi
    fi

    run_natilius

    echo ""
    echo -e "  ${CYAN}┃${NC} ${GREEN}✓${NC} ${BOLD}Provisioning Complete${NC}"
    echo ""

    if [[ -n "$SUDOERS_FILE" ]]; then
        echo -e "  ${DIM}To remove the sudo whitelist manually:${NC}"
        echo -e "  ${DIM}  sudo rm -f $SUDOERS_FILE${NC}"
    fi
}

trap cleanup_nopasswd_whitelist EXIT
main "$@"
