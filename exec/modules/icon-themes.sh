#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cài đặt icon themes..."

# Cài đặt Tela-circle-icon-theme
if ! pacman -Q tela-circle-icon-theme-all > /dev/null 2>&1; then
    echo "Cài đặt Tela Circle Icon Theme..."
    sudo pacman -S --noconfirm tela-circle-icon-theme-all
fi
