#!/bin/bash

# Mac Preferences Module

log_info "Applying macOS preferences and tweaks..."

############################
# Finder Preferences
############################

log_info "Updating Finder preferences..."

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
log_success "Set Finder to expand save panels by default"

# Disable the "reopen windows when logging back in" option
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
log_success "Disabled 'reopen windows when logging back in'"

# Show status and path bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
log_success "Enabled status and path bar in Finder"

# Use column view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
log_success "Set Finder to use column view by default"

# Allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true
log_success "Enabled text selection in Quick Look"

# Smaller sidebar icons
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
log_success "Set smaller sidebar icons"

# Show hidden ~/Library folder
chflags nohidden ~/Library
log_success "Made ~/Library folder visible"

# Show all hidden files and extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
log_success "Enabled showing hidden files and all extensions"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
log_success "Enabled showing external drives on desktop"

# Folders always on top
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
log_success "Set folders to always appear first in Finder"

# Search scope set to current folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
log_success "Set Finder search scope to current folder"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
log_success "Prevented creation of .DS_Store files on network or USB volumes"

# Enable snap-to-grid for icons
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
log_success "Enabled snap-to-grid for icons"

# Disable warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
log_success "Disabled warning when changing file extensions"

# Switch to respective space when switching applications
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true
log_success "Configured spaces to switch when activating apps"

# Disable smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
log_success "Disabled smart quotes and dashes"

# Disable automatic period substitution and capitalization
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
log_success "Disabled automatic period substitution and capitalization"

############################
# Dock Preferences
############################

log_info "Updating Dock preferences..."

# Auto-hide Dock with no delay and set size
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock show-process-indicators -bool true
log_success "Configured Dock auto-hide and size"

# Set up hot corners
defaults write com.apple.dock wvous-tl-corner -int 12  # Top left: Notification Center
defaults write com.apple.dock wvous-tr-corner -int 14  # Top right: Launchpad
defaults write com.apple.dock wvous-bl-corner -int 4   # Bottom left: Desktop
defaults write com.apple.dock wvous-br-corner -int 5   # Bottom right: Start screen saver
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0
log_success "Set up hot corners"

############################
# Input & Keyboard Preferences
############################

log_info "Updating Input & Keyboard preferences..."

# Disable 'natural' scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
log_success "Disabled natural scrolling"

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
log_success "Enabled full keyboard access"

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
log_success "Enabled tap to click"

# Enable silent clicking
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0
log_success "Enabled silent clicking"

# Adjust keyboard brightness in low light
defaults write com.apple.BezelServices kDim -bool true
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool true
log_success "Enabled keyboard brightness adjustment in low light"

# Dim keyboard after idle time (1 minute)
defaults write com.apple.BezelServices kDimTime -int 60
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Keyboard Dim Time" -int 60
log_success "Set keyboard to dim after 1 minute of inactivity"

############################
# Screenshot Preferences
############################

log_info "Updating Screenshot preferences..."

# Set screenshot format to PNG and disable shadows
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture name "Screenshot"
defaults write com.apple.screencapture disable-shadow -bool true
log_success "Configured screenshot settings"

############################
# Terminal Preferences
############################

log_info "Updating Terminal preferences..."

# Enable UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4
log_success "Enabled UTF-8 in Terminal.app"

# Set the Pro theme by default
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"
log_success "Set Terminal theme to Pro"

# X11 focus follows mouse
defaults write com.apple.terminal FocusFollowsMouse -string YES
defaults write org.x.X11 wm_ffm -bool true
log_success "Enabled focus follows mouse in Terminal"

############################
# Print Preferences
############################

log_info "Updating Print preferences..."

# Auto-quit printer app once print jobs are done
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
log_success "Configured printer app to auto-quit"

############################
# Display Preferences
############################

log_info "Updating Display preferences..."

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2
log_success "Enabled subpixel font rendering"

# Enable dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
log_success "Enabled dark mode"

############################
# Mail Preferences
############################

log_info "Updating Mail preferences..."

# Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>'
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
log_success "Changed email address copy format"

# Set default view to date descending and threaded
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"
log_success "Configured Mail view settings"

############################
# Restart Affected Applications
############################

log_info "Restarting affected applications to apply changes..."

for app in "Finder" "Dock" "Mail"; do
    killall "$app" &> /dev/null || true
    log_success "Restarted $app"
done


# # Safari Related Preferences
# echo -e | tee -a $LOGFILE
# echo -e "\033[0;36mUpdating preferences (Safari)...\033[0m" | tee -a $LOGFILE

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Hiding sidebar in Top Site\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.Safari ShowSidebarInTopSites -bool false > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Disabling thumbnail cache\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Enable debug, developer and inspector menus\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.Safari IncludeInternalDebugMenu -bool true > /dev/null 2>&1
#     defaults write com.apple.Safari IncludeDevelopMenu -bool true > /dev/null 2>&1
#     defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true > /dev/null 2>&1
#     defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true > /dev/null 2>&1
#     defaults write NSGlobalDomain WebKitDeveloperExtras -bool true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Show full URLs\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.safari "ShowFullURLInSmartSearchField" -bool true > /dev/null 2>&1
#     defaults write com.apple.safari ShowOverlayStatusBar -int 1

# # Other OS Related Preferences
# echo -e | tee -a $LOGFILE
# echo -e "\033[0;36mUpdating preferences (Other OS preferences)...\033[0m" | tee -a $LOGFILE

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: System apps to show temprarture in celsius\033[0m" | tee -a $LOGFILE
#     defaults write -g AppleTemperatureUnit -string "Celsius" > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar Battery Percentage\033[0m" | tee -a $LOGFILE
#     defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1 > /dev/null 2>&1
#     defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable Mission Control\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.dashboard mcx-disabled -bool true > /dev/null 2>&1
#     defaults write com.apple.dashboard enabled-state -int 1 > /dev/null 2>&1
#     defaults write com.apple.dock dashboard-in-overlay -bool true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar hide spotlight and wifi\033[0m" | tee -a $LOGFILE
#     defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1 > /dev/null 2>&1
#     defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar format time (EEE d MMM HH:mm) \033[0m" | tee -a $LOGFILE
#     defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\"" > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable the sound effects on boot\033[0m" | tee -a $LOGFILE
#     sudo nvram SystemAudioVolume=" " > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: iOS charging chime when plugged into magsafe\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.PowerChime ChimeOnAllHardware -bool true || true > /dev/null 2>&1
#     open /System/Library/CoreServices/PowerChime.app || true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Preventing Time Machine from prompting to use new backup volumes\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Remove duplicates in the 'Open With' menu\033[0m" | tee -a $LOGFILE
#     /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Stop 'Photos' app from opening automatically\033[0m" | tee -a $LOGFILE
#     defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable quartine on download messages nusiance\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.LaunchServices LSQuarantine -bool false > /dev/null 2>&1

# # Other App Specific Preferences
# echo -e | tee -a $LOGFILE
# echo -e "\033[0;36mUpdating preferences (App specific preferences)...\033[0m" | tee -a $LOGFILE

#     # https://stackoverflow.com/questions/39972335/how-do-i-press-and-hold-a-key-and-have-it-repeat-in-vscode
#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: VS Code Allow pressing and holding a key to repeat it\033[0m" | tee -a $LOGFILE
#     defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: VS Code enable subpixel anti-aliasing\033[0m" | tee -a $LOGFILE
#     defaults write com.microsoft.VSCode CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1
#     defaults write com.microsoft.VSCode.helper CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1
#     defaults write com.microsoft.VSCode.helper.EH CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1
#     defaults write com.microsoft.VSCode.helper.NP CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1


#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Apple Text Editor to use plain text only\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.TextEdit RichText -int 0 > /dev/null 2>&1
#     defaults write com.apple.TextEdit PlainTextEncoding -int 4 > /dev/null 2>&1
#     defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4 > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Apple contacts set locale and allways show birth date\033[0m" | tee -a $LOGFILE
#     defaults write com.apple.AddressBook ABBirthDayVisible -bool true > /dev/null 2>&1
#     defaults write com.apple.AddressBook ABDefaultAddressCountryCode -string $COUNTRYCODE > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Unarchiver show folder after extract\033[0m" | tee -a $LOGFILE
#     defaults write com.macpaw.site.theunarchiver openExtractedFolder -bool true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Docker enable auto-update\033[0m" | tee -a $LOGFILE
#     defaults write com.docker.docker SUAutomaticallyUpdate -bool true > /dev/null 2>&1
#     defaults write com.docker.docker SUEnableAutomaticChecks -bool true > /dev/null 2>&1

#     echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: GPG Use Keychain to Store Secrets\033[0m" | tee -a $LOGFILE
#     defaults write org.gpgtools.pinentry-mac DisableKeychain -bool false > /dev/null 2>&1
