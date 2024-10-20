#!/bin/bash

# Utility Functions

get_highest_version() {
    manager="$1"
    if "$manager" versions --bare | grep . > /dev/null; then
        HIGHESTVER=$("$manager" versions --bare | sort -rV | head -n1)
    else
        HIGHESTVER=""
    fi
    echo "$HIGHESTVER"
}

get_current_version() {
    manager="$1"
    if [ "$manager" == "jenv" ] || [ "$manager" == "pyenv" ]; then
        CURRENTVER=$("$manager" version-name)
    elif [ "$manager" == "nodenv" ]; then
        CURRENTVER=$("$manager" version)
    elif [ "$manager" == "rbenv" ]; then
        CURRENTVER=$("$manager" version --bare)
    else
        echo "Unknown version manager: $manager"
        return 1
    fi
    echo "$CURRENTVER"
}
