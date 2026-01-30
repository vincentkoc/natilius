#!/bin/bash
# Bash completion for natilius

_natilius_completion() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local commands="init setup doctor modules profiles version help"
    local options="-v --verbose -q --quiet -i --interactive -c --check --dry-run -p --profile --module -h --help --version"

    # Get built-in profiles from NATILIUS_HOME
    local profile_dir="${NATILIUS_HOME:-$HOME/.natilius}/profiles"
    local profiles=""
    if [[ -d "$profile_dir" ]]; then
        profiles=$(ls "$profile_dir"/*.natiliusrc 2>/dev/null | xargs -I {} basename {} .natiliusrc)
    fi

    # Check Homebrew cellar location
    for dir in /opt/homebrew/Cellar/natilius/*/libexec/profiles; do
        if [[ -d "$dir" ]]; then
            local brew_profiles
            brew_profiles=$(ls "$dir"/*.natiliusrc 2>/dev/null | xargs -I {} basename {} .natiliusrc)
            profiles="$profiles $brew_profiles"
        fi
    done

    # Get user profiles from ~/.natiliusrc.*
    local user_profiles
    user_profiles=$(ls ~/.natiliusrc.* 2>/dev/null | sed 's/.*\.natiliusrc\.//' | grep -v example)
    profiles="$profiles $user_profiles"

    # Remove duplicates
    profiles=$(echo "$profiles" | tr ' ' '\n' | sort -u | tr '\n' ' ')

    case "$prev" in
        -p|--profile)
            COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
            return 0
            ;;
        --module)
            local modules
            modules=$(find "${NATILIUS_HOME:-$HOME/.natilius}/modules" -name "*.sh" 2>/dev/null | sed "s#.*modules/##;s#\.sh\$##")
            COMPREPLY=($(compgen -W "$modules" -- "$cur"))
            return 0
            ;;
    esac

    COMPREPLY=($(compgen -W "$commands $options" -- "$cur"))
    return 0
}

complete -F _natilius_completion natilius
