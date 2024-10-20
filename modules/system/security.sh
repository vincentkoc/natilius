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
network_services=$(networksetup -listallnetworkservices | tail -n +2)
while IFS= read -r service; do
    if [[ "$service" != *"Bluetooth"* ]]; then
        sudo networksetup -setv6off "$service" 2>/dev/null || log_warning "Failed to disable IPv6 for: $service"
        log_success "Disabled IPv6 for: $service"
    fi
done <<< "$network_services"

# Enable Secure Keyboard Entry in Terminal.app
defaults write com.apple.terminal SecureKeyboardEntry -bool true
log_success "Enabled Secure Keyboard Entry in Terminal.app"

# Enable Gatekeeper (code signing verification)
sudo spctl --master-enable
log_success "Enabled Gatekeeper"

# Configure and enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo pkill -HUP socketfilterfw
log_success "Firewall enabled with logging and stealth mode"

# Disable Wake on LAN
sudo pmset -a womp 0
log_success "Disabled Wake on LAN"

# Enable FileVault encryption
if ! fdesetup status | grep -q "FileVault is On."; then
    log_info "Enabling FileVault (this may require a reboot)..."
    sudo fdesetup enable -user "$USER" || log_error "Failed to enable FileVault"
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

# Disable guest user and console login
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
sudo sysadminctl -guestAccount off
sudo defaults write /Library/Preferences/com.apple.loginwindow DisableConsoleAccess -bool true
log_success "Disabled guest user and console login"

############################
# Update Related Security Tweaks
############################

log_info "Configuring update settings..."

# Enable automatic system updates
sudo softwareupdate --schedule on
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool true
log_success "Enabled automatic system updates"

# Check for updates daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
log_success "Set software update check frequency to daily"

############################
# Privacy Related Security Tweaks
############################

log_info "Applying privacy-related security settings..."

# Safari: Send 'Do Not Track' header and disable search suggestions
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
log_success "Configured Safari privacy settings"

# Disable potential DNS leaks
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
log_success "Disabled multicast DNS advertisements"

# Remove Google Software Updater if present
google_updater="$HOME/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall"
if [ -f "$google_updater" ]; then
    "$google_updater" --nuke
    log_success "Removed Google Software Updater"
else
    log_info "Google Software Updater not found"
fi

############################
# Additional Security Measures
############################

# Enable Secure Empty Trash (if available on the system)
if defaults read com.apple.finder EmptyTrashSecurely &>/dev/null; then
    defaults write com.apple.finder EmptyTrashSecurely -bool true
    log_success "Enabled Secure Empty Trash"
else
    log_info "Secure Empty Trash option not available on this system"
fi

# Disable Bonjour multicast advertisements
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
log_success "Disabled Bonjour multicast advertisements"

# Enable application layer firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp on
log_success "Enabled application layer firewall"

############################
# Restart Affected Applications
############################

log_info "Restarting affected applications to apply changes..."

for app in "Finder" "Safari" "Terminal"; do
    killall "$app" &>/dev/null && log_success "Restarted $app" || log_info "$app was not running"
done

log_success "Security settings applied successfully"
