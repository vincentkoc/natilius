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

# Homebrew Module

set -o pipefail

log_info "Setting up Homebrew..."

# Suppress Homebrew hints and per-install cleanup (we run cleanup later).
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_info "Homebrew not found. Installing..."
    if ! retry_network_operation /bin/bash -o pipefail -c "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash" | tee -a "$LOGFILE"; then
        log_error "Homebrew installation failed."
        return 1
    fi
    log_success "Homebrew installed"
    # Add Homebrew to PATH
    echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log_success "Homebrew already installed"
    if ! retry_network_operation brew update | tee -a "$LOGFILE"; then
        log_error "Homebrew update failed."
        return 1
    fi
fi

if ! brew analytics off; then
    log_error "Could not disable Homebrew analytics."
    return 1
fi
log_info "Homebrew analytics disabled"

# Homebrew Taps
echo -e | tee -a "$LOGFILE"
log_info "Tapping Homebrew repositories..."
if ! installed_taps="$(brew tap)"; then
    log_error "Could not read installed Homebrew taps."
    return 1
fi
for tap in "${BREWTAPS[@]}"; do
    if printf '%s\n' "$installed_taps" | grep -qxF "$tap"; then
        log_info "Tap already added [$tap]. Skipping."
    else
        log_info "Tapping repository [$tap]..."
        if ! retry_network_operation brew tap "$tap" | tee -a "$LOGFILE"; then
            log_error "Homebrew tap failed: $tap"
            return 1
        fi
    fi
done

# Homebrew Packages
echo -e | tee -a "$LOGFILE"
log_info "Installing Homebrew packages..."
if ! installed_formulas="$(brew list --formula)"; then
    log_error "Could not read installed Homebrew packages."
    return 1
fi
missing_formulas=()
for package in "${BREWPACKAGES[@]}"; do
    if printf '%s\n' "$installed_formulas" | grep -qxF "${package##*/}"; then
        continue
    fi
    missing_formulas+=("$package")
done
if [ "${#missing_formulas[@]}" -eq 0 ]; then
    log_info "All Homebrew packages already installed. Skipping."
else
    log_info "Installing ${#missing_formulas[@]} Homebrew packages..."
    if ! retry_network_operation brew install "${missing_formulas[@]}" | tee -a "$LOGFILE"; then
        log_error "Homebrew package installation failed: ${missing_formulas[*]}"
        return 1
    fi
fi

# Homebrew Casks
echo -e | tee -a "$LOGFILE"
log_info "Installing Homebrew casks..."
if ! installed_casks="$(brew list --cask)"; then
    log_error "Could not read installed Homebrew casks."
    return 1
fi
cask_failures=0
for cask in "${BREWCASKS[@]}"; do
    if printf '%s\n' "$installed_casks" | grep -qxF "${cask##*/}"; then
        continue
    fi
    log_info "Installing Homebrew cask [$cask]..."
    # Homebrew adopts identical artifacts and refuses a different existing app.
    # Do not force replacement or stop an app to make adoption succeed.
    if brew install --adopt --appdir="/Applications" --cask "$cask" | tee -a "$LOGFILE"; then
        log_success "Installed Homebrew cask: $cask"
    else
        log_error "Homebrew cask installation failed: $cask"
        cask_failures=$((cask_failures + 1))
    fi
done

if [ "$cask_failures" -ne 0 ]; then
    log_error "$cask_failures Homebrew cask installation(s) failed."
    return 1
fi

log_info "Skipping Homebrew cleanup here (handled by system cleanup)."
