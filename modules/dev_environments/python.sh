#!/bin/bash

# Python Development Environment Module

log_info "Setting up Python environment..."

# Install pyenv if not installed
if ! command -v pyenv &> /dev/null; then
    brew install pyenv
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# Install Python version
pyenv install -s "$PYTHONVER"
pyenv global "$PYTHONVER"
log_success "Set global Python version to $PYTHONVER"

# Upgrade pip and install packages
pip install --upgrade pip
pip install virtualenv

log_success "Python environment setup complete"
