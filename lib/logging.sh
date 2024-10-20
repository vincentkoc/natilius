#!/bin/bash

# Logging Functions

log_info() {
    echo -e "\033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}

log_success() {
    echo -e "\033[0;32m[ ✓ ]\033[0m \033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}

log_warning() {
    echo -e "\033[0;33m[ ! ]\033[0m \033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}

log_error() {
    echo -e "\033[0;31m[ ✗ ]\033[0m \033[0;36m$1\033[0m" | tee -a "$LOGFILE"
}
