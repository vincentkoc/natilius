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

# Java Development Environment Module

log_info "Setting up Java environment..."

# Check if jenv is installed; if not, install it
if ! command -v jenv &> /dev/null; then
    log_info "jenv not found. Installing jenv..."
    brew install jenv
fi

log_info "Adding jenv to PATH and initializing..."
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init - | grep -v 'jenv rehash')"

# Get current version
log_info "Getting current Java version..."
CURRENTVER=$(jenv version-name 2>/dev/null || echo "none")
INSTALLED=false

# Check if the desired JDKVER is installed
log_info "Checking if desired Java version $JDKVER is installed..."
while read -r version; do
    if version_compare "$version" "$JDKVER"; then
        INSTALLED=true
        CURRENTVER=$version
        break
    fi
done <<< "$(jenv versions --bare 2>/dev/null || echo "")"

if [ "$INSTALLED" = true ]; then
    log_success "OpenJDK [$CURRENTVER] is already installed (matches or exceeds $JDKVER)."
    log_info "Skipping installation of OpenJDK."
    java --version | tee -a "$LOGFILE"
    which java | tee -a "$LOGFILE"
else
    log_warning "OpenJDK [$JDKVER] or higher is not installed. Found [$CURRENTVER]."
    log_info "Installing Java (OpenJDK) and related tools..."

    # Install JDK(s) and related tools
    brew install --cask temurin
    brew install --cask temurin8
    brew install maven
    brew install scala
    brew install apache-spark
    log_success "Installed OpenJDK and related tools"

    # Add all found JDKs to jenv
    log_info "Adding JDKs to jenv..."
    for jdk in /Library/Java/JavaVirtualMachines/*; do
        jenv add "${jdk}/Contents/Home/" | tee -a "$LOGFILE"
    done

    # Set the highest version as the global version if it differs from JDKVER
    log_info "Setting global Java version..."
    HIGHESTVER=$(jenv versions --bare | sort -V | tail -n 1)
    if version_compare "$HIGHESTVER" "$JDKVER"; then
        jenv global "$HIGHESTVER"
    else
        jenv global "$JDKVER"
    fi
    log_success "Set global Java version to $(jenv global)"

    # Display the active Java version
    java --version | tee -a "$LOGFILE"

    # Enable jenv plugins
    log_info "Enabling jenv plugins..."
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

# Use the safe_rehash function
safe_rehash "jenv"
