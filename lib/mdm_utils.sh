#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment
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

# MDM Utility Functions
# Supports: Jamf Pro, JumpCloud, Kandji, Mosyle, Microsoft Intune, and generic MDM

#=============================================================================
# Generic MDM Functions
#=============================================================================

# Check if device is MDM enrolled
is_mdm_enrolled() {
    if profiles status -type enrollment 2>/dev/null | grep -q "MDM enrollment: Yes"; then
        return 0
    fi
    if profiles list 2>/dev/null | grep -q "com.apple"; then
        return 0
    fi
    return 1
}

# Check if enrolled via DEP/ABM (Device Enrollment Program / Apple Business Manager)
is_dep_enrolled() {
    if profiles status -type enrollment 2>/dev/null | grep -q "Enrolled via DEP: Yes"; then
        return 0
    fi
    return 1
}

# Get MDM server URL
get_mdm_server_url() {
    profiles status -type enrollment 2>/dev/null | grep -i "MDM server:" | awk -F': ' '{print $2}'
}

# Detect which MDM provider is in use
# Returns: jamf, jumpcloud, kandji, mosyle, intune, workspace_one, other, none
get_mdm_provider() {
    local mdm_url
    mdm_url=$(get_mdm_server_url)

    if [ -z "$mdm_url" ] && ! is_mdm_enrolled; then
        echo "none"
        return
    fi

    # Check by MDM server URL
    case "$mdm_url" in
        *jamf*|*JAMF*)
            echo "jamf"
            return
            ;;
        *jumpcloud*|*JUMPCLOUD*)
            echo "jumpcloud"
            return
            ;;
        *kandji*|*KANDJI*)
            echo "kandji"
            return
            ;;
        *mosyle*|*MOSYLE*)
            echo "mosyle"
            return
            ;;
        *microsoft*|*intune*|*INTUNE*)
            echo "intune"
            return
            ;;
        *airwatch*|*workspace*|*WORKSPACE*)
            echo "workspace_one"
            return
            ;;
    esac

    # Check by installed agents/apps
    if [ -f "/usr/local/jamf/bin/jamf" ] || [ -f "/usr/local/bin/jamf" ]; then
        echo "jamf"
        return
    fi

    if [ -f "/opt/jc/bin/jumpcloud-agent" ] || [ -d "/Library/JumpCloud" ]; then
        echo "jumpcloud"
        return
    fi

    if [ -d "/Library/Kandji" ] || pgrep -x "Kandji" >/dev/null 2>&1; then
        echo "kandji"
        return
    fi

    if [ -d "/Library/Application Support/Mosyle" ]; then
        echo "mosyle"
        return
    fi

    if [ -d "/Library/Intune" ] || [ -f "/usr/local/bin/intune" ]; then
        echo "intune"
        return
    fi

    if is_mdm_enrolled; then
        echo "other"
    else
        echo "none"
    fi
}

# Check if a specific configuration profile is installed
has_profile() {
    local profile_identifier="$1"
    profiles list 2>/dev/null | grep -q "$profile_identifier"
}

# Check if running in managed environment
is_managed_environment() {
    is_mdm_enrolled
}

# Warn if MDM managed and making system changes
warn_if_managed() {
    if is_managed_environment; then
        local provider
        provider=$(get_mdm_provider)
        log_warning "This device is managed by ${provider}. Some settings may be restricted."
        return 0
    fi
    return 1
}

#=============================================================================
# Jamf Pro Functions
#=============================================================================

# Check if device is enrolled in Jamf
is_jamf_enrolled() {
    [ "$(get_mdm_provider)" = "jamf" ]
}

# Get Jamf binary path
get_jamf_binary() {
    if [ -f "/usr/local/jamf/bin/jamf" ]; then
        echo "/usr/local/jamf/bin/jamf"
    elif [ -f "/usr/local/bin/jamf" ]; then
        echo "/usr/local/bin/jamf"
    else
        echo ""
    fi
}

# Get Jamf version
get_jamf_version() {
    local jamf_bin
    jamf_bin=$(get_jamf_binary)
    if [ -n "$jamf_bin" ]; then
        "$jamf_bin" version 2>/dev/null | head -n1
    else
        echo ""
    fi
}

# Check if Jamf Connect is installed
has_jamf_connect() {
    [ -d "/Applications/Jamf Connect.app" ]
}

# Check if Jamf Protect is installed/running
has_jamf_protect() {
    [ -d "/Applications/JamfProtect.app" ] || pgrep -x "JamfProtect" >/dev/null 2>&1
}

# Run Jamf policy
run_jamf_policy() {
    local trigger="$1"
    local jamf_bin
    jamf_bin=$(get_jamf_binary)

    if [ -z "$jamf_bin" ]; then
        log_warning "Jamf is not installed"
        return 1
    fi

    if [ -z "$trigger" ]; then
        log_error "No policy trigger specified"
        return 1
    fi

    log_info "Running Jamf policy: $trigger"
    sudo "$jamf_bin" policy -trigger "$trigger"
}

# Check Jamf connectivity
check_jamf_connectivity() {
    local jamf_bin
    jamf_bin=$(get_jamf_binary)

    if [ -z "$jamf_bin" ]; then
        return 1
    fi

    "$jamf_bin" checkJSSConnection -retry 1 >/dev/null 2>&1
}

# Recon - update Jamf inventory
jamf_recon() {
    local jamf_bin
    jamf_bin=$(get_jamf_binary)

    if [ -z "$jamf_bin" ]; then
        log_warning "Jamf is not installed"
        return 1
    fi

    log_info "Updating Jamf inventory..."
    sudo "$jamf_bin" recon
}

#=============================================================================
# JumpCloud Functions
#=============================================================================

# Check if device is enrolled in JumpCloud
is_jumpcloud_enrolled() {
    [ "$(get_mdm_provider)" = "jumpcloud" ]
}

# Get JumpCloud agent binary path
get_jumpcloud_binary() {
    if [ -f "/opt/jc/bin/jumpcloud-agent" ]; then
        echo "/opt/jc/bin/jumpcloud-agent"
    else
        echo ""
    fi
}

# Check JumpCloud agent status
check_jumpcloud_status() {
    if [ -f "/opt/jc/bin/jumpcloud-agent" ]; then
        /opt/jc/bin/jumpcloud-agent --status 2>/dev/null
        return $?
    fi
    return 1
}

# Get JumpCloud system key
get_jumpcloud_system_key() {
    if [ -f "/opt/jc/jcagent.conf" ]; then
        grep -o '"systemKey":"[^"]*"' /opt/jc/jcagent.conf 2>/dev/null | cut -d'"' -f4
    fi
}

#=============================================================================
# Kandji Functions
#=============================================================================

# Check if device is enrolled in Kandji
is_kandji_enrolled() {
    [ "$(get_mdm_provider)" = "kandji" ]
}

#=============================================================================
# Microsoft Intune Functions
#=============================================================================

# Check if device is enrolled in Intune
is_intune_enrolled() {
    [ "$(get_mdm_provider)" = "intune" ]
}

# Check if Company Portal is installed
has_company_portal() {
    [ -d "/Applications/Company Portal.app" ]
}

#=============================================================================
# Utility Functions
#=============================================================================

# Get MDM provider display name
get_mdm_provider_name() {
    local provider
    provider=$(get_mdm_provider)

    case "$provider" in
        jamf) echo "Jamf Pro" ;;
        jumpcloud) echo "JumpCloud" ;;
        kandji) echo "Kandji" ;;
        mosyle) echo "Mosyle" ;;
        intune) echo "Microsoft Intune" ;;
        workspace_one) echo "VMware Workspace ONE" ;;
        other) echo "MDM (Unknown Provider)" ;;
        none) echo "Not Enrolled" ;;
        *) echo "$provider" ;;
    esac
}
