#!/bin/bash

setup_jetbrains_ides() {
    JETBRAINS_IDES=("idea" "pycharm" "webstorm" "phpstorm" "rubymine" "goland")
    for ide in "${JETBRAINS_IDES[@]}"; do
        if ! command -v "$ide" &> /dev/null; then
            log_info "$ide not found. Installing..."
            brew install --cask "$ide-ce" || log_warning "Failed to install $ide"
        fi

        if command -v "$ide" &> /dev/null; then
            log_info "Setting up $ide..."
            PLUGINS=(
                "com.intellij.plugins.github"
                "org.jetbrains.plugins.github"
            )
            # Add language-specific plugins
            for env in "${ENABLED_DEV_ENVS[@]}"; do
                case $env in
                    python) [[ $ide == "pycharm" ]] && PLUGINS+=("PythonCore") ;;
                    node) PLUGINS+=("JavaScriptLanguage" "NodeJS") ;;
                    ruby) [[ $ide == "rubymine" ]] && PLUGINS+=("org.jetbrains.plugins.ruby") ;;
                    php) [[ $ide == "phpstorm" ]] && PLUGINS+=("com.jetbrains.php") ;;
                    java) [[ $ide == "idea" ]] && PLUGINS+=("com.intellij.java") ;;
                    go) [[ $ide == "goland" ]] && PLUGINS+=("org.jetbrains.plugins.go") ;;
                    flutter) PLUGINS+=("io.flutter") ;;
                esac
            done
            for plugin in "${PLUGINS[@]}"; do
                $ide installPlugins "$plugin" || log_warning "Failed to install JetBrains plugin: $plugin"
            done
            log_success "$ide setup completed"
        fi
    done
}
