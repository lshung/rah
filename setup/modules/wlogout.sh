#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Wlogout configuration..."

# Declare variables
WLOGOUT_CONFIG_DIR="$HOME"/.config/wlogout
ICON_BASE_URL="https://raw.githubusercontent.com/catppuccin/wlogout/main/icons/wlogout/$THEME_FLAVOR/$THEME_ACCENT"
COLOR_URL="https://raw.githubusercontent.com/catppuccin/wlogout/main/themes/$THEME_FLAVOR/$THEME_ACCENT.css"
ICON_NAMES=("hibernate" "lock" "logout" "reboot" "shutdown" "suspend")

# Clean up Wlogout config directory
mkdir -p "$WLOGOUT_CONFIG_DIR"
rm -rf "$WLOGOUT_CONFIG_DIR"/*
mkdir -p "$WLOGOUT_CONFIG_DIR"/icons

# Copy Wlogout configuration template
cp "$APP_CONFIGS_WLOGOUT_DIR/style.css" "$WLOGOUT_CONFIG_DIR"/style.css
cp "$APP_CONFIGS_WLOGOUT_DIR/layout" "$WLOGOUT_CONFIG_DIR"/layout

# Download icons
for icon in "${ICON_NAMES[@]}"; do
    DOWNLOAD_URL="${ICON_BASE_URL}/${icon}.svg"
    OUTPUT_FILE="$WLOGOUT_CONFIG_DIR/icons/${icon}.svg"

    if ! _download_with_retry "$DOWNLOAD_URL" "$OUTPUT_FILE"; then
        exit 1
    fi
done

# Download css
if ! _download_with_retry "$COLOR_URL" "$WLOGOUT_CONFIG_DIR/colors.css"; then
    exit 1
fi
