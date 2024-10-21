#!/bin/bash

source "$(dirname "$0")/../lib/config_validator.sh"
source "$(dirname "$0")/../lib/logging.sh"

# Mock logging functions
log_error() { echo "ERROR: $1"; }
log_success() { echo "SUCCESS: $1"; }

# Test valid configuration
echo "Testing valid configuration..."
cat > test_config.rc << EOL
ENABLED_MODULES=("system/system_update" "applications/homebrew")
JDKVER="20"
PYTHONVER="3.9.11"
RUBYVER="3.2.1"
NODEVER="18.14.0"
GOVER="1.20.0"
SKIP_UPDATE_CHECK=false
INSTALL_VSCODE=true
INSTALL_CURSOR=false
INSTALL_JETBRAINS=true
INSTALL_SUBLIME=false
INSTALL_ZED=false
EOL

if validate_config "test_config.rc"; then
    echo "Valid configuration test passed."
else
    echo "Valid configuration test failed."
    exit 1
fi

# Test invalid configuration
echo "Testing invalid configuration..."
cat > test_config.rc << EOL
ENABLED_MODULES=()
JDKVER="invalid"
PYTHONVER="3.x"
RUBYVER="latest"
NODEVER="18"
GOVER="1.x"
SKIP_UPDATE_CHECK=maybe
INSTALL_VSCODE=yes
INSTALL_CURSOR=0
INSTALL_JETBRAINS=1
INSTALL_SUBLIME=no
INSTALL_ZED=TRUE
EOL

if ! validate_config "test_config.rc"; then
    echo "Invalid configuration test passed."
else
    echo "Invalid configuration test failed."
    exit 1
fi

rm test_config.rc
echo "All config validation tests passed."
