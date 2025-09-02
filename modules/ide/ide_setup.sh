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

# IDE Setup Module

log_info "Setting up IDEs..."

# Get enabled development environments
readarray -t ENABLED_DEV_ENVS < <(get_enabled_dev_environments)

# Source individual IDE setup scripts
source "$NATILIUS_DIR/modules/ide/vscode_setup.sh"
source "$NATILIUS_DIR/modules/ide/jetbrains_setup.sh"
source "$NATILIUS_DIR/modules/ide/sublime_setup.sh"
source "$NATILIUS_DIR/modules/ide/zed_setup.sh"

# Setup VSCode/Cursor
if [ "$INSTALL_VSCODE" = true ] || [ "$INSTALL_CURSOR" = true ]; then
    setup_vscode
fi

# Setup JetBrains IDEs
if [ "$INSTALL_JETBRAINS" = true ]; then
    setup_jetbrains_ides
fi

# Setup Sublime Text
if [ "$INSTALL_SUBLIME" = true ]; then
    setup_sublime_text
fi

# Setup Zed
if [ "$INSTALL_ZED" = true ]; then
    setup_zed
fi

log_success "IDE setup completed"
