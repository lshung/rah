#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Kitty..."

# Khai báo biến
KITTY_CONFIG_DIR="$HOME"/.config/kitty

# Dọn dẹp thư mục config của Kitty
mkdir -p "$KITTY_CONFIG_DIR"
rm -rf "$KITTY_CONFIG_DIR"/*
mkdir -p "$KITTY_CONFIG_DIR"/colors

# Sao chép template cấu hình Kitty
cp "$APP_CONFIGS_KITTY_DIR/kitty.conf" "$KITTY_CONFIG_DIR"/kitty.conf
cp "$APP_CONFIGS_KITTY_DIR/colors/$THEME_NAME-$THEME_FLAVOR.conf" "$KITTY_CONFIG_DIR"/colors/

# Chỉnh sửa cấu hình Kitty theo theme và flavor
sed -i "s/@@theme@@/$THEME_NAME/g" "$KITTY_CONFIG_DIR"/kitty.conf
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$KITTY_CONFIG_DIR"/kitty.conf
