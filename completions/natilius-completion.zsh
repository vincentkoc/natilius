#compdef natilius

_natilius() {
    local -a cmds opts profiles

    cmds=(init setup doctor modules profiles version help)
    opts=(-v --verbose -q --quiet -i --interactive -c --check --dry-run -p --profile --module -h --help --version)

    # Get built-in profiles from NATILIUS_HOME
    local profile_dir="${NATILIUS_HOME:-$HOME/.natilius}/profiles"
    if [[ -d "$profile_dir" ]]; then
        profiles+=(${(f)"$(ls "$profile_dir"/*.natiliusrc 2>/dev/null | xargs -I {} basename {} .natiliusrc)"})
    fi

    # Check Homebrew cellar location
    local brew_profiles="/opt/homebrew/Cellar/natilius/*/libexec/profiles"
    for dir in $~brew_profiles(N/); do
        profiles+=(${(f)"$(ls "$dir"/*.natiliusrc 2>/dev/null | xargs -I {} basename {} .natiliusrc)"})
    done

    # Get user profiles from ~/.natiliusrc.*
    local user_profiles
    user_profiles=(${(f)"$(ls ~/.natiliusrc.* 2>/dev/null | sed 's/.*\.natiliusrc\.//' | grep -v example)"})
    profiles+=("${user_profiles[@]}")

    # Remove duplicates
    profiles=(${(u)profiles})

    case "$words[2]" in
        -p|--profile)
            compadd "${profiles[@]}"
            ;;
        --module)
            local modules
            modules=(${(f)"$(find "${NATILIUS_HOME:-$HOME/.natilius}/modules" -name "*.sh" 2>/dev/null | sed 's#.*modules/##;s#\.sh$##')"})
            compadd "${modules[@]}"
            ;;
        *)
            compadd "${cmds[@]}" "${opts[@]}"
            ;;
    esac
}

_natilius "$@"
