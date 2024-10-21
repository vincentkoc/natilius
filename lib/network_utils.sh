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


# Maximum number of retries for network operations
MAX_RETRIES=3

# Delay between retries (in seconds)
RETRY_DELAY=5

# Perform a network operation with retries
#
# Arguments:
#   $@: The command to execute
#
# Returns: The exit status of the command
retry_network_operation() {
    local retries=0
    local command=("$@")

    while [ $retries -lt $MAX_RETRIES ]; do
        if "${command[@]}"; then
            return 0
        fi

        retries=$((retries + 1))
        log_warning "Network operation failed. Retrying in $RETRY_DELAY seconds (Attempt $retries of $MAX_RETRIES)..."
        sleep $RETRY_DELAY
    done

    log_error "Network operation failed after $MAX_RETRIES attempts"
    return 1
}

# Check internet connectivity
#
# Returns: 0 if connected, 1 if not connected
check_internet_connection() {
    if ping -c 1 google.com &> /dev/null; then
        return 0
    else
        return 1
    fi
}
