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
ROFI_CONFIG_DIR="$HOME"/.config/rofi

# Dọn dẹp thư mục config của Rofi
mkdir -p "$ROFI_CONFIG_DIR"
rm -rf "$ROFI_CONFIG_DIR"/*
mkdir -p "$ROFI_CONFIG_DIR"/colors

# Sao chép template cấu hình Rofi
cp "$APP_CONFIGS_ROFI_DIR/styles/$ROFI_STYLE.rasi" "$ROFI_CONFIG_DIR"/config.rasi
cp "$APP_CONFIGS_ROFI_DIR/colors/$THEME_NAME-$THEME_FLAVOR.rasi" "$ROFI_CONFIG_DIR"/colors/

# Chỉnh sửa cấu hình Rofi theo theme, flavor và accent
sed -i "s/@@theme@@/$THEME_NAME/g" "$ROFI_CONFIG_DIR"/config.rasi
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$ROFI_CONFIG_DIR"/config.rasi
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$ROFI_CONFIG_DIR"/config.rasi
