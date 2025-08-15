#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Waybar..."

# Khai báo biến
WAYBAR_CONFIG_DIR="$HOME"/.config/waybar

# Dọn dẹp thư mục config của Waybar
mkdir -p "$WAYBAR_CONFIG_DIR"
rm -rf "$WAYBAR_CONFIG_DIR"/*
mkdir -p "$WAYBAR_CONFIG_DIR"/colors

# Sao chép template cấu hình Waybar
cp "$APP_CONFIGS_WAYBAR_DIR/config.jsonc" "$WAYBAR_CONFIG_DIR"/config.jsonc
cp "$APP_CONFIGS_WAYBAR_DIR/style.css" "$WAYBAR_CONFIG_DIR"/style.css
cp "$APP_CONFIGS_WAYBAR_DIR/colors/$THEME_NAME-$THEME_FLAVOR.css" "$WAYBAR_CONFIG_DIR"/colors/

# Chỉnh sửa cấu hình Waybar theo theme, flavor và accent
sed -i "s/@@theme@@/$THEME_NAME/g" "$WAYBAR_CONFIG_DIR"/style.css
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$WAYBAR_CONFIG_DIR"/style.css
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$WAYBAR_CONFIG_DIR"/style.css

# Reload
killall waybar > /dev/null 2>&1 || true
waybar &
