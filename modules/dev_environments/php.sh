#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment
# https://github.com/vincentkoc/natilius

# PHP Development Environment Module

log_info "Setting up PHP environment..."

# Tap shivammathur/php for installing multiple PHP versions
brew tap shivammathur/php

# Install the specified PHP version
log_info "Installing PHP version $PHPVER..."
brew install shivammathur/php/php@"$PHPVER"

# Unlink other PHP versions and link the desired version
log_info "Linking PHP version $PHPVER..."
brew unlink php 2>/dev/null || true
brew link --force --overwrite php@"$PHPVER"

# Verify the installed PHP version
php -v | tee -a "$LOGFILE"

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

# Install default PEAR packages
log_info "Installing default PEAR packages..."
pear config-set auto_discover 1
for package in "${PEAR_PACKAGES[@]}"; do
    pear install -f "$package" | tee -a "$LOGFILE" || true
    log_success "Installed PEAR package: $package"
done

# Install global PHP tools using Composer
log_info "Installing global PHP Composer packages..."
composer global require "${GLOBAL_PHP_PACKAGES[@]}" | tee -a "$LOGFILE"
log_success "Installed global PHP Composer packages"

log_success "PHP environment setup complete"
