#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Kvantum..."

# Khai báo biến
KVANTUM_CONFIG_DIR="$HOME/.config/Kvantum"
THEME_FULL_NAME="${THEME_NAME}-${THEME_FLAVOR}-${THEME_ACCENT}"
THEME_DIR="$KVANTUM_CONFIG_DIR/${THEME_FULL_NAME}"

BASE_URL="https://raw.githubusercontent.com/catppuccin/kvantum/main/themes"
SVG_FILE_NAME="${THEME_FULL_NAME}.svg"
SVG_FILE_URL="${BASE_URL}/${THEME_FULL_NAME}/${SVG_FILE_NAME}"
KVCONFIG_FILE_NAME="${THEME_FULL_NAME}.kvconfig"
KVCONFIG_FILE_URL="${BASE_URL}/${THEME_FULL_NAME}/${KVCONFIG_FILE_NAME}"

# Dọn dẹp thư mục config của Kvantum
mkdir -p "$KVANTUM_CONFIG_DIR"
rm -rf "$THEME_DIR"
mkdir -p "$THEME_DIR"

# Tải về file svg và kvconfig
if ! _download_with_retry "$SVG_FILE_URL" "$THEME_DIR/$SVG_FILE_NAME"; then
    exit 1
fi

if ! _download_with_retry "$KVCONFIG_FILE_URL" "$THEME_DIR/$KVCONFIG_FILE_NAME"; then
    exit 1
fi

# Tạo config file cho Kvantum
cat > "$KVANTUM_CONFIG_DIR/kvantum.kvconfig" << EOF
[General]
theme=${THEME_FULL_NAME}
EOF
