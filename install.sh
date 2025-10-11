#!/bin/bash

# natilius - 🐚 Automated One-Click Mac Developer Environment (https://github.com/vincentkoc/natilius)
#
# Copyright (C) 2023 Vincent Koc (@vincent_koc)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#

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

# Clone or update the Natilius repository
if [ -d "$HOME/.natilius/.git" ]; then
    echo -e "\033[0;36mUpdating existing Natilius checkout...\033[0m"
    git -C "$HOME/.natilius" pull --ff-only
else
    git clone https://github.com/vincentkoc/natilius.git "$HOME/.natilius"
fi

# Run the main Natilius script
bash "$HOME/.natilius/natilius.sh"

echo -e "\033[0;32mNatilius installation complete!\033[0m"
