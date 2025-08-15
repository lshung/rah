#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Installing fonts..."

# Install JetBrainsMono Nerd Font
if ! fc-list | grep -q "JetBrainsMonoNerdFont"; then
    sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
    fc-cache -fv
fi

# Install CaskaydiaCove Nerd Font
if ! fc-list | grep -q "CaskaydiaCoveNerdFont"; then
    sudo pacman -S --noconfirm ttf-cascadia-code-nerd
    fc-cache -fv
fi

# Install Cantarell Font
if ! fc-list | grep -q "Cantarell"; then
    sudo pacman -S --noconfirm cantarell-fonts
    fc-cache -fv
fi

# Install Symbols Nerd Font
if ! fc-list | grep -q "SymbolsNerdFont"; then
    sudo pacman -S --noconfirm ttf-nerd-fonts-symbols
    fc-cache -fv
fi
