#!/usr/bin/env bats

# Load the utility and logging functions
load '../lib/utils.sh'
load '../lib/logging.sh'

setup() {
  # Mock NATILIUS_DIR
  export NATILIUS_DIR="/mock/natilius/dir"

  # Mock SKIP_UPDATE_CHECK
  export SKIP_UPDATE_CHECK=false

  # Mock LOGFILE
  export LOGFILE="/dev/null"

  # Mock TEST_MODE
  export TEST_MODE=true
}

# Utility function tests
@test "get_highest_version function works" {
  mock_version_manager() {
    echo "1.0.0
2.0.0
1.5.0"
  }
  result=$(get_highest_version mock_version_manager)
  [ "$result" = "2.0.0" ]
}

@test "get_current_version function works for jenv" {
  jenv() {
    echo "1.8.0"
  }
  result=$(get_current_version jenv)
  [ "$result" = "1.8.0" ]
}

@test "get_current_version function works for pyenv" {
  pyenv() {
    echo "3.9.5"
  }
  result=$(get_current_version pyenv)
  [ "$result" = "3.9.5" ]
}

@test "get_current_version function works for nodenv" {
  nodenv() {
    echo "14.17.0"
  }
  result=$(get_current_version nodenv)
  [ "$result" = "14.17.0" ]
}

@test "get_current_version function works for rbenv" {
  rbenv() {
    echo "3.0.1"
  }
  result=$(get_current_version rbenv)
  [ "$result" = "3.0.1" ]
}

@test "restart_system_preferences function works" {
  osascript() {
    echo "System Preferences quit successfully"
  }
  run restart_system_preferences
  [ "$status" -eq 0 ]
  [[ "$output" == *"System Preferences closed"* ]]
}

@test "check_for_updates function exists and runs without errors" {
  run check_for_updates
  echo "Status: $status"
  echo "Output: $output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Checking for Natilius updates..."* ]]
  [[ "$output" == *"Natilius is up to date"* ]]
}

# Logging function tests
@test "log_info function works" {
  run log_info "Test message"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[INFO]"* ]]
  [[ "$output" == *"Test message"* ]]
}

@test "log_success function works" {
  run log_success "Success message"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SUCCESS]"* ]]
  [[ "$output" == *"Success message"* ]]
}

@test "log_warning function works" {
  run log_warning "Warning message"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[WARNING]"* ]]
  [[ "$output" == *"Warning message"* ]]
}

@test "log_error function works" {
  run log_error "Error message"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[ERROR]"* ]]
  [[ "$output" == *"Error message"* ]]
}

# Module tests (mocking the actual operations)
@test "homebrew module file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../modules/applications/homebrew.sh" ]
}

@test "system_update module file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../modules/system/system_update.sh" ]
}

@test "mac_preferences module file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../modules/preferences/mac_preferences.sh" ]
}

@test "espanso module file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../modules/applications/espanso.sh" ]
}

@test "apps module file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../modules/applications/apps.sh" ]
}

@test "cleanup module file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../modules/system/cleanup.sh" ]
}

# Main script test
@test "natilius.sh file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../natilius.sh" ]
}

# Add more tests for specific functions in modules if needed
