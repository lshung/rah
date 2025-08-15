#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Hyprland configuration..."

# Declare variables
HYPR_CONFIG_DIR="$HOME"/.config/hypr
HYPRLOCK_CONFIG_FILE="$HYPR_CONFIG_DIR"/hyprlock.conf

# Clean up Hyprland config directory
mkdir -p "$HYPR_CONFIG_DIR"
rm -rf "$HYPR_CONFIG_DIR"/*

# Copy Hyprland configuration template
cp -r "$APP_CONFIGS_HYPR_DIR"/* "$HYPR_CONFIG_DIR"/

# Edit hyprlock configuration according to theme, flavor and accent
sed -i "s/@@theme@@/$THEME_NAME/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$HYPRLOCK_CONFIG_FILE"

hyprctl reload
