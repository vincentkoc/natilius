#!/bin/bash

#
# natilius - 🐚 Automated One-Click Mac Developer Environment
# 
# Copyright (C) 2023 Vincent Koc (@koconder)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this
# program. If not, see http://www.gnu.org/licenses/.
#

############################
#
# Config
#
############################

trap 'ret=$?; test $ret -ne 0 && printf "\n   \e[31m⚠️   Natilius failed   ⚠️\033[0m\n" >&2; exit $ret' EXIT
set -euo pipefail

SUDO_USER=$(whoami)
TIMESTAMP=$(date +%s)
LOGFILE="./natilius-setup-$TIMESTAMP.log"
COUNTRYCODE="au"
PYVER="3.9.11"

# Directories to generate
DIRS=(
    ~/.mackup
    ~/.nvm
    ~/GIT
    ~/GIT/_Apps
    ~/GIT/_Perso
    ~/GIT/_Hipages
    ~/GIT/_Stj
    ~/GIT/_Airbyte
)

# Apps to kill post setup to apply changes
KILLAPPS=(
    Finder
    Dock
    Mail
    Safari
    iTunes
    iCal
    Address\ Book
    SystemUIServer
)

# Homebrew packages to install
PACKAGES=(
    awscli
    ca-certificates
    coreutils
    curl
    docker-compose
    git
    github/gh/gh
    git-lfs
    go
    gpg
    gradle
    helm
    htop
    jq
    kubectl
    kubernetes-cli
    kubernetes-helm
    lynx
    make
    mackup
    minikube
    neovim
    nmap
    node
    nodenv
    npm
    openssl
    pre-commit
    pyenv
    pyenv-virtualenv
    pipenv
    rbenv
    readline
    rustup-init
    speedtest-cli
    sqlite3
    terraform
    terraformer
    tldr
    tmux
    trash
    tree
    vim
    watch
    wget
    xz
    yamllint
    zlib
)

# Homebrew casks to install
CASKS=(
    aerial
    airbuddy
    alfred
    amazon-chime
    brave-browser
    charles
    cheatsheet
    datagrip
    discord
    docker
    dropbox
    espanso
    firefox
    font-fira-code
    github
    gpg-suite
    imageoptim
    iterm2
    keybase
    keycastr
    keyboard-maestro
    lastpass
    logseq
    loom
    mamp
    microsoft-office
    miro
    muzzle
    mkchromecast
    mysqlworkbench
    netnewswire
    notion
    obsidian
    onyx
    postman
    profilecreator
    rescuetime
    slack
    spotify
    sublime-text
    the-unarchiver
    transmit
    visual-studio-code
    vlc
    zoom
)

############################
#
# Start Setup
#
############################

echo -e "\033[0;33m"
cat << "EOF"
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣾⣿⣿⣿⠀⢸⣿⣿⣿⣿⣶⣶⣤⣀⠀⠀⠀⠀⠀ 
 ⠀⠀⠀⠀⠀⢀⣴⡇⢀⣾⣿⣿⣿⣿⣿⠀⣾⣿⣿⣿⣿⣿⣿⣿⠿⠓⠀⠀⠀⠀ 
 ⠀⠀⠀⠀⣰⣿⣿⡀⢸⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⠟⠁⣠⣄⠀⠀⠀⠀ 
 ⠀⠀⠀⢠⣿⣿⣿⣇⠀⢿⣿⣿⣿⣿⣿⠀⢻⣿⣿⣿⡿⢃⣠⣾⣿⣿⣧⡀⠀⠀ 
 ⠀⠀⠀⢸⣿⣿⣿⣿⣆⠘⢿⣿⡿⠛⢉⠀⠀⠉⠙⠛⣠⣿⣿⣿⣿⣿⣿⣷⠀⠀ 
 ⠀⠀⠠⣾⣿⣿⣿⣿⣿⣧⠈⠋⢀⣴⣧⠀⣿⡏⢠⡀⢸⣿⣿⣿⣿⣿⣿⣿⡇⠀ 
 ⠀⠀⣀⠙⢿⣿⣿⣿⣿⣿⠇⢠⣿⣿⣿⡄⠹⠃⠼⠃⠈⠉⠛⠛⠛⠛⠛⠻⠇⠀ 
 ⠀⢸⡟⢠⣤⠉⠛⠿⢿⣿⠀⢸⣿⡿⠋⣠⣤⣄⠀⣾⣿⣿⣶⣶⣶⣦⡄⠀⠀⠀ 
 ⠀⠸⠀⣾⠏⣸⣷⠂⣠⣤⠀⠘⢁⣴⣾⣿⣿⣿⡆⠘⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀ 
 ⠀⠀⠀⠛⠀⣿⡟⠀⢻⣿⡄⠸⣿⣿⣿⣿⣿⣿⣿⡀⠘⣿⣿⣿⣿⠟⠀⠀⠀⠀ 
 ⠀⠀⠀⠀⠀⣿⠇⠀⠀⢻⡿⠀⠈⠻⣿⣿⣿⣿⣿⡇⠀⢹⣿⠿⠋⠀⠀⠀⠀⠀ 
 ⠀⠀⠀⠀⠀⠋⠀⠀⠀⡘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀  
                   _ _ _            
              _   (_) (_)           
  ____   ____| |_  _| |_ _   _  ___ 
 |  _ \ / _  |  _)| | | | | | |/___)
 | | | ( ( | | |__| | | | |_| |___ |
 |_| |_|\_||_|\___)_|_|_|\____(___/ 
                                   
 Welcome to Natilius

 Natilius is an automated script to help speed up
 development on a mac machine by scaffolding 
 all your key development apps, settings, dotfiles
 configration and have you up and running in no
 time. Developed by Vincent Koc (@koconder)

 This script assumes the iCloud as the primary
 location for dotfiles and configration.

 Starting Natilius...
EOF

############################
#
# Helper Functions
#
############################

# Set UUID for plists
if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
    macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
fi

# Check OS
if [[ $OSTYPE == 'darwin'* ]]; then
    OSVERSION=$(sw_vers -productVersion)
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mMac OS detected [macOS $OSVERSION, $OSTYPE]\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ !! ]\033[0m \033[0;36mRunning as $SUDO_USER\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ !! ]\033[0m \033[0;36mLocale set to $COUNTRYCODE\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;31mNatilius is only supported on Mac OS... Exiting\033[0m" | tee -a $LOGFILE
    exit 0
fi


############################
#
# Check environment (Login, iCloud)
#
############################

# Logging
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mLogging enabled...\033[0m" | tee -a $LOGFILE
echo -e "\033[0;33m[ !! ]\033[0m \033[0;36mLog file printing to [$LOGFILE]\033[0m" | tee -a $LOGFILE
echo -e | tee -a $LOGFILE

# Password for Sudo
echo -e "\033[0;36mPlease provide local password (may auto-skip)...\033[0m" | tee -a $LOGFILE
sudo -v
echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mPassword validated\033[0m" | tee -a $LOGFILE

# iCloud Drive
echo -e
echo -e "\033[0;36mChecking to see if iCloud drive has been mounted...\033[0m" | tee -a $LOGFILE
if [ -d ~/Library/Mobile\ Documents/com~apple~CloudDocs/ ]; then
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36miCloud Drive is located\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;31mError iCloud Drive not setup [~/Library/Mobile\ Documents/com~apple~CloudDocs/]... Exiting\033[0m" | tee -a $LOGFILE
    exit 0
fi

# Homebrew
echo -e
echo -e "\033[0;36mChecking to see if homebrew is installed...\033[0m" | tee -a $LOGFILE
if [[ $(command -v brew) == "" ]]; then
    echo -e "\033[0;33m[ !! ]\033[0m \033[0;36mInstalling homebrew...\033[0m" | tee -a $LOGFILE
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee -a $LOGFILE
    export PATH="/usr/local/bin:$PATH"
    echo -e "\033[0;33m[ ?? ]\033[0m \033[0;36mhomebrew should be installed, please restart this script if you have issues...\033[0m" | tee -a $LOGFILE
    #exit 0
else
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mUpdating homebrew\033[0m" | tee -a $LOGFILE
    brew update && brew upgrade | tee -a $LOGFILE
fi

# Quit preferences pane
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mClosing System Preferences pane if open...\033[0m" | tee -a $LOGFILE
osascript -e 'tell application "System Preferences" to quit' | tee -a $LOGFILE
echo -e "\033[0;33m[ ?? ]\033[0m \033[0;36mSystem Preferences pane closed\033[0m" | tee -a $LOGFILE

############################
#
# Setup OS environment
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSetting up custom home directories...\033[0m" | tee -a $LOGFILE
for a in "${DIRS[@]}";
do mkdir -p $a && echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mCreated folder if missing [$a]\033[0m" | tee -a $LOGFILE
done

# Finder Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Finder)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mExpanding the save panel by default\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDisable the “reopen windows when logging back in” option\033[0m" | tee -a $LOGFILE
    defaults write com.apple.loginwindow TALLogoutSavesState -bool false > /dev/null 2>&1
    defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mShow status and path bar in Finder\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder ShowStatusBar -bool true > /dev/null 2>&1
    defaults write com.apple.finder ShowPathbar -bool true> /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mUse column view in all Finder windows by default\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mAllow text selection in Quick Look\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder QLEnableTextSelection -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSmaller sidebar icons\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mShow hidden ~/Library folder\033[0m" | tee -a $LOGFILE
    chflags nohidden ~/Library > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mShow all hidden files and extensions\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true > /dev/null 2>&1
    defaults write com.apple.Finder AppleShowAllFiles YES > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mShowing icons for hard drives, servers, and removable media on the desktop\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mFolders allways ontop\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder "_FXSortFoldersFirst" -bool true > /dev/null 2>&1
    defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSearch Scope set to current folder\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mAvoiding the creation of .DS_Store files on network volumes\033[0m" | tee -a $LOGFILE
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mEnabling snap-to-grid for icons on the desktop and in other icon views\033[0m" | tee -a $LOGFILE
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist > /dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist > /dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDisabling the warning when changing a file extension\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mWhen switching applications, switch to respective space\033[0m" | tee -a $LOGFILE
    defaults write -g AppleSpacesSwitchOnActivate -bool true > /dev/null 2>&1

# Dock Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Dock)...\033[0m" | tee -a $LOGFILE
 
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSetting Dock to auto-hide, delay and sizing\033[0m" | tee -a $LOGFILE
    defaults write com.apple.dock autohide -bool true > /dev/null 2>&1
    defaults write com.apple.dock autohide-delay -float 0 > /dev/null 2>&1
    defaults write com.apple.dock autohide-time-modifier -float "0.5" > /dev/null 2>&1
    defaults write com.apple.dock tilesize -int 36 > /dev/null 2>&1
    defaults write com.apple.dock show-process-indicators -bool true > /dev/null 2>&1

# Input Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Input & Keyboard)...\033[0m" | tee -a $LOGFILE
 
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mScroll direction not natural\033[0m" | tee -a $LOGFILE
    defaults write -g com.apple.swipescrolldirection -bool NO > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mEnable full keyboard access for all controls (e.g. enable Tab in modal dialogs)\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 > /dev/null 2>&1

# Screenshotting Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Screenshotting)...\033[0m" | tee -a $LOGFILE
 
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSetting screenshot format to PNG\033[0m" | tee -a $LOGFILE
    defaults write com.apple.screencapture type -string "png" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDisable shadow in screenshots\033[0m" | tee -a $LOGFILE
    defaults write com.apple.screencapture disable-shadow -bool true > /dev/null 2>&1

# Terminal Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Terminal)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mEnabling UTF-8 for Terminal.app\033[0m" | tee -a $LOGFILE
    defaults write com.apple.terminal StringEncodings -array 4 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSetting the Pro theme by default\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Terminal "Default Window Settings" -string "Pro" > /dev/null 2>&1
    defaults write com.apple.Terminal "Startup Window Settings" -string "Pro" > /dev/null 2>&1

# Print Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Print)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mAutomatically quit printer app once the print jobs complete\033[0m" | tee -a $LOGFILE
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true > /dev/null 2>&1

# Display Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Display)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mEnabling subpixel font rendering on non-Apple LCDs\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain AppleFontSmoothing -int 2 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mEnabling dark mode\033[0m" | tee -a $LOGFILE
    defaults write "Apple Global Domain" "AppleInterfaceStyle" "Dark" > /dev/null 2>&1

# Apple Mail Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Apple Mail)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSetting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>'\033[0m" | tee -a $LOGFILE
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSetting default view to date descending and threaded\033[0m" | tee -a $LOGFILE
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes" > /dev/null 2>&1
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes" > /dev/null 2>&1
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date" > /dev/null 2>&1


# Safari Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Safari)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mHiding Safari's sidebar in Top Site\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari ShowSidebarInTopSites -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDisabling Safari's thumbnail cache for History and Top Sites\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDisabling Safari's thumbnail cache for History and Top Sites\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mEnable debug, developer and inspector menus\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true > /dev/null 2>&1
    defaults write com.apple.Safari IncludeDevelopMenu -bool true > /dev/null 2>&1
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true > /dev/null 2>&1
    defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mShow full URLs\033[0m" | tee -a $LOGFILE
    defaults write com.apple.safari "ShowFullURLInSmartSearchField" -bool true > /dev/null 2>&1

# Other OS Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Other OS preferences)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mSystem apps to show temprarture in celsius\033[0m" | tee -a $LOGFILE
    defaults write -g AppleTemperatureUnit -string "Celsius" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mMenubar Battery Percentage\033[0m" | tee -a $LOGFILE
    defaults write com.apple.menuextra.battery ShowTime -string "NO" > /dev/null 2>&1
    defaults write com.apple.menuextra.battery ShowPercent -string "YES" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mMenubar hide spotlight and wifi\033[0m" | tee -a $LOGFILE
    defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1 > /dev/null 2>&1
    defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mMenubar format time (EEE d MMM HH:mm) \033[0m" | tee -a $LOGFILE
    defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\"" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDisable the sound effects on boot\033[0m" | tee -a $LOGFILE
    sudo nvram SystemAudioVolume=" " > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mPreventing Time Machine from prompting to use new hard drives as backup volume\033[0m" | tee -a $LOGFILE
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mRemove duplicates in the 'Open With' menu\033[0m" | tee -a $LOGFILE
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user > /dev/null 2>&1

# Other App Specific Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (App specific preferences)...\033[0m" | tee -a $LOGFILE

    # https://stackoverflow.com/questions/39972335/how-do-i-press-and-hold-a-key-and-have-it-repeat-in-vscode
    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mAllow pressing and holding a key to repeat it in VS Code\033[0m" | tee -a $LOGFILE
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mApple Text Editor to use plain text only\033[0m" | tee -a $LOGFILE
    defaults write com.apple.TextEdit RichText -int 0 > /dev/null 2>&1
    defaults write com.apple.TextEdit PlainTextEncoding -int 4 > /dev/null 2>&1
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mApple contacts set locale and allways show birth date\033[0m" | tee -a $LOGFILE
    defaults write com.apple.AddressBook ABBirthDayVisible -bool true > /dev/null 2>&1
    defaults write com.apple.AddressBook ABDefaultAddressCountryCode -string $COUNTRYCODE > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mUnarchiver show folder after extract\033[0m" | tee -a $LOGFILE
    defaults write com.macpaw.site.theunarchiver openExtractedFolder -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓✓ ]\033[0m \033[0;36mDocker enable auto-update\033[0m" | tee -a $LOGFILE
    defaults write com.docker.docker SUAutomaticallyUpdate -bool true > /dev/null 2>&1
    defaults write com.docker.docker SUEnableAutomaticChecks -bool true > /dev/null 2>&1

exit 0

###### SECURITY

# Disable Siri
defaults write com.apple.Siri "UserHasDeclinedEnable" -bool true
defaults write com.apple.Siri "StatusMenuVisible" -bool false
defaults write com.apple.assistant.support "Assistant Enabled" -bool false
#Reveal system info (IP address, hostname, OS version, etc.) when clicking the clock in the login screen
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
#"Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
# Disable Guest User
sudo sysadminctl -guestAccount off
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
#Disable quartine on download messages
defaults write com.apple.LaunchServices LSQuarantine -bool false
# Disable Crash Report
defaults write com.apple.CrashReporter DialogType -string "none"






#"Speeding up wake from sleep to 24 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
# sudo pmset -a standbydelay 86400

# Kill affected applications

killall ${KILLAPPS[@]}

# echo "Setting up Touch ID for sudo..."
# read -p "Press [Enter] key after this..."

# Only run if the tools are not installed yet
# To check that try to print the SDK path
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
  echo "Command Line Tools for Xcode not found. Installing from softwareupdate…"
# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
  softwareupdate -i "$PROD" --verbose;
else
  echo "Command Line Tools for Xcode have been installed."
fi

# find the CLI Tools update
echo "Installing Mac OSX Updates..."
sudo softwareupdate --install --all

# Check for Homebrew
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew installed; updating..."
  brew update
fi

# Brew update
echo "Updating homebrew..."
brew update
brew upgrade

# Homebrew casks
echo "Tapping homebrew casks..."
brew tap homebrew/cask
brew tap homebrew/cask-versions
brew tap homebrew/cask-fonts

# Install Mac OS App Store Apps
# echo "Installing Mac App Store Apps..."
# brew install mas
#
## 441258766   Magnet        (2.11.0)
## 937984704   Amphetamine   (5.2.2)
## 1564015476  ShellHistory  (2.0.0)
## 975937182   Fantastical   (3.7.6)
## 639968404   Parcel        (7.6.6)
#
#
# https://apps.apple.com/us/app/shellhistory/id1564015476
# https://apps.apple.com/au/app/magnet/id441258766?mt=12
# https://apps.apple.com/us/app/amphetamine/id937984704?mt=12
# https://apps.apple.com/us/app/parcel-delivery-tracking/id639968404?mt=12
# https://apps.apple.com/us/app/fantastical-2/id975937182?mt=12&xcust=1675244233370vlst&xs=1

# Install OpenJDK Java
echo "Installing Java (OpenJDK)..."
brew tap AdoptOpenJDK/openjdk
brew install --cask adoptopenjdk
brew install --cask adoptopenjdk11

# Install Homebrew packages

echo "Installing packages..."
brew install ${PACKAGES[@]}

# Set Default Screensaver
echo "Installing packages..."
defaults -currentHost write com.apple.screensaver idleTime 120
defaults -currentHost write com.apple.screensaver 
defaults -currentHost write com.apple.screensaver moduleDict -dict path -string "/Users/$SUDO_USER/Library/Screen Savers/Aerial.saver" moduleName -string "Aerial" type -int 0 

# Install Homebrew casks

echo "Installing cask apps..."
sudo -u $SUDO_USER brew install --appdir="/Applications" --cask ${CASKS[@]}

# Install Other Misc Apps with Homebrew...
echo "Installing Chat GPT client..."
brew tap lencx/chatgpt https://github.com/lencx/ChatGPT.git
sudo -u $SUDO_USER brew install --appdir="/Applications" --cask chatgpt --no-quarantine

# Brew Cleanup
echo "Cleaning homebrew..."
brew cleanup

# Setup Python
# initi after install
export PYENV_ROOT="$(pyenv root)"
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"

which python
pyenv versions
pyenv install $PYVER
pyenv global $PYVER
pyenv versions
which python

# Mackup
if [ -L ~/.mackup.cfg ] ; then
    echo "mackup detected"
    mackup backup
else
    rm -rf ~/.mackup.cfg
    touch ~/.mackup.cfg
    cat <<EOT >> ~/.mackup.cfg
[storage]
engine = icloud
directory = dotfiles
EOT
    #mackup restore
fi

# Brew Doctor
echo "Checking homebrew..."
brew doctor


# Rust
rustup-init --profile default -y
source "$HOME/.cargo/env"
rustup update
rustc --version