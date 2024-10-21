#!/usr/bin/env bats

@test "Natilius exits immediately in dry-run mode" {
    run ./natilius.sh --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Running in dry-run mode. No system changes will be made."* ]]
}

@test "Natilius loads configuration in dry-run mode" {
    run ./natilius.sh --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Loaded configuration from"* ]]
}

@test "Natilius loads configuration correctly" {
    run ./natilius.sh --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Loaded configuration from"* ]]
    [[ "$output" == *"Enabled modules:"* ]]
}
