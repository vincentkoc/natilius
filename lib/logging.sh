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

log_info() {
    echo -e "\033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}

log_success() {
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}

log_warning() {
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}

log_error() {
    echo -e "\033[0;31m[ ✗ ]\033[0m \033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}
