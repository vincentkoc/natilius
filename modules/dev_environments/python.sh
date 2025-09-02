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

# Python Development Environment Module

log_info "Setting up Python environment..."

# Check if pyenv is installed; if not, install it
if ! command -v pyenv &> /dev/null; then
    log_info "pyenv not found. Installing pyenv..."
    brew install pyenv

    # Initialize pyenv
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

    # Install pyenv-virtualenv
    log_info "Installing pyenv-virtualenv..."
    brew install pyenv-virtualenv
    eval "$(pyenv virtualenv-init -)"
else
    # Initialize pyenv
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Check if desired Python version is installed
CURRENTVER=$(get_current_version pyenv)
INSTALLED=false

while read -r version; do
    if [[ "$version" == "$PYTHONVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(pyenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    log_success "Python [$PYTHONVER] is already installed."
    log_info "Skipping installation of Python."
    python --version | tee -a "$LOGFILE"
    which python | tee -a "$LOGFILE"
else
    log_warning "Python [$PYTHONVER] is not installed. Found [$CURRENTVER]."
    log_info "Installing Python..."
    pyenv install "$PYTHONVER" | tee -a "$LOGFILE"

    # Set PYTHONVER as the local and global Python version
    pyenv global "$PYTHONVER"
    pyenv local "$PYTHONVER"

    # Show the active Python version
    python --version | tee -a "$LOGFILE"

    # Upgrade pip and install global Python packages
    log_info "Upgrading pip and installing global Python packages..."
    pip install --upgrade pip
    pip install "${GLOBAL_PYTHON_PACKAGES[@]}" | tee -a "$LOGFILE"
    log_success "Installed global Python packages"

    log_success "Python environment setup complete"
fi
