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

# Node.js Development Environment Module

log_info "Setting up Node.js environment..."

# Check if nodenv is installed; if not, install it
if ! command -v nodenv &> /dev/null; then
    log_info "nodenv not found. Installing nodenv..."
    brew install nodenv
fi

export PATH="$HOME/.nodenv/bin:$PATH"
export PATH="$HOME/.nodenv/shims:$PATH"
eval "$(nodenv init -)"

NODE_MAJOR_ALIAS=""

# Resolve major-only versions (e.g., "24") to latest available patch.
resolve_node_version() {
    if [[ "$NODEVER" =~ ^[0-9]+$ ]]; then
        local major="$NODEVER"
        local resolved=""
        NODE_MAJOR_ALIAS="$major"
        resolved=$(nodenv install -l 2>/dev/null | tr -d ' ' | grep -E "^${major}\\.[0-9]+\\.[0-9]+$" | tail -n 1)
        if [[ -z "$resolved" ]]; then
            log_warning "Node.js [$major] not found in node-build list. Updating node-build..."
            brew upgrade node-build >/dev/null 2>&1 || true
            resolved=$(nodenv install -l 2>/dev/null | tr -d ' ' | grep -E "^${major}\\.[0-9]+\\.[0-9]+$" | tail -n 1)
        fi
        if [[ -n "$resolved" ]]; then
            log_info "Resolved Node.js [$major] -> [$resolved]"
            NODEVER="$resolved"
        else
            log_warning "Could not resolve Node.js major [$major]. Will try as-is."
        fi
    fi
}

ensure_node_major_alias() {
    local major="$NODE_MAJOR_ALIAS"
    local version="$NODEVER"
    local nodenv_root version_path alias_path

    [[ -n "$major" ]] || return 0
    [[ "$version" =~ ^${major}\.[0-9]+\.[0-9]+$ ]] || return 0

    nodenv_root="$(nodenv root)"
    version_path="$nodenv_root/versions/$version"
    alias_path="$nodenv_root/versions/$major"

    if [[ ! -d "$version_path" ]]; then
        log_warning "Cannot create nodenv major alias [$major]; Node.js [$version] is not installed."
        return 0
    fi

    if [[ -e "$alias_path" && ! -L "$alias_path" ]]; then
        log_warning "Cannot create nodenv major alias [$major]; [$alias_path] exists and is not a symlink."
        return 0
    fi

    ln -sfn "$version" "$alias_path"
    log_info "Linked nodenv major alias [$major] -> [$version]"
}

install_node_version() {
    local version="$1"
    set +e
    nodenv install "$version" 2>&1 | tee -a "$LOGFILE"
    local rc=${PIPESTATUS[0]}
    set -e
    return "$rc"
}

resolve_node_version

# Check if desired Node.js version is installed
CURRENTVER=$(get_current_version nodenv)
INSTALLED=false

while read -r version; do
    if [[ "$version" == "$NODEVER" ]]; then
        INSTALLED=true
        break
    fi
done <<< "$(nodenv versions --bare)"

if [ "$INSTALLED" = true ]; then
    log_success "Node.js [$NODEVER] is already installed."
    log_info "Skipping installation of Node.js."
    ensure_node_major_alias
    node --version | tee -a "$LOGFILE"
    which node | tee -a "$LOGFILE"
else
    log_warning "Node.js [$NODEVER] is not installed. Found [$CURRENTVER]."
    log_info "Installing Node.js..."
    if ! install_node_version "$NODEVER"; then
        log_error "Failed to install Node.js [$NODEVER]."
        log_error "Try: brew upgrade node-build"
        exit 1
    fi

    ensure_node_major_alias

    # Set NODEVER as the local and global Node.js version
    nodenv global "$NODEVER"
    nodenv local "$NODEVER"

    # If there are other versions installed, set the highest one as the global version
    HIGHESTVER=$(get_highest_version nodenv)
    if [ "$HIGHESTVER" != "$NODEVER" ]; then
        nodenv global "$HIGHESTVER"
        log_info "Set highest Node.js version [$HIGHESTVER] as global version."
    fi

    # Show the active Node.js version
    node --version | tee -a "$LOGFILE"

    log_success "Node.js environment setup complete"
fi

if [ "${#GLOBAL_NODE_PACKAGES[@]}" -gt 0 ]; then
    log_info "Installing global Node.js packages..."
    npm i -g "${GLOBAL_NODE_PACKAGES[@]}" | tee -a "$LOGFILE"
    log_success "Installed global Node.js packages"

    log_info "Rehashing nodenv shims..."
    nodenv rehash

    log_info "Verifying npm and yarn paths..."
    nodenv which npm
    nodenv which yarn
fi

# Ensure npm matches desired version when specified
if [[ -n "${NPMVER:-}" ]]; then
    CURRENT_NPM="$(npm -v 2>/dev/null || true)"
    if [[ "$CURRENT_NPM" != "$NPMVER" ]]; then
        log_warning "npm [$NPMVER] is not installed. Found [$CURRENT_NPM]."
        npm i -g "npm@${NPMVER}" | tee -a "$LOGFILE"
        npm -v | tee -a "$LOGFILE"
        log_success "Updated npm to [$NPMVER]"
    else
        log_success "npm [$NPMVER] is already installed."
    fi
    npm config set fund false --global | tee -a "$LOGFILE"
fi
