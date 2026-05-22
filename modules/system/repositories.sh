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

# Repository bootstrap module

log_info "Setting up Git repositories..."

REPO_BASE_DIR="${GIT_REPO_BASE_DIR:-$HOME/GIT/_Perso}"

expand_path() {
    local value="$1"

    if [[ "$value" == \~ ]]; then
        printf "%s\n" "$HOME"
    elif [[ "$value" == \~/* ]]; then
        printf "%s/%s\n" "$HOME" "${value#~/}"
    else
        printf "%s\n" "$value"
    fi
}

repo_slug() {
    local repo="$1"
    repo="${repo%.git}"
    printf "%s\n" "${repo##*/}"
}

repo_url_for() {
    local repo="$1"

    if [[ "$repo" == http://* || "$repo" == https://* || "$repo" == git@* || "$repo" == ssh://* ]]; then
        printf "%s\n" "$repo"
    else
        printf "https://github.com/%s.git\n" "$repo"
    fi
}

clone_repo() {
    local entry="$1"
    local repo="${entry%%:*}"
    local dest="${entry#*:}"
    local base_dir dest_path origin expected_url parent

    if [[ -z "$repo" ]]; then
        log_warning "Skipping empty repository entry"
        return 0
    fi

    if [[ "$dest" == "$entry" || -z "$dest" ]]; then
        dest="$(repo_slug "$repo")"
    fi

    base_dir="$(expand_path "$REPO_BASE_DIR")"
    if [[ "$dest" == /* || "$dest" == \~/* || "$dest" == \~ ]]; then
        dest_path="$(expand_path "$dest")"
    else
        dest_path="$base_dir/$dest"
    fi

    expected_url="$(repo_url_for "$repo")"

    if [[ -d "$dest_path/.git" ]]; then
        origin="$(git -C "$dest_path" remote get-url origin 2>/dev/null || true)"
        if [[ -n "$origin" && "$origin" != "$expected_url" ]]; then
            log_warning "Repository [$dest_path] exists with origin [$origin], expected [$expected_url]"
        else
            log_info "Repository already exists: [$dest_path]"
        fi
        return 0
    fi

    if [[ -e "$dest_path" ]] && find "$dest_path" -mindepth 1 -maxdepth 1 2>/dev/null | read -r _; then
        log_warning "Destination exists and is not an empty git repo: [$dest_path]"
        return 0
    fi

    parent="$(dirname "$dest_path")"
    mkdir -p "$parent"

    log_info "Cloning [$repo] -> [$dest_path]"
    if command -v ghx >/dev/null 2>&1 && [[ "$repo" != http://* && "$repo" != https://* && "$repo" != git@* && "$repo" != ssh://* ]]; then
        ghx repo clone "$repo" "$dest_path"
    else
        git clone "$expected_url" "$dest_path"
    fi
    log_success "Cloned repository: [$dest_path]"
}

if [[ "${#GIT_REPOS[@]}" -eq 0 ]]; then
    log_info "No Git repositories configured."
else
    for repo_entry in "${GIT_REPOS[@]}"; do
        clone_repo "$repo_entry"
    done
fi
