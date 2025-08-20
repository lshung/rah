#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Rofi configuration..."

# Declare variables
ROFI_CONFIG_DIR="$HOME"/.config/rofi

# Clean up Rofi config directory
mkdir -p "$ROFI_CONFIG_DIR"
rm -rf "$ROFI_CONFIG_DIR"/*
mkdir -p "$ROFI_CONFIG_DIR"/styles
mkdir -p "$ROFI_CONFIG_DIR"/colors

# Copy Rofi configuration template
cp "$APP_CONFIGS_ROFI_DIR/styles/$ROFI_STYLE.rasi" "$ROFI_CONFIG_DIR"/config.rasi
cp "$APP_CONFIGS_ROFI_DIR/styles"/*.rasi "$ROFI_CONFIG_DIR"/styles/
cp "$APP_CONFIGS_ROFI_DIR/colors/$THEME_NAME-$THEME_FLAVOR.rasi" "$ROFI_CONFIG_DIR"/colors/

# Edit Rofi configuration according to theme, flavor and accent
for file in "$ROFI_CONFIG_DIR"/config.rasi "$ROFI_CONFIG_DIR"/styles/*.rasi; do
    sed -i "s/@@theme@@/$THEME_NAME/g" "$file"
    sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$file"
    sed -i "s/@@accent@@/$THEME_ACCENT/g" "$file"
done
