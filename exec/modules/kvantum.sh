#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Kvantum..."

# Khai báo biến
ROOT_URL="https://raw.githubusercontent.com/catppuccin/kvantum/main/themes"
FLAVOR="mocha"
ACCENT="peach"

THEME_NAME="catppuccin-${FLAVOR}-${ACCENT}"
SVG_FILE_NAME="${THEME_NAME}.svg"
SVG_FILE_URL="${ROOT_URL}/${THEME_NAME}/${SVG_FILE_NAME}"
KVCONFIG_FILE_NAME="${THEME_NAME}.kvconfig"
KVCONFIG_FILE_URL="${ROOT_URL}/${THEME_NAME}/${KVCONFIG_FILE_NAME}"

KVANTUM_CONFIG_DIR="$HOME/.config/Kvantum"
THEME_DIR="$KVANTUM_CONFIG_DIR/${THEME_NAME}"

# Dọn dẹp thư mục
mkdir -p "$KVANTUM_CONFIG_DIR"
rm -rf "$THEME_DIR"
mkdir -p "$THEME_DIR"

# Tải về Catppuccin theme
echo "Đang tải về $SVG_FILE_NAME..."
if ! _download_with_retry "$SVG_FILE_URL" "$THEME_DIR/$SVG_FILE_NAME"; then
    echo "Không thể tải về $SVG_FILE_NAME."
fi

echo "Đang tải về $KVCONFIG_FILE_NAME..."
if ! _download_with_retry "$KVCONFIG_FILE_URL" "$THEME_DIR/$KVCONFIG_FILE_NAME"; then
    echo "Không thể tải về $KVCONFIG_FILE_NAME."
fi

# Tạo config file cho Kvantum
cat > "$KVANTUM_CONFIG_DIR/kvantum.kvconfig" << EOF
[General]
theme=${THEME_NAME}
EOF
