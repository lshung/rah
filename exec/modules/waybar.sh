#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Waybar..."
mkdir -p "$HOME"/.config/waybar
rm -rf "$HOME"/.config/waybar/*
cp -r "$CONFIGS_DIR"/waybar/* "$HOME"/.config/waybar/

killall waybar > /dev/null 2>&1 || true
waybar &
