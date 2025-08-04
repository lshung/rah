#!/bin/bash

# Thoát nếu có lỗi
set -e

# Cài đặt JetBrains Mono Nerd Font
if ! fc-list | grep -q "JetBrainsMonoNerdFont"; then
    sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
    fc-cache -fv
fi

# Cài đặt Symbols Nerd Font
if ! fc-list | grep -q "SymbolsNerdFont"; then
    sudo pacman -S --noconfirm ttf-nerd-fonts-symbols
    fc-cache -fv
fi

# Cập nhật cấu hình Hyprland
echo "Cập nhật cấu hình Hyprland..."
rm -rf "$HOME"/.config/hypr/*
cp -r ./configs/hypr/* "$HOME"/.config/hypr/
hyprctl reload

# Cập nhật cấu hình Waybar
echo "Cập nhật cấu hình Waybar..."
killall waybar > /dev/null 2>&1 || true
rm -rf "$HOME"/.config/waybar/*
cp -r ./configs/waybar/* "$HOME"/.config/waybar/
waybar &

# Cập nhật cấu hình Kitty
echo "Cập nhật cấu hình Kitty..."
rm -rf "$HOME"/.config/kitty/*
cp -r ./configs/kitty/* "$HOME"/.config/kitty/

echo "Cập nhật cấu hình thành công! Hãy logout để áp dụng các thay đổi."
