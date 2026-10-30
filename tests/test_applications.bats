#!/usr/bin/env bats

setup() {
    export APPLICATION_ROOT="$BATS_TEST_DIRNAME/.."
    export APPLICATION_CALLS="$BATS_TEST_TMPDIR/calls"
    mkdir -p "$BATS_TEST_TMPDIR/bin"
    export PATH="$BATS_TEST_TMPDIR/bin:/usr/bin:/bin"

    cat > "$BATS_TEST_TMPDIR/bin/brew" <<'STUB'
#!/bin/bash
(IFS='|'; printf '%s\n' "$*") >> "$APPLICATION_CALLS"
case "$1:$2" in
    update:) [[ "${BREW_FAIL:-}" != update ]] ;;
    analytics:off) [[ "${BREW_FAIL:-}" != analytics ]] ;;
    tap:)
        [[ "${BREW_FAIL:-}" != taps-list ]] || exit 17
        printf '%s\n' existing/tools
        ;;
    tap:example/tools) [[ "${BREW_FAIL:-}" != tap ]] ;;
    list:--formula)
        [[ "${BREW_FAIL:-}" != formula-list ]] || exit 17
        printf '%s\n' present-formula
        ;;
    list:--cask)
        [[ "${BREW_FAIL:-}" != cask-list ]] || exit 17
        printf '%s\n' present-app
        ;;
    install:new-formula) [[ "${BREW_FAIL:-}" != formula ]] ;;
    install:mas) [[ "${BREW_FAIL:-}" != mas-install ]] ;;
    install:--adopt)
        [[ "${BREW_FAIL:-}" != "$5" ]]
        ;;
    *) exit 90 ;;
esac
STUB
    cat > "$BATS_TEST_TMPDIR/bin/mas" <<'STUB'
#!/bin/bash
(IFS='|'; printf 'mas|%s\n' "$*") >> "$APPLICATION_CALLS"
[[ "${MAS_FAIL:-}" != "$2" ]]
STUB
    chmod +x "$BATS_TEST_TMPDIR/bin/brew" "$BATS_TEST_TMPDIR/bin/mas"

    cat > "$BATS_TEST_TMPDIR/run-module" <<'HARNESS'
#!/bin/bash
set -e -o pipefail
export LOGFILE=/dev/null
log_info() { printf 'info: %s\n' "$1"; }
log_success() { printf 'success: %s\n' "$1"; }
log_error() { printf 'error: %s\n' "$1"; }
restart_system_preferences() { printf 'unexpected restart\n'; return 90; }
retry_network_operation() {
    # The missing-Homebrew test must never invoke its actual installer.
    [[ "$1" != /bin/bash ]] || return 17
    "$@"
}
command() {
    if [[ "$1" == -v ]]; then
        [[ "$2" != brew || "${BREW_MISSING:-}" != 1 ]] || return 1
        [[ "$2" != mas || "${MAS_MISSING:-}" != 1 ]] || return 1
    fi
    builtin command "$@"
}
BREWTAPS=(example/tools)
BREWPACKAGES=(present-formula new-formula)
BREWCASKS=(present-app new-app other-app)
APPSTORE=(123 456)
if [[ "${QUALIFIED_PACKAGES:-}" == 1 ]]; then
    BREWTAPS=()
    BREWPACKAGES=(example/tools/present-formula)
    BREWCASKS=(example/tools/present-app)
fi
source "$APPLICATION_ROOT/modules/applications/$1.sh"
printf 'module completed\n'
HARNESS
}

@test "Homebrew rerun installs missing casks individually with safe adoption" {
    run /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -eq 0 ]
    [[ "$output" == *"module completed"* ]]
    [[ "$output" != *"unexpected restart"* ]]
    grep -Fxq 'install|new-formula' "$APPLICATION_CALLS"
    grep -Fxq 'install|--adopt|--appdir=/Applications|--cask|new-app' "$APPLICATION_CALLS"
    grep -Fxq 'install|--adopt|--appdir=/Applications|--cask|other-app' "$APPLICATION_CALLS"
    ! grep -Eq 'install.*present-|--force|kill|quit|open' "$APPLICATION_CALLS"
}

@test "Homebrew recognizes qualified names without reinstalling registered packages" {
    run env QUALIFIED_PACKAGES=1 /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -eq 0 ]
    ! grep -q '^install' "$APPLICATION_CALLS"
}

@test "Homebrew reports each refused cask without replacement or retry" {
    run env BREW_FAIL=new-app /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -ne 0 ]
    [[ "$output" == *"Homebrew cask installation failed: new-app"* ]]
    [[ "$output" != *"success: Installed Homebrew cask: new-app"* ]]
    [[ "$output" == *"success: Installed Homebrew cask: other-app"* ]]
    [[ "$output" != *"module completed"* ]]
    [ "$(grep -c '^install.*new-app$' "$APPLICATION_CALLS")" -eq 1 ]
    ! grep -Eq -- '--force|kill|quit|open' "$APPLICATION_CALLS"
}

@test "Homebrew propagates a formula failure through its logging pipeline" {
    run env BREW_FAIL=formula /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -ne 0 ]
    [[ "$output" == *"Homebrew package installation failed: new-formula"* ]]
    ! grep -q -- '--cask' "$APPLICATION_CALLS"
}

@test "Homebrew propagates a failed tap and stops dependent installs" {
    run env BREW_FAIL=tap /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -ne 0 ]
    [[ "$output" == *"Homebrew tap failed: example/tools"* ]]
    ! grep -q '^install' "$APPLICATION_CALLS"
}

@test "Homebrew update failure is not hidden by tee" {
    run env BREW_FAIL=update /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -ne 0 ]
    [[ "$output" == *"Homebrew update failed"* ]]
    [[ "$output" != *"module completed"* ]]
}

@test "Homebrew inventory failures never trigger speculative installs" {
    for failure in taps-list formula-list cask-list; do
        : > "$APPLICATION_CALLS"
        run env BREW_FAIL="$failure" QUALIFIED_PACKAGES=1 /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
        [ "$status" -ne 0 ]
        [[ "$output" == *"Could not read installed Homebrew"* ]]
        ! grep -q '^install' "$APPLICATION_CALLS"
    done
}

@test "Homebrew installer failure is not reported as installed" {
    run env BREW_MISSING=1 /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -ne 0 ]
    [[ "$output" == *"Homebrew installation failed"* ]]
    [[ "$output" != *"success: Homebrew installed"* ]]
    [ ! -e "$APPLICATION_CALLS" ]
}

@test "Homebrew analytics failure is reported" {
    run env BREW_FAIL=analytics /bin/bash "$BATS_TEST_TMPDIR/run-module" homebrew
    [ "$status" -ne 0 ]
    [[ "$output" == *"Could not disable Homebrew analytics"* ]]
    [[ "$output" != *"Homebrew analytics disabled"* ]]
}

@test "App Store reports successful installs" {
    run /bin/bash "$BATS_TEST_TMPDIR/run-module" apps
    [ "$status" -eq 0 ]
    [[ "$output" == *"success: Installed App Store app with ID: 123"* ]]
    [[ "$output" == *"success: Installed App Store app with ID: 456"* ]]
}

@test "App Store reports a failed ID and continues without claiming success" {
    run env MAS_FAIL=123 /bin/bash "$BATS_TEST_TMPDIR/run-module" apps
    [ "$status" -ne 0 ]
    [[ "$output" == *"App Store installation failed for ID: 123"* ]]
    [[ "$output" != *"success: Installed App Store app with ID: 123"* ]]
    [[ "$output" == *"success: Installed App Store app with ID: 456"* ]]
    [[ "$output" != *"module completed"* ]]
}

@test "App Store stops if mas cannot be installed" {
    run env MAS_MISSING=1 BREW_FAIL=mas-install /bin/bash "$BATS_TEST_TMPDIR/run-module" apps
    [ "$status" -ne 0 ]
    [[ "$output" == *"Could not install mas"* ]]
    [[ "$output" != *"success: Installed mas"* ]]
    ! grep -q '^mas|' "$APPLICATION_CALLS"
}
