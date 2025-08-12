#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Qt5ct..."
mkdir -p "$HOME"/.config/qt5ct
rm -rf "$HOME"/.config/qt5ct/*
cp -r "$CONFIGS_DIR"/qt5ct/* "$HOME"/.config/qt5ct/

echo "Cập nhật cấu hình Qt6ct..."
mkdir -p "$HOME"/.config/qt6ct
rm -rf "$HOME"/.config/qt6ct/*
cp -r "$CONFIGS_DIR"/qt6ct/* "$HOME"/.config/qt6ct/
