#!/bin/bash

# Java Development Environment Module

log_info "Setting up Java environment..."

# Install jenv if not installed
if ! command -v jenv &> /dev/null; then
    brew install jenv
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Install Java versions
brew install --cask adoptopenjdk"$JDKVER"
jenv add "/Library/Java/JavaVirtualMachines/adoptopenjdk-$JDKVER.jdk/Contents/Home/"

jenv global "$JDKVER"
log_success "Set global Java version to $JDKVER"

# Enable plugins
jenv enable-plugin maven
jenv enable-plugin gradle

log_success "Java environment setup complete"
