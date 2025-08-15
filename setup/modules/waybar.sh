#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Waybar configuration..."

# Declare variables
WAYBAR_CONFIG_DIR="$HOME"/.config/waybar

# Clean up Waybar config directory
mkdir -p "$WAYBAR_CONFIG_DIR"
rm -rf "$WAYBAR_CONFIG_DIR"/*
mkdir -p "$WAYBAR_CONFIG_DIR"/colors

# Copy Waybar configuration template
cp "$APP_CONFIGS_WAYBAR_DIR/config.jsonc" "$WAYBAR_CONFIG_DIR"/config.jsonc
cp "$APP_CONFIGS_WAYBAR_DIR/style.css" "$WAYBAR_CONFIG_DIR"/style.css
cp "$APP_CONFIGS_WAYBAR_DIR/colors/$THEME_NAME-$THEME_FLAVOR.css" "$WAYBAR_CONFIG_DIR"/colors/

# Edit Waybar configuration according to theme, flavor and accent
sed -i "s/@@theme@@/$THEME_NAME/g" "$WAYBAR_CONFIG_DIR"/style.css
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$WAYBAR_CONFIG_DIR"/style.css
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$WAYBAR_CONFIG_DIR"/style.css

# Reload
killall waybar > /dev/null 2>&1 || true
waybar &
