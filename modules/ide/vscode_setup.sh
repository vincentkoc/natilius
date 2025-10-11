#!/bin/bash

setup_vscode() {
    local install_vscode="${INSTALL_VSCODE:-false}"
    local install_cursor="${INSTALL_CURSOR:-false}"

    if [ "$install_vscode" = true ] && ! command -v code &> /dev/null; then
        log_info "VSCode not found. Installing..."
        brew install --cask visual-studio-code || log_warning "Failed to install VSCode"
    fi

    if [ "$install_cursor" = true ] && ! command -v cursor &> /dev/null; then
        log_info "Cursor not found. Installing..."
        brew install --cask cursor || log_warning "Failed to install Cursor"
    fi

    declare -a IDE_COMMANDS=()

    if [ "$install_vscode" = true ] && command -v code &> /dev/null; then
        IDE_COMMANDS+=("code")
    fi

    if [ "$install_cursor" = true ] && command -v cursor &> /dev/null; then
        IDE_COMMANDS+=("cursor")
    fi

    if [ ${#IDE_COMMANDS[@]} -eq 0 ]; then
        log_warning "Neither VSCode nor Cursor was installed or found"
        return
    fi

    log_info "Setting up VSCode/Cursor extensions..."

    # Common extensions
    EXTENSIONS=(
        "eamodio.gitlens"
        "esbenp.prettier-vscode"
        "ms-vsliveshare.vsliveshare"
        "enkia.tokyo-night-vscode"
    )

    # Add language-specific extensions
    for env in "${ENABLED_DEV_ENVS[@]}"; do
        case $env in
            python) EXTENSIONS+=("ms-python.python") ;;
            node) EXTENSIONS+=("dbaeumer.vscode-eslint") ;;
            ruby) EXTENSIONS+=("rebornix.ruby") ;;
            php) EXTENSIONS+=("felixfbecker.php-pack") ;;
            java) EXTENSIONS+=("vscjava.vscode-java-pack") ;;
            go) EXTENSIONS+=("golang.go") ;;
            flutter) EXTENSIONS+=("Dart-Code.flutter") ;;
        esac
    done

    for ide in "${IDE_COMMANDS[@]}"; do
        for ext in "${EXTENSIONS[@]}"; do
            "$ide" --install-extension "$ext" || log_warning "Failed to install $ext for $ide"
        done
        log_success "Installed extensions for $ide"
    done
}
