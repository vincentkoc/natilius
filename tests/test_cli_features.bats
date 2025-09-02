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
    [[ "$output" == *"Natilius version"* ]]
    [[ "$output" == *"Copyright"* ]]
    [[ "$output" == *"License:"* ]]
}

@test "natilius version shows version information" {
    run ./natilius.sh version
    [ "$status" -eq 0 ]
    [[ "$output" == *"Natilius version"* ]]
}

@test "natilius doctor runs system diagnostics" {
    run ./natilius.sh doctor
    [ "$status" -eq 0 ]
    [[ "$output" == *"System Diagnostics"* ]]
    [[ "$output" == *"System Information:"* ]]
    [[ "$output" == *"Development Tools:"* ]]
    [[ "$output" == *"macOS Version:"* ]]
}

@test "natilius list-modules shows available modules" {
    run ./natilius.sh list-modules
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available Natilius Modules:"* ]]
    [[ "$output" == *"System Modules:"* ]]
    [[ "$output" == *"Development Environment Modules:"* ]]
    [[ "$output" == *"Currently enabled modules"* ]]
}

@test "natilius --check shows dry-run information" {
    run ./natilius.sh --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Running in check/dry-run mode"* ]]
    [[ "$output" == *"The following modules would be executed:"* ]]
}

@test "natilius --verbose increases output verbosity" {
    run ./natilius.sh --verbose --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Running in check/dry-run mode"* ]]
}

@test "natilius --quiet suppresses non-error output" {
    run ./natilius.sh --quiet --check
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
    run ./natilius.sh --verbose --check --quiet
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
    run ./natilius.sh -v --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Running in check/dry-run mode"* ]]
}

@test "natilius -c flag works for check mode" {
    run ./natilius.sh -c
    [ "$status" -eq 0 ]
    [[ "$output" == *"Running in check/dry-run mode"* ]]
}
