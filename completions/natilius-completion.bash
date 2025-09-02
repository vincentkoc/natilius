#!/bin/bash
# Bash completion for natilius

_natilius_completion() {
    local cur prev opts commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Available commands
    commands="setup doctor list-modules version help"

    # Available options
    opts="--verbose --quiet --interactive --check --dry-run --profile --help --version"

    # Available modules (simplified list) - reserved for future use
    # modules="system/system_update system/security system/directories system/cleanup
    #          dev_environments/python dev_environments/node dev_environments/ruby
    #          dev_environments/rust dev_environments/go dev_environments/java
    #          dev_environments/php dev_environments/flutter
    #          applications/homebrew applications/apps applications/espanso
    #          ide/ide_setup preferences/mac_preferences preferences/system_preferences
    #          dotfiles"

    case $prev in
        --profile|-p)
            # Complete with existing profile files
            local profiles
            profiles=$(find ~ -maxdepth 1 -name ".natiliusrc.*" 2>/dev/null | sed 's/.*\.natiliusrc\.//' | grep -v example)
            mapfile -t COMPREPLY < <(compgen -W "$profiles" -- "$cur")
            return 0
            ;;
    esac

    # If we're completing the first argument (command)
    if [[ $COMP_CWORD -eq 1 ]]; then
        mapfile -t COMPREPLY < <(compgen -W "$commands $opts" -- "$cur")
        return 0
    fi

    # Complete with remaining options
    mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
    return 0
}

# Register the completion function
complete -F _natilius_completion natilius
