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

log_info "Setting up Homebrew..."

# Suppress Homebrew hints and per-install cleanup (we run cleanup later).
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_info "Homebrew not found. Installing..."
    retry_network_operation /bin/bash -c "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash" | tee -a "$LOGFILE"
    log_success "Homebrew installed"
    # Add Homebrew to PATH
    echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log_success "Homebrew already installed"
    retry_network_operation brew update | tee -a "$LOGFILE"
fi

brew analytics off
log_info "Homebrew analytics disabled"

# Restart System Preferences
restart_system_preferences

# Homebrew Taps
echo -e | tee -a "$LOGFILE"
log_info "Tapping Homebrew repositories..."
for tap in "${BREWTAPS[@]}"; do
    if brew tap | grep -qx "$tap"; then
        log_info "Tap already added [$tap]. Skipping."
    else
        log_info "Tapping repository [$tap]..."
        retry_network_operation brew tap "$tap" | tee -a "$LOGFILE" || true
    fi
    sleep 1
done

# Homebrew Packages
echo -e | tee -a "$LOGFILE"
log_info "Installing Homebrew packages..."
installed_formulas="$(brew list --formula 2>/dev/null || true)"
missing_formulas=()
for package in "${BREWPACKAGES[@]}"; do
    if printf '%s\n' "$installed_formulas" | grep -qx "$package"; then
        continue
    fi
    missing_formulas+=("$package")
done
if [ "${#missing_formulas[@]}" -eq 0 ]; then
    log_info "All Homebrew packages already installed. Skipping."
else
    log_info "Installing ${#missing_formulas[@]} Homebrew packages..."
    retry_network_operation brew install "${missing_formulas[@]}" | tee -a "$LOGFILE" || true
fi

# Homebrew Casks
echo -e | tee -a "$LOGFILE"
log_info "Installing Homebrew casks..."
installed_casks="$(brew list --cask 2>/dev/null || true)"
missing_casks=()
for cask in "${BREWCASKS[@]}"; do
    if printf '%s\n' "$installed_casks" | grep -qx "$cask"; then
        continue
    fi
    missing_casks+=("$cask")
done
if [ "${#missing_casks[@]}" -eq 0 ]; then
    log_info "All Homebrew casks already installed. Skipping."
else
    log_info "Installing ${#missing_casks[@]} Homebrew casks..."
    retry_network_operation brew install --appdir="/Applications" --cask "${missing_casks[@]}" | tee -a "$LOGFILE" || true
fi

log_info "Skipping Homebrew cleanup here (handled by system cleanup)."
