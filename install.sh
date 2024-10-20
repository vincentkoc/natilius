#!/bin/bash

# Natilius - One-click Mac Developer Environment Setup
# https://github.com/koconder/natilius

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "\033[0;36mInstalling Homebrew...\033[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Use Homebrew to install Git if not present
if ! command -v git &> /dev/null; then
    echo -e "\033[0;36mInstalling Git...\033[0m"
    brew install git
fi

# Clone the full Natilius repository
git clone https://github.com/koconder/natilius.git ~/.natilius

# Run the main Natilius script
bash ~/.natilius/natilius.sh

echo -e "\033[0;32mNatilius installation complete!\033[0m"
