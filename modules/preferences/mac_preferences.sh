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

# Mac Preferences Module

log_info "Applying macOS preferences and tweaks..."

# Function to set defaults with error handling
set_default() {
    if ! defaults write "$1" "$2" "$3"; then
        log_error "Failed to set default: $1 $2"
    fi
}

############################
# Global Preferences
############################

log_info "Updating global preferences..."

# Expand save and print panels by default
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
set_default NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
set_default NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
log_success "Set expanded save and print panels by default"

# Disable automatic capitalization, period substitution, and smart quotes/dashes
set_default NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
set_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
log_success "Disabled automatic text corrections"

# Enable full keyboard access for all controls
set_default NSGlobalDomain AppleKeyboardUIMode -int 3
log_success "Enabled full keyboard access"

# Enable subpixel font rendering on non-Apple LCDs
set_default NSGlobalDomain AppleFontSmoothing -int 2
log_success "Enabled subpixel font rendering"

# Enable dark mode
set_default NSGlobalDomain AppleInterfaceStyle -string "Dark"
log_success "Enabled dark mode"

############################
# Finder Preferences
############################

log_info "Updating Finder preferences..."

# Show status and path bar in Finder
set_default com.apple.finder ShowStatusBar -bool true
set_default com.apple.finder ShowPathbar -bool true
log_success "Enabled status and path bar in Finder"

# Use column view in all Finder windows by default
set_default com.apple.finder FXPreferredViewStyle -string "clmv"
log_success "Set Finder to use column view by default"

# Show all hidden files and extensions
set_default NSGlobalDomain AppleShowAllExtensions -bool true
set_default com.apple.finder AppleShowAllFiles -bool true
log_success "Enabled showing hidden files and all extensions"

# Avoid creating .DS_Store files on network or USB volumes
set_default com.apple.desktopservices DSDontWriteNetworkStores -bool true
set_default com.apple.desktopservices DSDontWriteUSBStores -bool true
log_success "Prevented creation of .DS_Store files on network or USB volumes"

# Enable snap-to-grid for icons
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
log_success "Enabled snap-to-grid for icons"

############################
# Dock Preferences
############################

log_info "Updating Dock preferences..."

# Auto-hide Dock with no delay and set size
set_default com.apple.dock autohide -bool true
set_default com.apple.dock autohide-delay -float 0
set_default com.apple.dock autohide-time-modifier -float 0.5
set_default com.apple.dock tilesize -int 36
set_default com.apple.dock show-process-indicators -bool true
log_success "Configured Dock auto-hide and size"

# Set up hot corners
corners=(
    "wvous-tl-corner:12"  # Top left: Notification Center
    "wvous-tr-corner:14"  # Top right: Launchpad
    "wvous-bl-corner:4"   # Bottom left: Desktop
    "wvous-br-corner:5"   # Bottom right: Start screen saver
)

for corner in "${corners[@]}"; do
    key="${corner%%:*}"
    value="${corner#*:}"
    set_default com.apple.dock "$key" -int "$value"
    set_default com.apple.dock "${key%-corner}-modifier" -int 0
done
log_success "Set up hot corners"

############################
# Input & Keyboard Preferences
############################

log_info "Updating Input & Keyboard preferences..."

# Disable 'natural' scrolling
set_default NSGlobalDomain com.apple.swipescrolldirection -bool false
log_success "Disabled natural scrolling"

# Enable tap to click
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
set_default NSGlobalDomain com.apple.mouse.tapBehavior -int 1
log_success "Enabled tap to click"

# Adjust keyboard brightness in low light
set_default com.apple.BezelServices kDim -bool true
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool true
log_success "Enabled keyboard brightness adjustment in low light"

############################
# Screenshot Preferences
############################

log_info "Updating Screenshot preferences..."

# Set screenshot format to PNG and disable shadows
set_default com.apple.screencapture type -string "png"
set_default com.apple.screencapture name "Screenshot"
set_default com.apple.screencapture disable-shadow -bool true
log_success "Configured screenshot settings"

############################
# Terminal Preferences
############################

log_info "Updating Terminal preferences..."

# Enable UTF-8 in Terminal.app
set_default com.apple.terminal StringEncodings -array 4
log_success "Enabled UTF-8 in Terminal.app"

# Set the Pro theme by default
set_default com.apple.Terminal "Default Window Settings" -string "Pro"
set_default com.apple.Terminal "Startup Window Settings" -string "Pro"
log_success "Set Terminal theme to Pro"

############################
# Mail Preferences
############################

log_info "Updating Mail preferences..."

# Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>'
set_default com.apple.mail AddressesIncludeNameOnPasteboard -bool false
log_success "Changed email address copy format"

# Set default view to date descending and threaded
set_default com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
set_default com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
set_default com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"
log_success "Configured Mail view settings"

############################
# Restart Affected Applications
############################

log_info "Restarting affected applications to apply changes..."

for app in "Finder" "Dock" "Mail"; do
    if ! killall "$app" 2>/dev/null; then
        log_warning "Failed to restart $app"
    else
        log_success "Restarted $app"
    fi
done

log_success "macOS preferences update completed"
