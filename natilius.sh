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
    ~/GIT
    ~/GIT/_Apps
    ~/GIT/_Perso
    ~/GIT/_Hipages
    ~/GIT/_Stj
    ~/GIT/_Airbyte
)
DIRSTOEXCLUDEFROMTIMEMACHINE=(
    ~/.mackup
    ~/GIT
    ~/Dropbox
    ~/.gnupg
    ~/.ssh
)

# Apps to kill post setup to apply changes
KILLAPPS=(
    Address\ Book
    Dock
    Finder
    Mail
    iCal
    iTunes
    Safari
    SystemUIServer
)

# Homebrew Casks to "tap"
BREWTAPS=(
    homebrew/cask
    homebrew/cask-versions
    homebrew/cask-fonts
    lencx/chatgpt
    adoptopenjdk/openjdk
    github/gh
    r-lib/rig
)

# App Store
APPSTORE=(
    # Magnet https://apps.apple.com/au/app/magnet/id441258766?mt=12
    441258766
    # Amphetamine https://apps.apple.com/us/app/amphetamine/id937984704?mt=12
    937984704
    # ShellHistory https://apps.apple.com/us/app/shellhistory/id1564015476
    1564015476
    # Fantastical https://apps.apple.com/us/app/fantastical-2/id975937182?mt=12&xcust=1675244233370vlst&xs=1
    975937182
    # Parcel https://apps.apple.com/us/app/parcel-delivery-tracking/id639968404?mt=12
    639968404
    # Kerberos Ticket Autorenewal https://apps.apple.com/app/id1246781916
    1246781916
    # Endel https://apps.apple.com/us/app/endel-focus-relax-sleep/id1484348796?mt=12
    1484348796
    # Flow https://apps.apple.com/au/app/flow-focus-pomodoro-timer/id1423210932
    1423210932
    # Irvue https://apps.apple.com/app/id1039633667
    1039633667
)

# Homebrew packages to install
#
# Cli replacements:
# cat -> bat
# ssh -> mosh
# vim -> neovim
# grep -> ack + peco
# ls -> exa
# diff -> icdiff
# curl -> httpie
# man -> tealdeer (tldr)
# find -> fd
# top -> htop
# git -> tig
# ps -> procs
# ping -> gping
# dig -> dog
#
# Newer shell/cli tools:
# croc
# fzf
# glow
# hexyl
# jc
# jq
# tokei
# zoxide (z)
#
BREWPACKAGES=(
    ack
    awscli
    bat
    ca-certificates
    coreutils
    curl
    croc
    docker-compose
    dog
    exa
    fd
    fzf
    git
    gh
    git-lfs
    glow
    go
    gping
    gpg
    gradle
    helm
    hexyl
    htop
    httpie
    icdiff
    jenv
    jc
    jq
    kubectl
    kubernetes-cli
    kubernetes-helm
    lynx
    mackup
    make
    mas
    minikube
    mosh
    neovim
    nmap
    node
    nodenv
    npm
    openssl
    peco
    pre-commit
    pyenv
    pyenv-virtualenv
    pipenv
    procs
    rbenv
    readline
    rustup-init
    speedtest-cli
    sqlite3
    tealdeer
    terraform
    terraformer
    tig
    tmux
    tokei
    trash
    tree
    vim
    watch
    wget
    xz
    yamllint
    zlib
    zoxide
)

# Homebrew casks to install
BREWCASKS=(
    aerial
    airbuddy
    alfred
    alt-tab
    amazon-chime
    brave-browser
    charles
    cheatsheet
    dash
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
    kap
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
    # mkchromecast
    # soundflower
    mysqlworkbench
    netnewswire
    notion
    obsidian
    onyx
    pika
    # pock
    postman
    profilecreator
    rescuetime
    rig
    slack
    spotify
    sublime-text
    the-unarchiver
    transmit
    visual-studio-code
    vlc
    xquartz
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
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mMac OS detected [macOS $OSVERSION, $OSTYPE]\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36mRunning as $SUDO_USER\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36mLocale set to $COUNTRYCODE\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;31mNatilius is only supported on Mac OS... Exiting\033[0m" | tee -a $LOGFILE
    exit 0
fi

# Warning
echo -e "\033[0;31m⚠️   !! Warning: Use at your own risk, and ensure you have a backup !!   ⚠️\033[0m" | tee -a $LOGFILE
read -r -s -p $'Press enter to continue...'
echo -e

############################
#
# Check environment (Login, iCloud)
#
############################

# Logging
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mLogging enabled...\033[0m" | tee -a $LOGFILE
echo -e "\033[0;33m[ ! ]\033[0m \033[0;36mLog file printing to [$LOGFILE]\033[0m" | tee -a $LOGFILE
echo -e | tee -a $LOGFILE

# Password for Sudo
echo -e "\033[0;36mPlease provide local password (may auto-skip)...\033[0m" | tee -a $LOGFILE
sudo -v
echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPassword validated\033[0m" | tee -a $LOGFILE

# iCloud Drive
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if iCloud drive has been mounted...\033[0m" | tee -a $LOGFILE
if [ -d ~/Library/Mobile\ Documents/com~apple~CloudDocs/ ]; then
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36miCloud Drive is located\033[0m" | tee -a $LOGFILE
else
    echo -e "\033[0;31mError iCloud Drive not setup [~/Library/Mobile\ Documents/com~apple~CloudDocs/]... Exiting\033[0m" | tee -a $LOGFILE
    exit 0
fi

# xcode install
rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress 2> /dev/null || true
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if Command Line Tools for Xcode is installed...\033[0m" | tee -a $LOGFILE
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36mCommand Line Tools for Xcode not found. Installing from softwareupdate…\033[0m" | tee -a $LOGFILE
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --agree-to-license --verbose | tee -a $LOGFILE
else
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mCommand Line Tools for Xcode is already installed\033[0m" | tee -a $LOGFILE
fi

# Mac OS updates
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mInstalling rosetta (for M1 macs)...\033[0m" | tee -a $LOGFILE
sudo softwareupdate --install-rosetta --agree-to-license --verbose | tee -a $LOGFILE || true
echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mUpdate rosetta operation completed\033[0m" | tee -a $LOGFILE

# Mac OS updates
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mChecking to see if any Mac OS updates and installing...\033[0m" | tee -a $LOGFILE
sudo softwareupdate --install --all --agree-to-license --verbose  | tee -a $LOGFILE
echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mUpdate checks completed\033[0m" | tee -a $LOGFILE

# Homebrew
echo -e
echo -e "\033[0;36mChecking to see if homebrew is installed...\033[0m" | tee -a $LOGFILE
if [[ $(command -v brew) == "" ]]; then
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36mInstalling homebrew...\033[0m" | tee -a $LOGFILE
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee -a $LOGFILE
    export PATH="/usr/local/bin:$PATH"
    echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mhomebrew should be installed, please restart this script if you have issues...\033[0m" | tee -a $LOGFILE
    #exit 0
else
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mUpdating homebrew\033[0m" | tee -a $LOGFILE
    brew update && brew upgrade | tee -a $LOGFILE
fi

echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mDisabling homebrew analytics module\033[0m" | tee -a $LOGFILE
brew analytics off


# Quit preferences pane
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mClosing System Preferences pane if open...\033[0m" | tee -a $LOGFILE
osascript -e 'tell application "System Preferences" to quit' | tee -a $LOGFILE
echo -e "\033[0;33m[ ? ]\033[0m \033[0;36mSystem Preferences pane closed\033[0m" | tee -a $LOGFILE

############################
#
# Setup OS environment
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSetting up custom home directories...\033[0m" | tee -a $LOGFILE
for a in "${DIRS[@]}";
do mkdir -p $a && echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mCreated folder if missing [$a]\033[0m" 2>/dev/null | tee -a $LOGFILE || true
done

echo -e "\033[0;36mAdding custom exclusions to Time Machine...\033[0m" | tee -a $LOGFILE
for a in "${DIRSTOEXCLUDEFROMTIMEMACHINE[@]}";
do
    sudo tmutil $a 2>/dev/null || true
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mTime machine exclusions included [$a]\033[0m" | tee -a $LOGFILE 
done


# Finder Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Finder)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Expanding the save panel by default\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true > /dev/null 2>&1
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Disable the “reopen windows when logging back in” option\033[0m" | tee -a $LOGFILE
    defaults write com.apple.loginwindow TALLogoutSavesState -bool false > /dev/null 2>&1
    defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Show status and path bar in Finder\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder ShowStatusBar -bool true > /dev/null 2>&1
    defaults write com.apple.finder ShowPathbar -bool true> /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Use column view in all Finder windows by default\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Allow text selection in Quick Look\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder QLEnableTextSelection -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Smaller sidebar icons\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Show hidden ~/Library folder\033[0m" | tee -a $LOGFILE
    chflags nohidden ~/Library > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Show all hidden files and extensions\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true > /dev/null 2>&1
    defaults write com.apple.Finder AppleShowAllFiles YES > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Showing icons for hard drives, servers, removables on the desktop\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Folders allways ontop\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder "_FXSortFoldersFirst" -bool true > /dev/null 2>&1
    defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Search Scope set to current folder\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Avoiding the creation of .DS_Store files on non-physical volumes\033[0m" | tee -a $LOGFILE
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true > /dev/null 2>&1
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Enabling snap-to-grid for icons on the desktop and in other icon views\033[0m" | tee -a $LOGFILE
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist > /dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist > /dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Disabling the warning when changing a file extension\033[0m" | tee -a $LOGFILE
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: When switching applications, switch to respective space\033[0m" | tee -a $LOGFILE
    defaults write -g AppleSpacesSwitchOnActivate -bool true > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Disable smart quotes and dashes when typing\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false > /dev/null 2>&1
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Finder: Disable automatic period substitution and capitalisation when typing\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false > /dev/null 2>&1
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false > /dev/null 2>&1

    # echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mDisable auto-correct\033[0m" | tee -a $LOGFILE
    # defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false > /dev/null 2>&1

# Dock Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Dock)...\033[0m" | tee -a $LOGFILE
 
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Dock: Setting Dock to auto-hide, delay and sizing\033[0m" | tee -a $LOGFILE
    defaults write com.apple.dock autohide -bool true > /dev/null 2>&1
    defaults write com.apple.dock autohide-delay -float 0 > /dev/null 2>&1
    defaults write com.apple.dock autohide-time-modifier -float "0.5" > /dev/null 2>&1
    defaults write com.apple.dock tilesize -int 36 > /dev/null 2>&1
    defaults write com.apple.dock show-process-indicators -bool true > /dev/null 2>&1

# Input Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Input & Keyboard)...\033[0m" | tee -a $LOGFILE
 
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Input: Scroll direction not natural\033[0m" | tee -a $LOGFILE
    defaults write -g com.apple.swipescrolldirection -bool NO > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Input: Enable full keyboard access for all controls/modals\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 > /dev/null 2>&1

# Screenshotting Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Screenshotting)...\033[0m" | tee -a $LOGFILE
 
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Screenshots: Setting format to PNG\033[0m" | tee -a $LOGFILE
    defaults write com.apple.screencapture type -string "png" > /dev/null 2>&1
    defaults write com.apple.screencapture name "Screenshot" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Screenshots: Disable shadows\033[0m" | tee -a $LOGFILE
    defaults write com.apple.screencapture disable-shadow -bool true > /dev/null 2>&1

# Terminal Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Terminal)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Terminal: Enabling UTF-8 for Terminal.app\033[0m" | tee -a $LOGFILE
    defaults write com.apple.terminal StringEncodings -array 4 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Terminal: Setting the Pro theme by default\033[0m" | tee -a $LOGFILE
    defaults write com.apple.Terminal "Default Window Settings" -string "Pro" > /dev/null 2>&1
    defaults write com.apple.Terminal "Startup Window Settings" -string "Pro" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Terminal: X11 follow focus mouse\033[0m" | tee -a $LOGFILE
    defaults write com.apple.terminal FocusFollowsMouse -string YES > /dev/null 2>&1
    defaults write org.x.X11 wm_ffm -bool true > /dev/null 2>&1

# Print Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Print)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Print: Auto quit app once the print jobs done\033[0m" | tee -a $LOGFILE
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true > /dev/null 2>&1

# Display Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Display)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Display: Enabling subpixel font rendering on non-Apple LCDs\033[0m" | tee -a $LOGFILE
    defaults write NSGlobalDomain AppleFontSmoothing -int 2 > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Display: Enabling dark mode\033[0m" | tee -a $LOGFILE
    defaults write "Apple Global Domain" "AppleInterfaceStyle" "Dark" > /dev/null 2>&1

# Apple Mail Related Preferences
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mUpdating preferences (Apple Mail)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Mail: Setting email addresses to copy as 'foo@e.com' instead of 'Foo' <foo@e.com>'\033[0m" | tee -a $LOGFILE
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Mail: Setting default view to date descending and threaded\033[0m" | tee -a $LOGFILE
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes" > /dev/null 2>&1
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes" > /dev/null 2>&1
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date" > /dev/null 2>&1


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
    defaults write com.apple.menuextra.battery ShowTime -string "NO" > /dev/null 2>&1
    defaults write com.apple.menuextra.battery ShowPercent -string "YES" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar hide spotlight and wifi\033[0m" | tee -a $LOGFILE
    defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1 > /dev/null 2>&1
    defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Menubar format time (EEE d MMM HH:mm) \033[0m" | tee -a $LOGFILE
    defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\"" > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: Disable the sound effects on boot\033[0m" | tee -a $LOGFILE
    sudo nvram SystemAudioVolume=" " > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mPref > Other: iOS charing chime when plugged into magsafe\033[0m" | tee -a $LOGFILE
    defaults write com.apple.PowerChime ChimeOnAllHardware -bool true > /dev/null 2>&1
    open /System/Library/CoreServices/PowerChime.app > /dev/null 2>&1

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
            sudo networksetup -setv6off $line
        fi
    done <<< "$NETWORKADAPTERS"

    # echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable infared\033[0m" | tee -a $LOGFILE
    # defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -int 0 > /dev/null 2>&1

    # echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Disable SSH\033[0m" | tee -a $LOGFILE
    # sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable gatekeeper (code signing verification)\033[0m" | tee -a $LOGFILE
    sudo spctl --master-enable

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Critical: Enable filevault (disk encryption)\033[0m" | tee -a $LOGFILE
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36m...You may be asked for login again, please keep recovery key safe\033[0m" | tee -a $LOGFILE
    if [[ $(sudo fdesetup status) != "FileVault is On." ]];then
        sudosudo fdesetup enable
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

# Update related Security Tweaks
echo -e | tee -a $LOGFILE
echo -e "\033[0;36mSecurity tweaks (Updates)...\033[0m" | tee -a $LOGFILE

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Updates: Time machine dose not require AC power (magsafe)\033[0m" | tee -a $LOGFILE
    sudo defaults write /Library/Preferences/com.apple.TimeMachine RequiresACPower -bool false > /dev/null 2>&1

    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mSecurity > Updates: Enabling scheduled updates\033[0m" | tee -a $LOGFILE
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
# Mac App Store (mas)
#
############################

echo -e | tee -a $LOGFILE
echo -e "\033[0;36mInstalling Apple App Store apps...\033[0m" | tee -a $LOGFILE
for a in "${APPSTORE[@]}";
do
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36mInstalling app [$a]\033[0m" | tee -a $LOGFILE
    sudo -u $SUDO_USER brew install --appdir="/Applications" --cask $a | tee -a $LOGFILE
    echo -e 
    sleep 2
done

# espanso service register



############################
#
# Homebrew Java
#
############################

# Install Mac OS App Store Apps
# echo "Installing Mac App Store Apps..."
# brew install mas
#


# # Install OpenJDK Java
# echo "Installing Java (OpenJDK)..."
# brew tap AdoptOpenJDK/openjdk
# brew install --cask adoptopenjdk
# brew install --cask adoptopenjdk16
# jenv add /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home 
# > jenv local 17.0
# > java -version                                                                                                                                     
# openjdk version "17.0.1" 2021-10-19
# OpenJDK Runtime Environment Homebrew (build 17.0.1+1)
# OpenJDK 64-Bit Server VM Homebrew (build 17.0.1+1, mixed mode, sharing)
# https://formulae.brew.sh/cask/temurin
# https://gist.github.com/bondolo/5ce1a1c0d38e72a80a79ac28f951c9a5

# # Set Default Screensaver
# echo "Installing packages..."
# defaults -currentHost write com.apple.screensaver idleTime 120
# defaults -currentHost write com.apple.screensaver 
# defaults -currentHost write com.apple.screensaver moduleDict -dict path -string "/Users/$SUDO_USER/Library/Screen Savers/Aerial.saver" moduleName -string "Aerial" type -int 0 

# # Install Homebrew casks

# echo "Installing cask apps..."
# sudo -u $SUDO_USER brew install --appdir="/Applications" --cask ${CASKS[@]}

# # Install Other Misc Apps with Homebrew...
# echo "Installing Chat GPT client..."
# brew tap
# sudo -u $SUDO_USER brew install --appdir="/Applications" --cask chatgpt --no-quarantine

# # Brew Cleanup
# echo "Cleaning homebrew..."
# brew cleanup

# # Setup Python
# # initi after install
# export PYENV_ROOT="$(pyenv root)"
# export PATH="$PYENV_ROOT/shims:$PATH"
# eval "$(pyenv init -)"

# which python
# pyenv versions
# pyenv install $PYVER
# pyenv global $PYVER
# pyenv versions
# which python

# # Mackup
# if [ -L ~/.mackup.cfg ] ; then
#     echo "mackup detected"
#     mackup backup
# else
#     rm -rf ~/.mackup.cfg
#     touch ~/.mackup.cfg
#     cat <<EOT >> ~/.mackup.cfg
# [storage]
# engine = icloud
# directory = dotfiles
# EOT
#     #mackup restore
# fi

# # Brew Doctor
# echo "Checking homebrew..."
# brew doctor



# # Rust
# rustup-init --profile default -y
# source "$HOME/.cargo/env"
# rustup update
# rustc --version