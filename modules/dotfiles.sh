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

# Dotfiles Module

log_info "Setting up dotfiles..."

# Install Mackup if not installed
if ! command -v mackup &> /dev/null; then
    brew install mackup
fi

# Copy Mackup config if not present
if [ ! -f "$HOME/.mackup.cfg" ]; then
    cat << EOF > "$HOME/.mackup.cfg"
[storage]
engine = icloud
directory = dotfiles
EOF
    log_success "Created .mackup.cfg"
fi

# Restore dotfiles (guarded)
SHOULD_RESTORE=false

if [[ "${NATILIUS_DOTFILES_SKIP_RESTORE:-false}" == "true" ]]; then
    log_info "Skipping dotfiles restore because NATILIUS_DOTFILES_SKIP_RESTORE is true"
else
    if [[ "${NATILIUS_FORCE_DOTFILES_RESTORE:-false}" == "true" ]]; then
        SHOULD_RESTORE=true
    elif [[ "${INTERACTIVE_MODE:-false}" == true ]]; then
        read -r -p "Restore dotfiles from Mackup now? [y/N]: " _dotfiles_restore_answer
        if [[ "$_dotfiles_restore_answer" =~ ^[Yy]$ ]]; then
            SHOULD_RESTORE=true
        else
            log_warning "User declined Mackup restore; local dotfiles remain untouched"
        fi
        unset _dotfiles_restore_answer
    else
        log_warning "Skipping Mackup restore (set NATILIUS_FORCE_DOTFILES_RESTORE=true to enable in non-interactive mode)"
    fi
fi

if [[ "$SHOULD_RESTORE" == true ]]; then
    mackup restore -f
    log_success "Dotfiles restored with Mackup"
else
    log_info "Dotfiles restore not run"
fi
