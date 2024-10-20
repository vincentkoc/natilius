#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment
#
# Copyright (C) 2023 Vincent Koc (@koconder)
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

# Java Development Environment Module

log_info "Setting up Java environment..."

# Check if jenv is installed; if not, install it
if ! command -v jenv &> /dev/null; then
    log_info "jenv not found. Installing jenv..."
    brew install jenv
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Get current version
CURRENTVER=$(get_current_version jenv)
INSTALLED=false

# Check if the desired JDKVER is installed
while read -r version; do
    if [[ "$version" == "$JDKVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(jenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    log_success "OpenJDK [$JDKVER] is already installed."
    log_info "Skipping installation of OpenJDK."
    java --version | tee -a "$LOGFILE"
    which java | tee -a "$LOGFILE"
else
    log_warning "OpenJDK [$JDKVER] is not installed. Found [$CURRENTVER]."
    log_info "Installing Java (OpenJDK) and related tools..."

    # Install JDK(s) and related tools
    brew install --cask temurin
    brew install --cask temurin8
    brew install maven
    brew install scala
    brew install apache-spark
    log_success "Installed OpenJDK and related tools"

    # Add all found JDKs to jenv
    for jdk in /Library/Java/JavaVirtualMachines/*; do
        jenv add "${jdk}/Contents/Home/" | tee -a "$LOGFILE"
    done

    # Set the highest version as the global version if it differs from JDKVER
    HIGHESTVER=$(get_highest_version jenv)
    if [ "$HIGHESTVER" != "$JDKVER" ]; then
        jenv global "$HIGHESTVER"
    else
        jenv global "$JDKVER"
    fi
    log_success "Set global Java version to $(jenv global)"

    # Display the active Java version
    java --version | tee -a "$LOGFILE"

    # Enable jenv plugins
    jenv enable-plugin maven
    jenv enable-plugin scala
    jenv enable-plugin gradle
    log_success "Enabled jenv plugins: maven, scala, gradle"

    # Verify installations
    log_info "Verifying installations..."
    jenv exec mvn -version | tee -a "$LOGFILE"
    jenv exec scala -version | tee -a "$LOGFILE"
    jenv exec gradle -version | tee -a "$LOGFILE"

    # Run jenv doctor
    log_info "Running jenv doctor..."
    jenv doctor | tee -a "$LOGFILE"

    log_success "Java environment setup complete"
fi
