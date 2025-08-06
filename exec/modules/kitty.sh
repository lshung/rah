#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Kitty..."
mkdir -p "$HOME"/.config/kitty
rm -rf "$HOME"/.config/kitty/*
cp -r "$CONFIGS_DIR"/kitty/* "$HOME"/.config/kitty/
