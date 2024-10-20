#!/bin/bash

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
