#!/bin/bash

# Homebrew Module

log_info "Setting up Homebrew..."

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee -a "$LOGFILE"
    log_success "Homebrew installed"
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log_success "Homebrew already installed"
    brew update | tee -a "$LOGFILE"
fi

brew analytics off
log_info "Homebrew analytics disabled"

# Restart System Preferences
restart_system_preferences

# Homebrew Taps
echo -e | tee -a "$LOGFILE"
log_info "Tapping Homebrew repositories..."
for tap in "${BREWTAPS[@]}"; do
    log_info "Tapping repository [$tap]..."
    brew tap "$tap" | tee -a "$LOGFILE" || true
    sleep 1
done

# Homebrew Packages
echo -e | tee -a "$LOGFILE"
log_info "Installing Homebrew packages..."
for package in "${BREWPACKAGES[@]}"; do
    log_info "Installing package [$package]..."
    brew install "$package" | tee -a "$LOGFILE" || true
    echo -e
    sleep 2
done

# Homebrew Casks
echo -e | tee -a "$LOGFILE"
log_info "Installing Homebrew casks..."
for cask in "${BREWCASKS[@]}"; do
    log_info "Installing cask [$cask]..."
    brew install --appdir="/Applications" --cask "$cask" | tee -a "$LOGFILE" || true
    echo -e
    sleep 2
done

log_info "Running post-install cleanup..."
brew cleanup | tee -a "$LOGFILE"

