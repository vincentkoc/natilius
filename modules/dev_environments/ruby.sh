#!/bin/bash

# Ruby Development Environment Module

log_info "Setting up Ruby environment..."

# Install rbenv if not installed
if ! command -v rbenv &> /dev/null; then
    brew install rbenv
fi

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby version
rbenv install -s "$RUBYVER"
rbenv global "$RUBYVER"
log_success "Set global Ruby version to $RUBYVER"

# Update RubyGems and install Bundler
gem update --system
gem install bundler

log_success "Ruby environment setup complete"
