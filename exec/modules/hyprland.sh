#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Hyprland..."
mkdir -p "$HOME"/.config/hypr
rm -rf "$HOME"/.config/hypr/*
cp -r "$CONFIGS_DIR"/hypr/* "$HOME"/.config/hypr/

hyprctl reload
