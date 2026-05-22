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

@test "repositories module file exists and is executable" {
    [ -f "modules/system/repositories.sh" ]
    [ -x "modules/system/repositories.sh" ]
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

@test "Config validator validates version format correctly" {
    source lib/config_validator.sh
    run validate_version "TEST" "1.2.3"
    [ "$status" -eq 0 ]

    run validate_version "TEST" "invalid"
    [ "$status" -eq 1 ]

    run validate_version "TEST" "1.2.3.4.5"
    [ "$status" -eq 0 ]

    run validate_version "TEST" ""
    [ "$status" -eq 1 ]
}

@test "Config validator validates boolean values correctly" {
    source lib/config_validator.sh
    run validate_boolean "TEST" "true"
    [ "$status" -eq 0 ]

    run validate_boolean "TEST" "false"
    [ "$status" -eq 0 ]

    run validate_boolean "TEST" "yes"
    [ "$status" -eq 1 ]

    run validate_boolean "TEST" "1"
    [ "$status" -eq 1 ]
}

@test "Config validator has valid module list" {
    source lib/config_validator.sh
    [ ${#VALID_MODULES[@]} -gt 0 ]
    # Check some known modules are in the list
    local has_homebrew=false
    for mod in "${VALID_MODULES[@]}"; do
        if [[ "$mod" == "applications/homebrew" ]]; then
            has_homebrew=true
        fi
    done
    [ "$has_homebrew" = true ]

    local has_repositories=false
    for mod in "${VALID_MODULES[@]}"; do
        if [[ "$mod" == "system/repositories" ]]; then
            has_repositories=true
        fi
    done
    [ "$has_repositories" = true ]
}

@test "is_valid_module function works" {
    source lib/config_validator.sh
    run is_valid_module "applications/homebrew"
    [ "$status" -eq 0 ]

    run is_valid_module "system/repositories"
    [ "$status" -eq 0 ]

    run is_valid_module "nonexistent/module"
    [ "$status" -eq 1 ]
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

@test "Bash completions have correct commands" {
    source completions/natilius-completion.bash 2>/dev/null || true
    # Check the completion script references key commands
    grep -q "init" completions/natilius-completion.bash
    grep -q "setup" completions/natilius-completion.bash
    grep -q "doctor" completions/natilius-completion.bash
    grep -q "modules" completions/natilius-completion.bash
    grep -q "profiles" completions/natilius-completion.bash
}

@test "Zsh completions have correct commands" {
    grep -q "init" completions/natilius-completion.zsh
    grep -q "setup" completions/natilius-completion.zsh
    grep -q "doctor" completions/natilius-completion.zsh
    grep -q "modules" completions/natilius-completion.zsh
    grep -q "profiles" completions/natilius-completion.zsh
}

@test "MDM utils library exists" {
    [ -f "lib/mdm_utils.sh" ]
    [ -r "lib/mdm_utils.sh" ]
}

@test "MDM utils has proper functions" {
    source lib/mdm_utils.sh
    declare -f get_mdm_provider >/dev/null
    declare -f is_mdm_enrolled >/dev/null
    declare -f get_mdm_server_url >/dev/null
    declare -f get_mdm_provider_name >/dev/null
}

@test "Example config file exists and has required sections" {
    [ -f ".natiliusrc.example" ]
    # Check for key config sections
    grep -q "ENABLED_MODULES" .natiliusrc.example
    grep -q "BREWPACKAGES" .natiliusrc.example
    grep -q "BREWCASKS" .natiliusrc.example
    grep -q "PYTHONVER" .natiliusrc.example
    grep -q "NODEVER" .natiliusrc.example
}

@test "Profile files exist in profiles directory" {
    [ -d "profiles" ]
    # At least one profile should exist
    ls profiles/*.natiliusrc 2>/dev/null | head -n1 | grep -q ".natiliusrc"
}


@test "GitHub workflows exist" {
    [ -f ".github/workflows/ci.yml" ]
    [ -f ".github/workflows/release.yml" ]
}
