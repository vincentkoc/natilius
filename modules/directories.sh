#!/bin/bash

# Directories Module

log_info "Setting up custom directories..."

# Create Directories
for dir in "${DIRS[@]}"; do
    dir_expanded=$(eval echo "$dir")
    if [ ! -d "$dir_expanded" ]; then
        mkdir -p "$dir_expanded" && log_success "Created directory: [$dir_expanded]"
    else
        log_info "Directory already exists: [$dir_expanded]"
    fi
done

# Add Time Machine Exclusions
log_info "Adding custom exclusions to Time Machine..."
for exclude_dir in "${DIRSTOEXCLUDEFROMTIMEMACHINE[@]}"; do
    exclude_dir_expanded=$(eval echo "$exclude_dir")
    sudo tmutil addexclusion "$exclude_dir_expanded" 2>/dev/null || true
    log_success "Added Time Machine exclusion for: [$exclude_dir_expanded]"
done
