#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

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
