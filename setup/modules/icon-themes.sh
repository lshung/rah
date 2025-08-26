#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

echo "Installing icon themes..."

# Install Tela-circle-icon-theme
if ! pacman -Q tela-circle-icon-theme-all > /dev/null 2>&1; then
    echo "Installing Tela Circle Icon Theme..."
    sudo pacman -S --noconfirm tela-circle-icon-theme-all
fi
