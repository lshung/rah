#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Kitty configuration..."

# Declare variables
KITTY_CONFIG_DIR="$HOME"/.config/kitty

# Clean up Kitty config directory
mkdir -p "$KITTY_CONFIG_DIR"
rm -rf "$KITTY_CONFIG_DIR"/*
mkdir -p "$KITTY_CONFIG_DIR"/colors

# Copy Kitty configuration template
cp "$APP_CONFIGS_KITTY_DIR/kitty.conf" "$KITTY_CONFIG_DIR"/kitty.conf
cp "$APP_CONFIGS_KITTY_DIR/colors/$THEME_NAME-$THEME_FLAVOR.conf" "$KITTY_CONFIG_DIR"/colors/

# Edit Kitty configuration according to theme and flavor
sed -i "s/@@theme@@/$THEME_NAME/g" "$KITTY_CONFIG_DIR"/kitty.conf
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$KITTY_CONFIG_DIR"/kitty.conf
