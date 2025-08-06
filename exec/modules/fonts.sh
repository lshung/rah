#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "Cài đặt fonts..."

# Cài đặt JetBrains Mono Nerd Font
if ! fc-list | grep -q "JetBrainsMonoNerdFont"; then
    sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
    fc-cache -fv
fi

# Cài đặt Cantarell Font
if ! fc-list | grep -q "Cantarell"; then
    sudo pacman -S --noconfirm cantarell-fonts
    fc-cache -fv
fi

# Cài đặt Symbols Nerd Font
if ! fc-list | grep -q "SymbolsNerdFont"; then
    sudo pacman -S --noconfirm ttf-nerd-fonts-symbols
    fc-cache -fv
fi
