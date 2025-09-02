#!/bin/bash

setup_sublime_text() {
    if ! command -v subl &> /dev/null; then
        log_info "Sublime Text not found. Installing..."
        brew install --cask sublime-text
    fi

    if command -v subl &> /dev/null; then
        log_info "Setting up Sublime Text..."
        PACKAGES=(
            "Package Control"
            "GitGutter"
            "SublimeLinter"
        )
        # Add language-specific packages
        for env in "${ENABLED_DEV_ENVS[@]}"; do
            case $env in
                python) PACKAGES+=("Anaconda") ;;
                node) PACKAGES+=("JavaScript Completions") ;;
                ruby) PACKAGES+=("Ruby") ;;
                php) PACKAGES+=("PHP Companion") ;;
                java) PACKAGES+=("JavaImports") ;;
                go) PACKAGES+=("GoSublime") ;;
                flutter) PACKAGES+=("Dart" "Flutter") ;;
            esac
        done
        for package in "${PACKAGES[@]}"; do
            subl --command "PackageControl: Install Package $package" || log_warning "Failed to install Sublime Text package: $package"
        done
        log_success "Sublime Text setup completed"
    else
        log_warning "Failed to install Sublime Text"
    fi
}
