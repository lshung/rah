#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Installing icon themes..."

# Install Tela-circle-icon-theme
if ! pacman -Q tela-circle-icon-theme-all > /dev/null 2>&1; then
    echo "Installing Tela Circle Icon Theme..."
    sudo pacman -S --noconfirm tela-circle-icon-theme-all
fi
