#!/bin/bash

# Security Module

log_info "Applying security settings..."

# Disable Siri and analytics
defaults write com.apple.Siri "UserHasDeclinedEnable" -bool true
defaults write com.apple.Siri "StatusMenuVisible" -bool false
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# Enable firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
log_success "Firewall enabled"

# Enable stealth mode
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1
log_success "Stealth mode enabled"

# Enable FileVault encryption
if fdesetup status | grep -q "Off"; then
    sudo fdesetup enable -user "$USER"
    log_success "FileVault enabled"
else
    log_info "FileVault is already enabled"
fi
