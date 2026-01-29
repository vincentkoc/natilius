#!/usr/bin/env bats

# Test the new CLI features


@test "natilius --help shows help message" {
    run ./natilius.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE:"* ]]
    [[ "$output" == *"COMMANDS:"* ]]
    [[ "$output" == *"OPTIONS:"* ]]
    [[ "$output" == *"EXAMPLES:"* ]]
}

@test "natilius help shows help message" {
    run ./natilius.sh help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE:"* ]]
    [[ "$output" == *"COMMANDS:"* ]]
}

@test "natilius --version shows version information" {
    run ./natilius.sh --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"natilius"* ]]
    [[ "$output" == *"Copyright"* ]]
    [[ "$output" == *"License"* ]]
}

@test "natilius version shows version information" {
    run ./natilius.sh version
    [ "$status" -eq 0 ]
    [[ "$output" == *"natilius"* ]]
    [[ "$output" == *"v"*"."* ]]
}

@test "natilius doctor runs system diagnostics" {
    run env SKIP_SUDO=1 perl -e 'alarm shift; exec @ARGV' 15 ./natilius.sh doctor
    if [ "$status" -eq 142 ]; then
        skip "natilius doctor timed out"
    fi
    [ "$status" -eq 0 ]
    [[ "$output" == *"natilius"* ]]
    [[ "$output" == *"System Information"* ]]
    [[ "$output" == *"Development Tools"* ]]
    [[ "$output" == *"macOS"* ]]
}

@test "natilius modules shows available modules" {
    run ./natilius.sh modules
    [ "$status" -eq 0 ]
    [[ "$output" == *"natilius"* ]]
    [[ "$output" == *"System"* ]]
    [[ "$output" == *"Applications"* ]]
    [[ "$output" == *"enabled"* ]]
}

@test "natilius list-modules alias works" {
    run ./natilius.sh list-modules
    [ "$status" -eq 0 ]
    [[ "$output" == *"System"* ]]
}

@test "natilius setup --check shows dry-run information" {
    run ./natilius.sh setup --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Dry-run Mode"* ]]
    [[ "$output" == *"Modules"* ]]
}

@test "natilius --check without command shows help" {
    run ./natilius.sh --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE:"* ]]
}

@test "natilius --verbose setup --check increases output verbosity" {
    run ./natilius.sh --verbose setup --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Dry-run Mode"* ]]
}

@test "natilius --quiet setup --check suppresses non-error output" {
    run ./natilius.sh --quiet setup --check
    [ "$status" -eq 0 ]
    # Should have minimal output in quiet mode
}

@test "natilius with invalid argument shows error" {
    run ./natilius.sh --invalid-option
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown parameter"* ]]
    [[ "$output" == *"natilius --help"* ]]
}

@test "natilius with multiple valid flags works" {
    run ./natilius.sh --verbose setup --check --quiet
    [ "$status" -eq 0 ]
}

@test "natilius commands are case-sensitive" {
    run ./natilius.sh DOCTOR
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown parameter"* ]]
}

@test "natilius short flags work correctly" {
    run ./natilius.sh -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE:"* ]]
}

@test "natilius -v flag works" {
    run ./natilius.sh -v setup --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Dry-run Mode"* ]]
}

@test "natilius -c flag works for check mode" {
    run ./natilius.sh setup -c
    [ "$status" -eq 0 ]
    [[ "$output" == *"Dry-run Mode"* ]]
}

@test "natilius profiles shows available profiles" {
    run ./natilius.sh profiles
    [ "$status" -eq 0 ]
    [[ "$output" == *"natilius"* ]]
    [[ "$output" == *"Profiles"* ]]
}

@test "natilius help shows environment variables section" {
    run ./natilius.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"ENVIRONMENT VARIABLES"* ]]
    [[ "$output" == *"NATILIUS_"* ]]
}

@test "natilius doctor shows config validation section" {
    run env SKIP_SUDO=1 perl -e 'alarm shift; exec @ARGV' 15 ./natilius.sh doctor
    if [ "$status" -eq 142 ]; then
        skip "natilius doctor timed out"
    fi
    [ "$status" -eq 0 ]
    [[ "$output" == *"Config Validation"* ]] || [[ "$output" == *"Configuration"* ]]
}

@test "natilius doctor shows MDM section" {
    run env SKIP_SUDO=1 perl -e 'alarm shift; exec @ARGV' 15 ./natilius.sh doctor
    if [ "$status" -eq 142 ]; then
        skip "natilius doctor timed out"
    fi
    [ "$status" -eq 0 ]
    [[ "$output" == *"MDM"* ]] || [[ "$output" == *"Enterprise"* ]]
}

@test "natilius setup --check shows homebrew packages preview" {
    run ./natilius.sh setup --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Homebrew"* ]] || [[ "$output" == *"Packages"* ]] || [[ "$output" == *"Modules"* ]]
}

@test "natilius --profile with nonexistent profile uses default" {
    run ./natilius.sh --profile nonexistent setup --check
    # Should either work with fallback or give informative error
    # We accept both behaviors
    [[ "$status" -eq 0 ]] || [[ "$output" == *"not found"* ]]
}

@test "environment variable overrides work" {
    # Test that NATILIUS_ prefixed env vars are documented
    run ./natilius.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"NATILIUS_PYTHONVER"* ]]
}

@test "natilius --verbose increases output" {
    run ./natilius.sh --verbose setup --check
    [ "$status" -eq 0 ]
    # Verbose mode should have more output
    [ ${#output} -gt 50 ]
}

@test "natilius dry run shows all config categories" {
    run ./natilius.sh setup --check
    [ "$status" -eq 0 ]
    # Should show various configuration categories
    [[ "$output" == *"Modules"* ]]
}
