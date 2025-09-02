#compdef natilius
# shellcheck shell=bash disable=SC2148,SC2034,SC2296,SC2206,SC2012

# Zsh completion for natilius

_natilius() {
    local context state state_descr line
    local -a commands options

    commands=(
        'setup:Run the full setup process'
        'doctor:Run system diagnostics and checks'
        'list-modules:List all available modules'
        'version:Show version information'
        'help:Show help message'
    )

    options=(
        '(-v --verbose)'{-v,--verbose}'[Enable verbose output]'
        '(-q --quiet)'{-q,--quiet}'[Suppress non-error output]'
        '(-i --interactive)'{-i,--interactive}'[Run in interactive mode]'
        '(-c --check --dry-run)'{-c,--check,--dry-run}'[Run in check/dry-run mode]'
        '(-p --profile)'{-p,--profile}'[Use a specific configuration profile]:profile:_natilius_profiles'
        '(-h --help)'{-h,--help}'[Show help message]'
        '--version[Show version information]'
    )

    _arguments -C \
        '1: :_describe "command" commands' \
        '*: :_describe "option" options'
}

_natilius_profiles() {
    local profiles
    profiles=(${(f)"$(ls ~/.natiliusrc.* 2>/dev/null | sed 's/.*\.natiliusrc\.//' | grep -v example)"})
    _describe 'profiles' profiles
}

_natilius "$@"
