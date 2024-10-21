#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment (https://github.com/vincentkoc/natilius)
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


validate_config() {
    local config_file="$1"
    local errors=0

    # Check if file exists
    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi

    # Source the config file
    source "$config_file"

    # Validate ENABLED_MODULES
    if [ ${#ENABLED_MODULES[@]} -eq 0 ]; then
        log_error "No modules enabled in configuration"
        errors=$((errors + 1))
    fi

    # Validate version numbers
    validate_version "JDKVER" "$JDKVER"
    validate_version "PYTHONVER" "$PYTHONVER"
    validate_version "RUBYVER" "$RUBYVER"
    validate_version "NODEVER" "$NODEVER"
    validate_version "GOVER" "$GOVER"

    # Validate boolean values
    validate_boolean "SKIP_UPDATE_CHECK" "$SKIP_UPDATE_CHECK"
    validate_boolean "INSTALL_VSCODE" "$INSTALL_VSCODE"
    validate_boolean "INSTALL_CURSOR" "$INSTALL_CURSOR"
    validate_boolean "INSTALL_JETBRAINS" "$INSTALL_JETBRAINS"
    validate_boolean "INSTALL_SUBLIME" "$INSTALL_SUBLIME"
    validate_boolean "INSTALL_ZED" "$INSTALL_ZED"

    if [ $errors -gt 0 ]; then
        log_error "Found $errors error(s) in configuration"
        return 1
    fi

    log_success "Configuration validation passed"
    return 0
}

validate_version() {
    local name="$1"
    local version="$2"
    if [ -z "$version" ] || ! [[ "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        log_error "Invalid $name version: $version"
        errors=$((errors + 1))
    fi
}

validate_boolean() {
    local name="$1"
    local value="$2"
    if [ -z "$value" ] || { [ "$value" != "true" ] && [ "$value" != "false" ]; }; then
        log_error "Invalid $name value: $value (should be true or false)"
        errors=$((errors + 1))
    fi
}
