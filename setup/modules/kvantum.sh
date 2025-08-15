#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Kvantum configuration..."

# Khai báo biến
KVANTUM_CONFIG_DIR="$HOME/.config/Kvantum"
THEME_FULL_NAME="${THEME_NAME}-${THEME_FLAVOR}-${THEME_ACCENT}"
THEME_DIR="$KVANTUM_CONFIG_DIR/${THEME_FULL_NAME}"

BASE_URL="https://raw.githubusercontent.com/catppuccin/kvantum/main/themes"
SVG_FILE_NAME="${THEME_FULL_NAME}.svg"
SVG_FILE_URL="${BASE_URL}/${THEME_FULL_NAME}/${SVG_FILE_NAME}"
KVCONFIG_FILE_NAME="${THEME_FULL_NAME}.kvconfig"
KVCONFIG_FILE_URL="${BASE_URL}/${THEME_FULL_NAME}/${KVCONFIG_FILE_NAME}"

# Clean up Kvantum config directory
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
