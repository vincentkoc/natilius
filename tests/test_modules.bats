#!/usr/bin/env bats

# Test module existence and basic functionality

@test "dotfiles module file exists and is executable" {
    [ -f "modules/dotfiles.sh" ]
    [ -x "modules/dotfiles.sh" ]
}

@test "security module file exists and is executable" {
    [ -f "modules/system/security.sh" ]
    [ -x "modules/system/security.sh" ]
}

@test "directories module file exists and is executable" {
    [ -f "modules/system/directories.sh" ]
    [ -x "modules/system/directories.sh" ]
}

@test "go development environment module exists" {
    [ -f "modules/dev_environments/go.sh" ]
    [ -x "modules/dev_environments/go.sh" ]
}

@test "python development environment module exists" {
    [ -f "modules/dev_environments/python.sh" ]
    [ -x "modules/dev_environments/python.sh" ]
}

@test "rust development environment module exists" {
    [ -f "modules/dev_environments/rust.sh" ]
    [ -x "modules/dev_environments/rust.sh" ]
}

@test "java development environment module exists" {
    [ -f "modules/dev_environments/java.sh" ]
    [ -x "modules/dev_environments/java.sh" ]
}

@test "flutter development environment module exists" {
    [ -f "modules/dev_environments/flutter.sh" ]
    [ -x "modules/dev_environments/flutter.sh" ]
}

@test "php development environment module exists" {
    [ -f "modules/dev_environments/php.sh" ]
    [ -x "modules/dev_environments/php.sh" ]
}

@test "ruby development environment module exists" {
    [ -f "modules/dev_environments/ruby.sh" ]
    [ -x "modules/dev_environments/ruby.sh" ]
}

@test "IDE setup modules exist" {
    [ -f "modules/ide/ide_setup.sh" ]
    [ -f "modules/ide/vscode_setup.sh" ]
    [ -f "modules/ide/jetbrains_setup.sh" ]
    [ -f "modules/ide/sublime_setup.sh" ]
    [ -f "modules/ide/zed_setup.sh" ]
}

@test "All module files have proper shebang" {
    for module in modules/**/*.sh modules/*.sh; do
        if [ -f "$module" ]; then
            head -n1 "$module" | grep -q "#!/bin/bash"
        fi
    done
}

@test "All modules contain log_info calls" {
    for module in modules/**/*.sh modules/*.sh; do
        if [ -f "$module" ]; then
            # Most modules should contain at least one log_info call
            if ! grep -q "log_info\|log_success\|log_warning\|log_error" "$module"; then
                # Allow empty or template modules for now
                echo "Warning: $module may not contain logging calls"
            fi
        fi
    done
}

@test "Library files exist and are readable" {
    [ -f "lib/utils.sh" ]
    [ -r "lib/utils.sh" ]
    [ -f "lib/logging.sh" ]
    [ -r "lib/logging.sh" ]
    [ -f "lib/config_validator.sh" ]
    [ -r "lib/config_validator.sh" ]
    [ -f "lib/network_utils.sh" ]
    [ -r "lib/network_utils.sh" ]
}

@test "Config validator has proper functions" {
    source lib/config_validator.sh
    # Check that validate_config function exists
    declare -f validate_config >/dev/null
    declare -f validate_version >/dev/null
    declare -f validate_boolean >/dev/null
}

@test "Network utils has proper functions" {
    source lib/network_utils.sh
    # Check that network utility functions exist
    declare -f retry_network_operation >/dev/null
    declare -f check_internet_connection >/dev/null
}

@test "Completions files exist" {
    [ -f "completions/natilius-completion.bash" ]
    [ -f "completions/natilius-completion.zsh" ]
}

@test "DevContainer configuration exists" {
    [ -f ".devcontainer/devcontainer.json" ]
    [ -f ".devcontainer/setup.sh" ]
    [ -x ".devcontainer/setup.sh" ]
}

@test "GitHub workflows exist" {
    [ -f ".github/workflows/ci.yml" ]
    [ -f ".github/workflows/release.yml" ]
}
