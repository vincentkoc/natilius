#!/bin/bash

# Natilius - One-click Mac Developer Environment Setup
# https://github.com/koconder/natilius

# Warning
echo -e "\033[0;31m⚠️  !! Warning: Use at your own risk, and ensure you have a backup !!  ⚠️\033[0m"
read -r -s -p $'Press enter to continue...'
echo -e

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
