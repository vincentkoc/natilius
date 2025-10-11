#!/bin/bash

setup_sublime_text() {
    if ! command -v subl &> /dev/null; then
        log_info "Sublime Text not found. Installing..."
        brew install --cask sublime-text
    fi

    if command -v subl &> /dev/null; then
        log_info "Setting up Sublime Text..."

        BASE_PACKAGES=(
            "Package Control"
            "A File Icon"
            "BracketHighlighter"
            "Color Highlighter"
            "Enki Theme"
            "GitGutter"
            "SublimeLinter"
            "SideBarEnhancements"
        )

        PACKAGES=("${BASE_PACKAGES[@]}")

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
            if ! subl --command "Package Control: Install Package ${package}"; then
                log_warning "Failed to queue Sublime Text package: $package"
            fi
        done
    else
        log_warning "Failed to install Sublime Text"
    fi
}
