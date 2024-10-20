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

# Display the ASCII intro
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
 development on a Mac machine by scaffolding
 all your key development apps, settings, dotfiles
 configuration, and have you up and running in no
 time. Developed by Vincent Koc (@koconder)

 This script assumes iCloud as the primary
 location for dotfiles and configuration.

 Starting Natilius...
EOF

echo -e "\033[0m"

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

# Conclusion
echo -e | tee -a "$LOGFILE"
echo -e | tee -a "$LOGFILE"
echo -e "\033[0;32m[ 🐚 ]\033[0m \033[0;36mNatilius install script has completed!\033[0m" | tee -a "$LOGFILE"
echo -e "\033[0;33m"
cat << EOF
 Thanks for using Natilius :)
 Your logfile is saved at $LOGFILE

 You are welcome to leave feedback, comments, and issues
 directly on GitHub at (https://github.com/koconder/natilius).

 I also welcome PRs and suggestions to speed up the
 setup of your development environment.

 Thanks
 Vince

EOF
echo -e "\033[0m"
