#!/bin/bash

source "$(dirname "$0")/../lib/config_validator.sh"
source "$(dirname "$0")/../lib/logging.sh"

# Mock logging functions
log_error() { echo "ERROR: $1"; }
log_success() { echo "SUCCESS: $1"; }

tmp_config="$(mktemp)"
cleanup() { rm -f "$tmp_config"; }
trap cleanup EXIT

# Test valid configuration
echo "Testing valid configuration..."
cat > "$tmp_config" << EOL
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

output="$(validate_config "$tmp_config" 2>&1)"
status=$?
if [ "$status" -ne 0 ] || echo "$output" | grep -q "ERROR:"; then
    echo "$output"
    echo "Valid configuration test failed."
    exit 1
fi
echo "Valid configuration test passed."

# Test all repo .natiliusrc* configs
echo "Testing .natiliusrc* configs..."
config_dir="$(dirname "$0")/.."
shopt -s nullglob
configs=("$config_dir"/.natiliusrc*)
shopt -u nullglob
if [ "${#configs[@]}" -eq 0 ]; then
    echo "No .natiliusrc* configs found. Skipping."
else
    for cfg in "${configs[@]}"; do
        echo "Testing $(basename "$cfg")..."
        output="$(validate_config "$cfg" 2>&1)"
        status=$?
        if [ "$status" -ne 0 ] || echo "$output" | grep -q "ERROR:"; then
            echo "$output"
            echo "Configuration test failed for $(basename "$cfg")."
            exit 1
        fi
        echo "Configuration test passed for $(basename "$cfg")."
    done
fi

echo "All config validation tests passed."
