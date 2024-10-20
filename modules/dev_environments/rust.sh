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

# Rust Development Environment Module

log_info "Setting up Rust environment..."

# Install rustup if not installed
if ! command -v rustup &> /dev/null; then
    brew install rustup-init
    rustup-init -y
fi

export PATH="$HOME/.cargo/bin:$PATH"

# Update Rust and install components
rustup update
rustup component add rustfmt
rustup component add clippy

log_success "Rust environment setup complete"
