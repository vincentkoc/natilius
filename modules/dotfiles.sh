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

# Ensure Homebrew is on PATH for this session (needed when running module alone).
ensure_brew_path() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi

    local brew_path=""
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        brew_path="/opt/homebrew/bin/brew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        brew_path="/usr/local/bin/brew"
    fi

    if [[ -n "$brew_path" ]]; then
        eval "$("$brew_path" shellenv)"
        if [[ -f "$HOME/.zprofile" ]]; then
            if ! grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
                echo "" >> "$HOME/.zprofile"
                echo "# Homebrew" >> "$HOME/.zprofile"
                echo "eval \"\$($brew_path shellenv)\"" >> "$HOME/.zprofile"
            fi
        else
            echo "# Homebrew" > "$HOME/.zprofile"
            echo "eval \"\$($brew_path shellenv)\"" >> "$HOME/.zprofile"
        fi
        return 0
    fi

    return 1
}

# Optional dotfiles repo/bootstrap
DOTFILES_DIR="${NATILIUS_DOTFILES_DIR:-$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles}"
DOTFILES_REPO="${NATILIUS_DOTFILES_REPO:-https://github.com/vincentkoc/dotfiles}"
DOTFILES_POST_PULL_CMD="${NATILIUS_DOTFILES_POST_PULL_CMD:-}"

# If a dotfiles repo is configured, clone it only when the location is empty.
if [[ -n "$DOTFILES_REPO" ]]; then
    if [[ -d "$DOTFILES_DIR" ]] && find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | read -r _; then
        log_info "Dotfiles location not empty [$DOTFILES_DIR]. Skipping repo clone."
    else
        log_info "Dotfiles location empty. Cloning repo [$DOTFILES_REPO] -> [$DOTFILES_DIR]..."
        rm -rf "$DOTFILES_DIR"
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        log_success "Dotfiles repo cloned"
    fi

    if [[ -n "$DOTFILES_POST_PULL_CMD" ]]; then
        log_info "Running dotfiles post-pull command..."
        (cd "$DOTFILES_DIR" && /bin/bash -c "$DOTFILES_POST_PULL_CMD")
        log_success "Dotfiles post-pull command finished"
    fi
fi

# Install Mackup if not installed
if ! command -v mackup &> /dev/null; then
    if ! ensure_brew_path; then
        log_error "Homebrew not found in PATH and could not be detected. Install Homebrew first."
        return 1
    fi
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
