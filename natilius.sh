#!/bin/bash

# Natilius - Modular Mac Developer Environment Setup
# https://github.com/koconder/natilius

set -e

NATILIUS_DIR="$HOME/.natilius"
CONFIG_FILE="$HOME/.natiliusrc"

# Source utility functions and logging
source "$NATILIUS_DIR/lib/utils.sh"
source "$NATILIUS_DIR/lib/logging.sh"

# Load user configuration and export variables
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    export $(grep -Ev '^#' "$CONFIG_FILE" | cut -d= -f1 | xargs)
else
    cp "$NATILIUS_DIR/.natiliusrc.example" "$CONFIG_FILE"
    log_info "Created default configuration file at $CONFIG_FILE"
    source "$CONFIG_FILE"
    export $(grep -Ev '^#' "$CONFIG_FILE" | cut -d= -f1 | xargs)
fi

# Set LOGFILE
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="$NATILIUS_DIR/logs/natilius-setup-$TIMESTAMP.log"

mkdir -p "$NATILIUS_DIR/logs"

# Start logging
log_info "Logging enabled..."
log_info "Log file is located at [$LOGFILE]"

# Export LOGFILE so that it's available in sourced scripts
export LOGFILE

# Prompt for sudo password at the start
log_info "Please provide your password to proceed with sudo privileges (may auto-skip)..."
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

log_success "Sudo password validated"

# Run modules based on configuration
for module in "${ENABLED_MODULES[@]}"; do
    MODULE_PATH="$NATILIUS_DIR/modules/$module.sh"
    if [ -f "$MODULE_PATH" ]; then
        log_info "Running module: $module"
        source "$MODULE_PATH"
    else
        log_warning "Module not found: $module"
    fi
done

log_success "Natilius setup complete!"


# Safari Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Safari)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Hiding sidebar in Top Site\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari ShowSidebarInTopSites -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Disabling thumbnail cache\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Enable debug, developer and inspector menus\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true > /dev/null 2>&1
    defaults write com.apple.Safari IncludeDevelopMenu -bool true > /dev/null 2>&1
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true > /dev/null 2>&1
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Safari: Show full URLs\033[0m" | tee -a $LOGFILE
    defaults write com.apple.safari "ShowFullURLInSmartSearchField" -bool true > /dev/null 2>&1
    defaults write com.apple.safari ShowOverlayStatusBar -int 1

# Other OS Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Other OS preferences)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: System apps to show temprarture in celsius\033[0m" | tee -a $LOGFILE
    defaults write -g AppleTemperatureUnit -string "Celsius" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar Battery Percentage\033[0m" | tee -a $LOGFILE
    defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1 > /dev/null 2>&1
    defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable Mission Control\033[0m" | tee -a $LOGFILE
    defaults write com.apple.dashboard mcx-disabled -bool true > /dev/null 2>&1
    defaults write com.apple.dashboard enabled-state -int 1 > /dev/null 2>&1
    defaults write com.apple.dock dashboard-in-overlay -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar hide spotlight and wifi\033[0m" | tee -a $LOGFILE
    defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1 > /dev/null 2>&1
    defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar format time (EEE d MMM HH:mm) \033[0m" | tee -a $LOGFILE
    defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\"" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable the sound effects on boot\033[0m" | tee -a $LOGFILE
    sudo nvram SystemAudioVolume=" " > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: iOS charging chime when plugged into magsafe\033[0m" | tee -a $LOGFILE
    defaults write com.apple.PowerChime ChimeOnAllHardware -bool true || true > /dev/null 2>&1
    open /System/Library/CoreServices/PowerChime.app || true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Preventing Time Machine from prompting to use new backup volumes\033[0m" | tee -a $LOGFILE
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Remove duplicates in the 'Open With' menu\033[0m" | tee -a $LOGFILE
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Stop 'Photos' app from opening automatically\033[0m" | tee -a $LOGFILE
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable quartine on download messages nusiance\033[0m" | tee -a $LOGFILE
    defaults write com.apple.LaunchServices LSQuarantine -bool false > /dev/null 2>&1

# Other App Specific Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (App specific preferences)...\033[0m" | tee -a $LOGFILE

    # https://stackoverflow.com/questions/39972335/how-do-i-press-and-hold-a-key-and-have-it-repeat-in-vscode
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: VS Code Allow pressing and holding a key to repeat it\033[0m" | tee -a $LOGFILE
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: VS Code enable subpixel anti-aliasing\033[0m" | tee -a $LOGFILE
    defaults write com.microsoft.VSCode CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1
    defaults write com.microsoft.VSCode.helper CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1
    defaults write com.microsoft.VSCode.helper.EH CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1
    defaults write com.microsoft.VSCode.helper.NP CGFontRenderingFontSmoothingDisabled -bool false > /dev/null 2>&1


    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Apple Text Editor to use plain text only\033[0m" | tee -a $LOGFILE
    defaults write com.apple.TextEdit RichText -int 0 > /dev/null 2>&1
    defaults write com.apple.TextEdit PlainTextEncoding -int 4 > /dev/null 2>&1
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Apple contacts set locale and allways show birth date\033[0m" | tee -a $LOGFILE
    defaults write com.apple.AddressBook ABBirthDayVisible -bool true > /dev/null 2>&1
    defaults write com.apple.AddressBook ABDefaultAddressCountryCode -string $COUNTRYCODE > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Unarchiver show folder after extract\033[0m" | tee -a $LOGFILE
    defaults write com.macpaw.site.theunarchiver openExtractedFolder -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: Docker enable auto-update\033[0m" | tee -a $LOGFILE
    defaults write com.docker.docker SUAutomaticallyUpdate -bool true > /dev/null 2>&1
    defaults write com.docker.docker SUEnableAutomaticChecks -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Apps: GPG Use Keychain to Store Secrets\033[0m" | tee -a $LOGFILE
    defaults write org.gpgtools.pinentry-mac DisableKeychain -bool false > /dev/null 2>&1

############################
#
# Security
#
############################

# Critical Security Tweaks
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSecurity tweaks (Critical)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable Siri and Apple Analytics\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Siri "UserHasDeclinedEnable" -bool true > /dev/null 2>&1
    defaults write com.apple.Siri "StatusMenuVisible" -bool false > /dev/null 2>&1
    defaults write com.apple.assistant.support "Assistant Enabled" -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable IPV6 on Wi-fi and Ethernet adapters\033[0m" | tee -a $LOGFILE
    NETWORKADAPTERS=$(networksetup -listallhardwareports | grep "Hardware Port:" | awk -F ': ' '{print $2}')
    while read -r line; do
        if [[ ${line} != *"Thunderbolt"* ]];then
            echo "Disabling ipv6 for: $line" | tee -a $LOGFILE
            sudo networksetup -setv6off $line || true
        fi
    done <<< "$NETWORKADAPTERS"

    # echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable infared\033[0m" | tee -a $LOGFILE
    # defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -int 0 > /dev/null 2>&1

    # echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable SSH\033[0m" | tee -a $LOGFILE
    # sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable Secure Keyboard Entry in terminal.app\033[0m" | tee -a $LOGFILE
    defaults write -app Terminal SecureKeyboardEntry -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable gatekeeper (code signing verification)\033[0m" | tee -a $LOGFILE
    sudo spctl --master-enable

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable Apple firewall\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.alf globalstate 1 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable Apple firewall logging\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enabling Stealth Firewall Mode\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.alf stealthenabled 1 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable Wake on Lan (womp)\033[0m" | tee -a $LOGFILE
    sudo pmset womp 0 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable filevault (disk encryption)\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36m...You may be asked for login again, please keep recovery key safe\033[0m" | tee -a $LOGFILE

    FILEVAULT_STATUS=$(sudo fdesetup status)
    if [[ $FILEVAULT_STATUS != "FileVault is On." && ! $FILEVAULT_STATUS =~ "Encryption in progress" ]];then
        sudo fdesetup enable
    else
        echo -e "\033[0;33m[ ✓ ]\033[0m \033[0;36mAlready enabled... skipping...\033[0m" | tee -a $LOGFILE
    fi

# Login related Security Tweaks
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSecurity tweaks (Login/User)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Login: Reveal system info (IP address etc.) when clicking the clock in the login screen\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Login: Require password immediately after sleep or screen saver begins\033[0m" | tee -a $LOGFILE
    defaults write com.apple.screensaver askForPassword -int 1 > /dev/null 2>&1
    defaults write com.apple.screensaver askForPasswordDelay -int 0 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Login: Disable guest user\033[0m" | tee -a $LOGFILE
    sudo sysadminctl -guestAccount off > /dev/null 2>&1
    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Login: Disable console logon from the logon screen\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.loginwindow DisableConsoleAccess -bool true > /dev/null 2>&1

# Update related Security Tweaks
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSecurity tweaks (Updates)...\033[0m" | tee -a $LOGFILE

    #echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Updates: Time machine dose not require AC power (magsafe)\033[0m" | tee -a $LOGFILE
    #sudo defaults write /Library/Preferences/com.apple.TimeMachine RequiresACPower -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Updates: Enabling scheduled updates and background downloads\033[0m" | tee -a $LOGFILE
    softwareupdate --schedule on > /dev/null 2>&1
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool true > /dev/null 2>&1
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool true > /dev/null 2>&1
    sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool true > /dev/null 2>&1
    sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Updates: Check for App Updates daily, not just once a week\033[0m" | tee -a $LOGFILE
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1 > /dev/null 2>&1

# Privacy related Security Tweaks
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSecurity tweaks (Privacy)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Privacy: Safari send do not track header\033[0m" | tee -a $LOGFILE
    defaults write com.apple.safari SendDoNotTrackHTTPHeader -int 1 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Privacy: Disable potential DNS leaks\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Privacy: Disable search data leaking in safari\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari UniversalSearchEnabled -bool false > /dev/null 2>&1
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true > /dev/null 2>&1
    defaults write com.apple.Safari.plist WebsiteSpecificSearchEnabled -bool NO > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Privacy: Remove Google Software Updater\033[0m" | tee -a $LOGFILE
    ~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall --nuke 2>/dev/null | tee -a $LOGFILE || true

############################
#
# Kill apps (to apply changes)
#
############################

# Kill affected applications
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mRestarting apps after applying changes...\033[0m" | tee -a $LOGFILE
for a in "${KILLAPPS[@]}";
do killall -q $a && echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mClosing app [$a]\033[0m" 2>/dev/null | tee -a $LOGFILE || true
done

############################
#
# Homebrew Taps
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mTapping homebrew casks...\033[0m" | tee -a $LOGFILE
for a in "${BREWTAPS[@]}";
do
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mTapping cask [$a]\033[0m" | tee -a $LOGFILE
    brew tap $a | tee -a $LOGFILE
    sleep 1
done

############################
#
# Homebrew Packages
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mInstalling homebrew packages...\033[0m" | tee -a $LOGFILE
for a in "${BREWPACKAGES[@]}";
do
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mInstalling package [$a]\033[0m" | tee -a $LOGFILE
    brew install $a | tee -a $LOGFILE
    echo -e
    sleep 2
done

############################
#
# Homebrew Casks
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mInstalling homebrew casks...\033[0m" | tee -a $LOGFILE
for a in "${BREWCASKS[@]}";
do
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mInstalling cask [$a]\033[0m" | tee -a $LOGFILE
    sudo -u $SUDO_USER brew install --appdir="/Applications" --cask $a | tee -a $LOGFILE
    echo -e
    sleep 2
done

echo -e "\033[0;36mRunning post install clean-up\033[0m" | tee -a $LOGFILE
brew cleanup

############################
#
# Screensaver
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if Aerial screensaver is installed...\033[0m" | tee -a $LOGFILE
if [ -L ~/.mackup.cfg ] ; then
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;Aerial screensaver should be installed, please restart this script if you have issues...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;Skipping Aerial setup...\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSetting default screensaver to Aerial with 2minute timeout\033[0m" | tee -a $LOGFILE
    defaults -currentHost write com.apple.screensaver idleTime 120
    defaults -currentHost write com.apple.screensaver moduleDict -dict path -string "/Users/$SUDO_USER/Library/Screen Savers/Aerial.saver" moduleName -string "Aerial" type -int 0
fi

############################
#
# Espanso
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if espanso is installed...\033[0m" | tee -a $LOGFILE
if [[ $(command -v espanso) == "" ]]; then
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;espanso should be installed, please restart this script if you have issues...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;Skipping espanso setup...\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mRegistering espanso service [$(which espanso)]\033[0m" | tee -a $LOGFILE
    espanso service register | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mInstalling espanso extensions\033[0m" | tee -a $LOGFILE
    espanso install accented-words 2> /dev/null || true
    espanso install misspell-en-uk 2> /dev/null || true
    espanso install misspell-en 2> /dev/null || true
    espanso install numeronyms 2> /dev/null || true

    espanso restart | tee -a $LOGFILE
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mRestarted espanso service\033[0m" | tee -a $LOGFILE
fi

############################
#
# Mac App Store (mas)
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if mas (mac app store cli) is installed...\033[0m" | tee -a $LOGFILE
if [[ $(command -v mas) == "" ]]; then
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;mas should be installed, please restart this script if you have issues...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;Skipping installation of mac apps...\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mInstalling Apple App Store apps with mas [$(which mas)]\033[0m" | tee -a $LOGFILE
    for a in "${APPSTORE[@]}";
    do
        echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mInstalling app [$a]\033[0m" | tee -a $LOGFILE
        mas install $a | tee -a $LOGFILE
        echo -e
        sleep 1
    done
fi

############################
#
# Developer Enviroment: Java
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if Java JDK (OpenJDK) using jenv is installed...\033[0m" | tee -a $LOGFILE

# Check if jenv is installed, if not install it
if ! command -v jenv &> /dev/null; then
    echo "jenv not found. Installing jenv..."
    brew install jenv
    export PATH="$HOME/.jenv/bin:$PATH"
    PROMPT_COMMAND=${PROMPT_COMMAND:-true}
    eval "$(jenv init -)"
fi


CURRENTVER=$(get_current_version jenv)
INSTALLED=false

# Loop through versions and check for an exact match
while read -r version; do
    if [[ "$version" == "$JDKVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(jenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mOpenJDK [$JDKVER] is already installed...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mSkipping installation of OpenJDK...\033[0m" | tee -a $LOGFILE
    java --version | tee -a $LOGFILE
    which java | tee -a $LOGFILE

else
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mOpenJDK [$JDKVER] is not installed... Found [$CURRENTVER]...\033[0m" | tee -a $LOGFILE

    # Load jenv
    export PATH="$HOME/.jenv/bin:$PATH"
    PROMPT_COMMAND=${PROMPT_COMMAND:-true}
    eval "$(jenv init -)"

    # Install JDK(s)
    echo "Installing Java (OpenJDK)..." | tee -a $LOGFILE
    brew install --cask temurin
    brew install --cask temurin8
    brew install maven
    brew install scala
    brew install apache-spark

    # Add all found JDKs to jenv
    for jdk in /Library/Java/JavaVirtualMachines/*; do
        jenv add "${jdk}/Contents/Home/" | tee -a $LOGFILE
    done

    # If there are other versions installed, set the highest one as the global version
    HIGHESTVER=$(get_highest_version jenv)
    if [ "$HIGHESTVER" != "$JDKVER" ]
    then
        jenv global $HIGHESTVER
    fi

    # Show the active JDK version
    java --version | tee -a $LOGFILE

    # Enable extras
    jenv enable-plugin maven | tee -a $LOGFILE
    jenv enable-plugin scala | tee -a $LOGFILE
    jenv enable-plugin gradle | tee -a $LOGFILE
    jenv exec mvn -version | tee -a $LOGFILE
    jenv exec scala -version | tee -a $LOGFILE
    jenv exec gradle -version | tee -a $LOGFILE

    # Use jenv-doctor to check the setup
    jenv doctor | tee -a $LOGFILE
fi


############################
#
# Developer Enviroment: Ruby
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if Ruby using rbenv is installed...\033[0m" | tee -a $LOGFILE

# Check if rbenv is installed, if not install it
if ! command -v rbenv &> /dev/null; then
    echo "rbenv not found. Installing rbenv..." | tee -a $LOGFILE
    brew install rbenv | tee -a $LOGFILE
    eval "$(rbenv init -)"

    # Install ruby-build as an rbenv plugin
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

    # Install rbenv-default-gems as an rbenv plugin
    git clone https://github.com/rbenv/rbenv-default-gems.git "$(rbenv root)"/plugins/rbenv-default-gems

    # Create a default-gems file
    echo "bundler" > "$(rbenv root)"/default-gems
fi


CURRENTVER=$(get_current_version rbenv)
INSTALLED=false

# Loop through versions and check for an exact match
while read -r version; do
    if [[ "$version" == "$RUBYVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(rbenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mRuby [$RUBYVER] is already installed...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mSkipping installation of Ruby...\033[0m" | tee -a $LOGFILE
    ruby --version | tee -a $LOGFILE
    which ruby | tee -a $LOGFILE

else
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mRuby [$RUBYVER] is not installed... Found [$CURRENTVER]...\033[0m" | tee -a $LOGFILE
    echo -e "Installing Ruby..." | tee -a $LOGFILE
    rbenv install $RUBYVER | tee -a $LOGFILE

    # Set RUBYVER as the local and global Ruby version
    rbenv global $RUBYVER
    rbenv local $RUBYVER

    # If there are other versions installed, set the highest one as the global version
    HIGHESTVER=$(get_highest_version rbenv)
    if [ "$HIGHESTVER" != "$RUBYVER" ]; then
        rbenv global $HIGHESTVER
    fi

    # Show the active Ruby version
    ruby --version | tee -a $LOGFILE

    # Update the RubyGems system software to the latest version
    gem update --system

    # Update all installed gems to their latest versions
    gem update

    # Use rbenv-doctor to check the setup
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-doctor | bash | tee -a $LOGFILE
fi

############################
#
# Developer Enviroment: Node
#
############################


echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if NodeJS using nodenv is installed...\033[0m" | tee -a $LOGFILE

# Check if nodenv is installed, if not install it
if ! command -v nodenv &> /dev/null; then
    echo "nodenv not found. Installing jenv..." | tee -a $LOGFILE
    brew install nodenv | tee -a $LOGFILE
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
fi


CURRENTVER=$(get_current_version nodenv)
INSTALLED=false

# Loop through versions and check for an exact match
while read -r version; do
    if [[ "$version" == "$NODEVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(nodenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mNodeJS [$NODEVER] is already installed...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mSkipping installation of NodeJS...\033[0m" | tee -a $LOGFILE
    node --version | tee -a $LOGFILE
    which node | tee -a $LOGFILE

else
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mNodeJS [$NODEVER] is not installed... Found [$CURRENTVER]...\033[0m" | tee -a $LOGFILE
    echo -e "Installing NodeJS..." | tee -a $LOGFILE
    nodenv install $NODEVER | tee -a $LOGFILE

    # Set NODEVER as the local and global Node.js version
    nodenv global $NODEVER
    nodenv local $NODEVER

    # If there are other versions installed, set the highest one as the global version
    HIGHESTVER=$(get_highest_version nodenv)
    if [ "$HIGHESTVER" != "$NODEVER" ]
    then
        nodenv global $HIGHESTVER
    fi

    # Show the active Node.js version
    node --version | tee -a $LOGFILE

    # Setup packages
    echo "Installing global Node.js packages..."
    declare -a globalNodePackages=(
        'eslint'
        'gatsby'
        'json'
        'sort-json'
        'nodemon'
        'express-generator'
        'create-react-app'
        'vue-cli'
        'angular-cli'
        'prettier'
        'mocha'
        'jest'
        'typescript'
        'grunt-cli'
        'gulp-cli'
        'webpack-cli'
        'yarn'
        'pm2'
        'serverless'
        'npm-check-updates'
        'istanbul'
        'nyc'
    )
    npm i -g "${globalNodePackages[@]}" | tee -a $LOGFILE
    echo "Setting up npm and yarn with nodenv..." | tee -a $LOGFILE
    nodenv rehash
    nodenv which npm
    nodenv which yarn
fi

############################
#
# Developer Enviroment: Python
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if Python using pyenv is installed...\033[0m" | tee -a $LOGFILE

# Check if pyenv is installed, if not install it
if ! command -v pyenv &> /dev/null; then
    echo "pyenv not found. Installing jenv..." | tee -a $LOGFILE
    brew install pyenv | tee -a $LOGFILE
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

    # Install pyenv-virtualenv
    echo "pyenv-virtualenv not found. Installing jenv..." | tee -a $LOGFILE
    brew install pyenv-virtualenv | tee -a $LOGFILE
    eval "$(pyenv virtualenv-init -)"
fi


CURRENTVER=$(get_current_version pyenv)
INSTALLED=false

# Loop through versions and check for an exact match
while read -r version; do
    if [[ "$version" == "$PYTHONVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(pyenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPython [$PYTHONVER] is already installed...\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mSkipping installation of Python...\033[0m" | tee -a $LOGFILE
    python --version | tee -a $LOGFILE
    which python | tee -a $LOGFILE

else
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mPython [$PYTHONVER] is not installed... Found [$CURRENTVER]...\033[0m" | tee -a $LOGFILE
    echo -e "Installing Python..." | tee -a $LOGFILE
    pyenv install $PYTHONVER | tee -a $LOGFILE

    # Set PYTHONVER as the local and global Python version
    pyenv global $PYTHONVER
    pyenv local $PYTHONVER

    # Show the active Python version
    python --version | tee -a $LOGFILE

    # Setup packages
    echo "Installing global Python packages..."
    declare -a globalPythonPackages=(
        'pip'
        'virtualenv'
        'setuptools'
        'wheel'
        'numpy'
        'pandas'
        'scipy'
        'matplotlib'
        'seaborn'
        'scikit-learn'
        'requests'
        'beautifulsoup4'
        'flask'
        'pre-commit'
        'flake8'
        'isort'
        'coverage'
        'regex'
        'cython'
        'Jinja2'
        'six'
        'tabula'
        'dbt-core'
        'PyYAML'
        'sqlfluff'
        # 'django'
    )
    pip install "${globalPythonPackages[@]}" | tee -a $LOGFILE
fi

############################
#
# Developer Enviroment: Rust
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if Rust is installed...\033[0m" | tee -a $LOGFILE
if ! command -v rustup &> /dev/null; then
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mRust is not installed... Installing Rust\033[0m" | tee -a $LOGFILE
    #rustup-init --profile default -y | tee -a $LOGFILE
    brew install rust | tee -a $LOGFILE
    source "$HOME/.cargo/env"
    rustup update | tee -a $LOGFILE
else
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mRust is already installed\033[0m" | tee -a $LOGFILE
    rustc --version | tee -a $LOGFILE
    which rustc
    which rustup
fi

############################
#
# Dot files and preferences
#
############################

# # Mackup
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking for mackup setup (Mac configuration backup and dotfiles)...\033[0m" | tee -a $LOGFILE
if [ -e ~/.mackup.cfg ]; then
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mmackup config is detected... starting backup...\033[0m" | tee -a $LOGFILE
    read -p "Do you want to perform a backup with Mackup? (y/N): " backup_choice
    if [[ $backup_choice == [Yy]* ]]; then
        echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mPerforming Mackup backup...\033[0m" | tee -a $LOGFILE
        mackup backup
    else
        echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mSkipping Mackup backup...\033[0m" | tee -a $LOGFILE
    fi
else
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mmackup config is not detected... setting default config...\033[0m" | tee -a $LOGFILE
    echo "[storage]
engine = icloud
directory = dotfiles" > ~/.mackup.cfg
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mStarting mackup restore to load config from icloud and run symlinks...\033[0m" | tee -a $LOGFILE
    mackup restore -f
fi

#
# The End
#
echo -e | tee -a $LOGFILE
echo -e | tee -a $LOGFILE
echo -e "\033[0;32m[ 🐚 ]\033[0m \033[0;36mnatilius install script is finalised!\033[0m" | tee -a $LOGFILE
echo -e "\033[0;33m"
cat << EOF
 Thanks for using natilius :)
 Your logfile is saved at $LOGFILE

 You are welcomed to leave feedback, comments, and issues
 directly on GitHub at (https://github.com/koconder/natilius).

 I also welcome PR's and suggestions to speed up the
 setup of your development environment.

 Thanks
 Vince

EOF

# # Brew Doctor
# echo "Checking homebrew..."
# brew doctor

# ## Sublime
# - File Format Syntax Highliters
# https://packagecontrol.io/packages/Babel
# https://packagecontrol.io/packages/Crontab
# https://packagecontrol.io/packages/LESS
# https://packagecontrol.io/packages/ApacheConf
# https://packagecontrol.io/packages/nginx
# https://packagecontrol.io/packages/INI
# https://packagecontrol.io/packages/TOML
# https://packagecontrol.io/packages/DotENV
# https://packagecontrol.io/packages/Log%20Highlight
# https://packagecontrol.io/packages/Terraform
#
# - Lang Support
# https://packagecontrol.io/packages/Rust%20Enhanced
# https://packagecontrol.io/packages/BinaryPlist
#
# - UI
# https://packagecontrol.io/packages/BracketHighlighter
# https://packagecontrol.io/packages/AutoFileName
# https://packagecontrol.io/packages/SideBarEnhancements
# https://packagecontrol.io/packages/A%20File%20Icon
# https://packagecontrol.io/packages/TrailingSpaces
# https://packagecontrol.io/packages/ColorHelper
# https://packagecontrol.io/packages/rainbow_csv
# mkdir -p ~/.1password && ln -s \
#     ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \
#     ~/.1password/agent.sock
