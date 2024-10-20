#!/bin/bash

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
