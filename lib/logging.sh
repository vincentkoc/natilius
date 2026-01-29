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

# Logging Functions

# Color definitions for consistent styling
LOG_CYAN='\033[1;36m'
LOG_GREEN='\033[1;32m'
LOG_YELLOW='\033[1;33m'
LOG_RED='\033[1;31m'
LOG_DIM='\033[2m'
LOG_RESET='\033[0m'

# Export for use in subshells
export LOG_DIM LOG_RESET

get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

log_info() {
    echo -e "  ${LOG_CYAN}→${LOG_RESET} $1" | tee -a "$LOGFILE"
}

log_success() {
    echo -e "  ${LOG_GREEN}✓${LOG_RESET} $1" | tee -a "$LOGFILE"
}

log_warning() {
    echo -e "  ${LOG_YELLOW}⚠${LOG_RESET} $1" | tee -a "$LOGFILE"
}

log_error() {
    echo -e "  ${LOG_RED}✗${LOG_RESET} $1" | tee -a "$LOGFILE"
}
