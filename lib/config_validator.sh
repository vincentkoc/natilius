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


# Valid modules list
VALID_MODULES=(
    "system/system_update"
    "system/directories"
    "system/repositories"
    "system/security"
    "system/cleanup"
    "preferences/mac_preferences"
    "preferences/system_preferences"
    "applications/homebrew"
    "applications/apps"
    "applications/espanso"
    "dev_environments/java"
    "dev_environments/ruby"
    "dev_environments/python"
    "dev_environments/node"
    "dev_environments/rust"
    "dev_environments/go"
    "dev_environments/php"
    "dev_environments/flutter"
    "ide/ide_setup"
    "dotfiles"
)

# Configuration schema - defines expected types and defaults
# Format: "VAR_NAME:type:required:default"
# Reserved for future schema-based validation
# shellcheck disable=SC2034
CONFIG_SCHEMA=(
    "ENABLED_MODULES:array:yes:"
    "COUNTRYCODE:string:no:us"
    "JDKVER:version:no:20"
    "PYTHONVER:version:no:3.11.0"
    "RUBYVER:version:no:3.2.0"
    "NODEVER:version:no:20.10.0"
    "GOVER:version:no:1.21.0"
    "PHPVER:version:no:8.2.0"
    "FLUTTER_CHANNEL:enum:no:stable:stable,beta,dev,master"
    "SKIP_UPDATE_CHECK:bool:no:false"
    "INSTALL_VSCODE:bool:no:true"
    "INSTALL_CURSOR:bool:no:false"
    "INSTALL_JETBRAINS:bool:no:false"
    "INSTALL_SUBLIME:bool:no:false"
    "INSTALL_ZED:bool:no:false"
    "ENTERPRISE_MODE:bool:no:false"
    "RESPECT_MDM_POLICIES:bool:no:true"
    "JAMF_RECON_ON_COMPLETE:bool:no:false"
    "BREWTAPS:array:no:"
    "BREWPACKAGES:array:no:"
    "BREWCASKS:array:no:"
    "APPSTORE:array:no:"
    "DIRS:array:no:"
    "DIRSTOEXCLUDEFROMTIMEMACHINE:array:no:"
    "GIT_REPOS:array:no:"
    "GIT_REPO_BASE_DIR:string:no:"
    "GLOBAL_NODE_PACKAGES:array:no:"
    "GLOBAL_PYTHON_PACKAGES:array:no:"
    "GLOBAL_PHP_PACKAGES:array:no:"
    "PEAR_PACKAGES:array:no:"
    "KILLAPPS:array:no:"
)

validate_config() {
    local config_file="$1"
    # shellcheck disable=SC2034  # verbose reserved for future use
    local verbose="${2:-false}"
    local errors=0
    local warnings=0

    # Check if file exists
    if [ ! -f "$config_file" ]; then
        echo "  ✗ Configuration file not found: $config_file"
        return 1
    fi

    # Source the config file in a subshell to avoid polluting namespace
    (
        # shellcheck disable=SC1090
        source "$config_file" 2>/dev/null
    ) || {
        echo "  ✗ Configuration file has syntax errors"
        return 1
    }

    # shellcheck disable=SC1090
    source "$config_file"

    # Validate ENABLED_MODULES array
    if [ ${#ENABLED_MODULES[@]} -eq 0 ]; then
        echo "  ✗ No modules enabled in configuration"
        errors=$((errors + 1))
    else
        # Validate each module name
        for module in "${ENABLED_MODULES[@]}"; do
            if ! is_valid_module "$module"; then
                echo "  ✗ Unknown module: $module"
                errors=$((errors + 1))
            fi
        done
    fi

    # Validate version numbers (only if set)
    validate_version_if_set "JDKVER" "${JDKVER:-}" || errors=$((errors + 1))
    validate_version_if_set "PYTHONVER" "${PYTHONVER:-}" || errors=$((errors + 1))
    validate_version_if_set "RUBYVER" "${RUBYVER:-}" || errors=$((errors + 1))
    validate_version_if_set "NODEVER" "${NODEVER:-}" || errors=$((errors + 1))
    validate_version_if_set "GOVER" "${GOVER:-}" || errors=$((errors + 1))
    validate_version_if_set "PHPVER" "${PHPVER:-}" || errors=$((errors + 1))

    # Validate boolean values (only if set)
    validate_boolean_if_set "SKIP_UPDATE_CHECK" "${SKIP_UPDATE_CHECK:-}" || errors=$((errors + 1))
    validate_boolean_if_set "INSTALL_VSCODE" "${INSTALL_VSCODE:-}" || errors=$((errors + 1))
    validate_boolean_if_set "INSTALL_CURSOR" "${INSTALL_CURSOR:-}" || errors=$((errors + 1))
    validate_boolean_if_set "INSTALL_JETBRAINS" "${INSTALL_JETBRAINS:-}" || errors=$((errors + 1))
    validate_boolean_if_set "INSTALL_SUBLIME" "${INSTALL_SUBLIME:-}" || errors=$((errors + 1))
    validate_boolean_if_set "INSTALL_ZED" "${INSTALL_ZED:-}" || errors=$((errors + 1))
    validate_boolean_if_set "ENTERPRISE_MODE" "${ENTERPRISE_MODE:-}" || errors=$((errors + 1))
    validate_boolean_if_set "RESPECT_MDM_POLICIES" "${RESPECT_MDM_POLICIES:-}" || errors=$((errors + 1))
    validate_boolean_if_set "JAMF_RECON_ON_COMPLETE" "${JAMF_RECON_ON_COMPLETE:-}" || errors=$((errors + 1))

    # Validate enum values
    if [ -n "${FLUTTER_CHANNEL:-}" ]; then
        case "$FLUTTER_CHANNEL" in
            stable|beta|dev|master) ;;
            *)
                echo "  ✗ Invalid FLUTTER_CHANNEL: $FLUTTER_CHANNEL (must be stable, beta, dev, or master)"
                errors=$((errors + 1))
                ;;
        esac
    fi

    # Validate arrays are actually arrays
    validate_array_if_set "BREWTAPS" || errors=$((errors + 1))
    validate_array_if_set "BREWPACKAGES" || errors=$((errors + 1))
    validate_array_if_set "BREWCASKS" || errors=$((errors + 1))
    validate_array_if_set "APPSTORE" || errors=$((errors + 1))
    validate_array_if_set "DIRS" || errors=$((errors + 1))
    validate_array_if_set "GIT_REPOS" || errors=$((errors + 1))

    # Check for deprecated or unknown variables (warnings only)
    if [ -n "${HOMEBREW_CASK_OPTS:-}" ]; then
        echo "  ⚠ HOMEBREW_CASK_OPTS is deprecated, use Homebrew environment variables instead"
        warnings=$((warnings + 1))
    fi

    # Return results
    if [ $errors -gt 0 ]; then
        echo ""
        echo "  Found $errors error(s), $warnings warning(s)"
        return 1
    elif [ $warnings -gt 0 ]; then
        echo "  ⚠ Found $warnings warning(s)"
        return 0
    else
        echo "  ✓ Configuration valid"
        return 0
    fi
}

is_valid_module() {
    local module="$1"
    for valid in "${VALID_MODULES[@]}"; do
        if [ "$module" = "$valid" ]; then
            return 0
        fi
    done
    return 1
}

# Returns 1 if validation error, 0 otherwise
validate_version_if_set() {
    local name="$1"
    local version="$2"

    # Skip if not set
    [ -z "$version" ] && return 0

    if ! [[ "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        echo "  ✗ Invalid $name version: $version (expected format: X.Y.Z)"
        return 1
    fi
    return 0
}

# Returns 1 if validation error, 0 otherwise
validate_boolean_if_set() {
    local name="$1"
    local value="$2"

    # Skip if not set
    [ -z "$value" ] && return 0

    if [ "$value" != "true" ] && [ "$value" != "false" ]; then
        echo "  ✗ Invalid $name value: $value (should be true or false)"
        return 1
    fi
    return 0
}

# Returns 1 if validation error, 0 otherwise
validate_array_if_set() {
    local name="$1"

    # Check if variable is declared
    if ! declare -p "$name" &>/dev/null; then
        return 0
    fi

    # Check if it's an array
    local decl
    decl=$(declare -p "$name" 2>/dev/null)
    if [[ ! "$decl" =~ "declare -a" ]]; then
        echo "  ✗ $name should be an array, not a scalar"
        return 1
    fi
    return 0
}

# Legacy functions for backward compatibility
validate_version() {
    local name="$1"
    local version="$2"
    if [ -z "$version" ] || ! [[ "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        echo "  ✗ Invalid $name version: $version"
        return 1
    fi
    return 0
}

validate_boolean() {
    local name="$1"
    local value="$2"
    if [ -z "$value" ] || { [ "$value" != "true" ] && [ "$value" != "false" ]; }; then
        echo "  ✗ Invalid $name value: $value (should be true or false)"
        return 1
    fi
    return 0
}
