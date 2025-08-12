#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Rofi..."

# Khai báo biến
FLAVOR="mocha"
ACCENT="peach"

# Cập nhật cấu hình Rofi
mkdir -p "$HOME"/.config/rofi
rm -rf "$HOME"/.config/rofi/*
cp -r "$CONFIGS_DIR"/rofi/* "$HOME"/.config/rofi/

# Chỉnh sửa cấu hình Rofi theo flavor và accent
sed -i "s/@@flavor@@/$FLAVOR/g" "$HOME"/.config/rofi/config.rasi
sed -i "s/@@accent@@/$ACCENT/g" "$HOME"/.config/rofi/config.rasi
