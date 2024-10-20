#!/bin/bash

# Security Module

log_info "Applying security settings..."

############################
# Critical Security Tweaks
############################

# Disable Siri and analytics
defaults write com.apple.Siri "UserHasDeclinedEnable" -bool true
defaults write com.apple.Siri "StatusMenuVisible" -bool false
defaults write com.apple.assistant.support "Assistant Enabled" -bool false
log_success "Disabled Siri and analytics"

# Disable IPv6 on Wi-Fi and Ethernet adapters
log_info "Disabling IPv6 on Wi-Fi and Ethernet adapters..."
network_services=$(networksetup -listallnetworkservices | tail +2)
while IFS= read -r service; do
    if [[ "$service" != *"Bluetooth"* ]]; then
        sudo networksetup -setv6off "$service" 2>/dev/null || true
        log_success "Disabled IPv6 for: $service"
    fi
done <<< "$network_services"

# Enable Secure Keyboard Entry in Terminal.app
defaults write com.apple.terminal SecureKeyboardEntry -bool true
log_success "Enabled Secure Keyboard Entry in Terminal.app"

# Enable Gatekeeper (code signing verification)
sudo spctl --master-enable
log_success "Enabled Gatekeeper"

# Enable firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
log_success "Firewall enabled"

# Enable firewall logging
sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true
log_success "Firewall logging enabled"

# Enable stealth mode
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1
log_success "Stealth mode enabled"

# Disable Wake on LAN
sudo pmset -a womp 0
log_success "Disabled Wake on LAN"

# Enable FileVault encryption
if fdesetup status | grep -q "Off"; then
    log_info "Enabling FileVault (this may require a reboot)..."
    sudo fdesetup enable -user "$USER"
    log_success "FileVault enabled"
else
    log_info "FileVault is already enabled"
fi

############################
# Login Related Security Tweaks
############################

log_info "Applying login-related security settings..."

# Reveal system info at login screen when clicking the clock
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
log_success "Configured login screen to show system info on click"

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
log_success "Set requirement for password immediately after sleep or screen saver"

# Disable guest user
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
sudo sysadminctl -guestAccount off
log_success "Disabled guest user"

# Disable console login
sudo defaults write /Library/Preferences/com.apple.loginwindow DisableConsoleAccess -bool true
log_success "Disabled console login"

############################
# Update Related Security Tweaks
############################

log_info "Configuring update settings..."

# Enable automatic system updates
sudo softwareupdate --schedule on
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool true
log_success "Enabled automatic system updates"

# Check for updates daily instead of weekly
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
log_success "Set software update check frequency to daily"

############################
# Privacy Related Security Tweaks
############################

log_info "Applying privacy-related security settings..."

# Safari: Send 'Do Not Track' header
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
log_success "Enabled 'Do Not Track' in Safari"

# Disable potential DNS leaks
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
log_success "Disabled multicast DNS advertisements"

# Disable search data sharing in Safari
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
log_success "Disabled Safari search data sharing"

# Remove Google Software Updater if present
if [ -f ~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall ]; then
    ~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall --nuke
    log_success "Removed Google Software Updater"
else
    log_info "Google Software Updater not found"
fi

############################
# Restart Affected Applications
############################

log_info "Restarting affected applications to apply changes..."

for app in "Safari" "Terminal"; do
    killall "$app" &> /dev/null || true
    log_success "Restarted $app"
done
