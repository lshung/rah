#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Hyprland..."

# Khai báo biến
HYPR_CONFIG_DIR="$HOME"/.config/hypr
HYPRLOCK_CONFIG_FILE="$HYPR_CONFIG_DIR"/hyprlock.conf

# Dọn dẹp thư mục config của Hyprland
mkdir -p "$HYPR_CONFIG_DIR"
rm -rf "$HYPR_CONFIG_DIR"/*

# Sao chép template cấu hình Hyprland
cp -r "$CONFIGS_DIR"/hypr/* "$HYPR_CONFIG_DIR"/

# Chỉnh sửa cấu hình hyprlock theo theme, flavor và accent
sed -i "s/@@theme@@/$THEME_NAME/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$HYPRLOCK_CONFIG_FILE"

hyprctl reload
