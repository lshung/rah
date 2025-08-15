#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Wlogout..."

# Khai báo biến
WLOGOUT_CONFIG_DIR="$HOME"/.config/wlogout
ICON_BASE_URL="https://raw.githubusercontent.com/catppuccin/wlogout/main/icons/wlogout/$THEME_FLAVOR/$THEME_ACCENT"
COLOR_URL="https://raw.githubusercontent.com/catppuccin/wlogout/main/themes/$THEME_FLAVOR/$THEME_ACCENT.css"
ICON_NAMES=("hibernate" "lock" "logout" "reboot" "shutdown" "suspend")

# Dọn dẹp thư mục config của Wlogout
mkdir -p "$WLOGOUT_CONFIG_DIR"
rm -rf "$WLOGOUT_CONFIG_DIR"/*
mkdir -p "$WLOGOUT_CONFIG_DIR"/icons

# Sao chép template cấu hình Wlogout
cp "$APP_CONFIGS_WLOGOUT_DIR/style.css" "$WLOGOUT_CONFIG_DIR"/style.css
cp "$APP_CONFIGS_WLOGOUT_DIR/layout" "$WLOGOUT_CONFIG_DIR"/layout

# Tải xuống các file icon
for icon in "${ICON_NAMES[@]}"; do
    DOWNLOAD_URL="${ICON_BASE_URL}/${icon}.svg"
    OUTPUT_FILE="$WLOGOUT_CONFIG_DIR/icons/${icon}.svg"

    if ! _download_with_retry "$DOWNLOAD_URL" "$OUTPUT_FILE"; then
        exit 1
    fi
done

# Tải xuống file css
if ! _download_with_retry "$COLOR_URL" "$WLOGOUT_CONFIG_DIR/colors.css"; then
    exit 1
fi
