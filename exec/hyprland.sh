#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Hyprland..."
mkdir -p "$HOME"/.config/hypr
rm -rf "$HOME"/.config/hypr/*
cp -r ./configs/hypr/* "$HOME"/.config/hypr/

hyprctl reload
