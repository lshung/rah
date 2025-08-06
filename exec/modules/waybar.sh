#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Waybar..."
mkdir -p "$HOME"/.config/waybar
rm -rf "$HOME"/.config/waybar/*
cp -r "$CONFIGS_DIR"/waybar/* "$HOME"/.config/waybar/

killall waybar > /dev/null 2>&1 || true
waybar &
