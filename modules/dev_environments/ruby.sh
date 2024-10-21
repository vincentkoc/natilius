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
# Ruby Development Environment Module

log_info "Setting up Ruby environment..."

# Check if rbenv is installed; if not, install it
if ! command -v rbenv &> /dev/null; then
    log_info "rbenv not found. Installing rbenv..."
    brew install rbenv

    # Install ruby-build as an rbenv plugin
    if [ ! -d "$(rbenv root)/plugins/ruby-build" ]; then
        log_info "Installing ruby-build plugin for rbenv..."
        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)/plugins/ruby-build"
    fi

    # Install rbenv-default-gems as an rbenv plugin
    if [ ! -d "$(rbenv root)/plugins/rbenv-default-gems" ]; then
        log_info "Installing rbenv-default-gems plugin for rbenv..."
        git clone https://github.com/rbenv/rbenv-default-gems.git "$(rbenv root)/plugins/rbenv-default-gems"
    fi

    # Create a default-gems file with default gems to install
    log_info "Creating default-gems file..."
    cat << EOF > "$(rbenv root)/default-gems"
bundler
EOF
fi

# Initialize rbenv
log_info "Adding rbenv to PATH and initializing..."
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - | grep -v 'rbenv rehash')"

# Check if desired Ruby version is installed
CURRENTVER=$(get_current_version rbenv)
INSTALLED=false

while read -r version; do
    if [[ "$version" == "$RUBYVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(rbenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    log_success "Ruby [$RUBYVER] is already installed."
    log_info "Skipping installation of Ruby."
    ruby --version | tee -a "$LOGFILE"
    which ruby | tee -a "$LOGFILE"
else
    log_warning "Ruby [$RUBYVER] is not installed. Found [$CURRENTVER]."
    log_info "Installing Ruby [$RUBYVER]..."
    rbenv install "$RUBYVER" | tee -a "$LOGFILE"

    # Set RUBYVER as the global Ruby version
    rbenv global "$RUBYVER"

    # If there are other versions installed, set the highest one as the global version
    HIGHESTVER=$(get_highest_version rbenv)
    if [ "$HIGHESTVER" != "$RUBYVER" ]; then
        rbenv global "$HIGHESTVER"
        log_info "Set highest Ruby version [$HIGHESTVER] as global version."
    fi

    # Show the active Ruby version
    ruby --version | tee -a "$LOGFILE"

    # Update the RubyGems system software to the latest version
    log_info "Updating RubyGems..."
    gem update --system | tee -a "$LOGFILE"

    # Update all installed gems to their latest versions
    log_info "Updating installed gems..."
    gem update | tee -a "$LOGFILE"

    # Install Bundler if not already installed
    if ! gem list bundler -i > /dev/null; then
        log_info "Installing Bundler..."
        gem install bundler | tee -a "$LOGFILE"
    fi

    # Use rbenv-doctor to check the setup
    log_info "Running rbenv-doctor to verify the setup..."
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-doctor | bash | tee -a "$LOGFILE"

    log_success "Ruby environment setup complete"
fi

# Use the safe_rehash function
safe_rehash "rbenv"
