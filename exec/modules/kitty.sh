#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Kitty..."
mkdir -p "$HOME"/.config/kitty
rm -rf "$HOME"/.config/kitty/*
cp -r "$CONFIGS_DIR"/kitty/* "$HOME"/.config/kitty/
