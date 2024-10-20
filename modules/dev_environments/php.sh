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

# PHP Development Environment Module

log_info "Setting up PHP environment..."

# Install PHP using Homebrew if not installed
if ! command -v php &> /dev/null; then
    log_info "PHP not found. Installing PHP..."
    brew install php
    log_success "PHP installed"
else
    log_success "PHP is already installed."
    php -v | tee -a "$LOGFILE"
fi

# Install Composer
if ! command -v composer &> /dev/null; then
    log_info "Composer not found. Installing Composer..."
    EXPECTED_CHECKSUM="$(curl -s https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
        php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
        rm composer-setup.php
        log_success "Composer installed"
    else
        log_error "Composer installer checksum mismatch"
        rm composer-setup.php
    fi
else
    log_success "Composer is already installed."
    composer --version | tee -a "$LOGFILE"
fi

# Install global PHP tools using Composer
log_info "Installing global PHP tools..."
composer global require "$GLOBAL_PHP_PACKAGES" | tee -a "$LOGFILE"
log_success "Installed global PHP packages"

log_success "PHP environment setup complete"
