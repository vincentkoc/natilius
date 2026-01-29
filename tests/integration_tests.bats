#!/usr/bin/env bats

@test "Natilius exits immediately in dry-run mode" {
    run ./natilius.sh setup --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Dry-run Mode"* ]]
}

@test "Natilius shows modules in dry-run mode" {
    run ./natilius.sh setup --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Modules"* ]]
}

@test "Natilius shows configuration loaded message" {
    run ./natilius.sh setup --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Configuration"* ]] || [[ "$output" == *"Modules"* ]]
}

# Integration tests for new features

@test "Config validator can validate example config" {
    source lib/config_validator.sh 2>/dev/null
    source lib/logging.sh 2>/dev/null
    export LOGFILE="/dev/null"
    run validate_config .natiliusrc.example
    # Example config should be valid
    [ "$status" -eq 0 ]
}

@test "Help command completes quickly (under 1 second)" {
    local start end duration
    start=$(date +%s%N)
    run ./natilius.sh --help
    end=$(date +%s%N)
    duration=$(( (end - start) / 1000000 ))  # Convert to milliseconds
    [ "$status" -eq 0 ]
    [ "$duration" -lt 1000 ]  # Less than 1 second
}

@test "Version command completes quickly (under 1 second)" {
    local start end duration
    start=$(date +%s%N)
    run ./natilius.sh --version
    end=$(date +%s%N)
    duration=$(( (end - start) / 1000000 ))
    [ "$status" -eq 0 ]
    [ "$duration" -lt 1000 ]
}

@test "Dry run mode does not modify any files" {
    # Create a temp directory to track modifications
    local before_sum after_sum
    before_sum=$(find ~/.natiliusrc* -type f 2>/dev/null | xargs md5 2>/dev/null || echo "none")
    run ./natilius.sh setup --check
    [ "$status" -eq 0 ]
    after_sum=$(find ~/.natiliusrc* -type f 2>/dev/null | xargs md5 2>/dev/null || echo "none")
    [ "$before_sum" = "$after_sum" ]
}

@test "All library files can be sourced without errors" {
    export LOGFILE="/dev/null"
    export NATILIUS_DIR="$(pwd)"
    run bash -c 'source lib/utils.sh && source lib/logging.sh && source lib/network_utils.sh && source lib/config_validator.sh && echo "success"'
    [ "$status" -eq 0 ]
    [[ "$output" == *"success"* ]]
}

@test "MDM utils library can be sourced" {
    export LOGFILE="/dev/null"
    run bash -c 'source lib/mdm_utils.sh && echo "success"'
    [ "$status" -eq 0 ]
    [[ "$output" == *"success"* ]]
}

@test "Natilius handles SKIP_SUDO environment variable" {
    run env SKIP_SUDO=true ./natilius.sh setup --check
    [ "$status" -eq 0 ]
}

@test "Natilius handles profile flag with built-in profile" {
    # Test with a profile from the profiles directory if it exists
    if [ -f "profiles/minimal.natiliusrc" ]; then
        run ./natilius.sh --profile minimal setup --check
        [ "$status" -eq 0 ]
    else
        skip "No minimal profile found"
    fi
}

@test "Shell script syntax is valid for main script" {
    run bash -n natilius.sh
    [ "$status" -eq 0 ]
}

@test "Shell script syntax is valid for all library files" {
    run bash -c 'for f in lib/*.sh; do bash -n "$f" || exit 1; done; echo ok'
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}

@test "Shell script syntax is valid for all module files" {
    run bash -c 'for f in modules/**/*.sh modules/*.sh; do [ -f "$f" ] && bash -n "$f" || exit 1; done 2>/dev/null; echo ok'
    [ "$status" -eq 0 ]
}
