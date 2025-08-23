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
# Declare variable COLOR_ACCENT2
if [ -n "$HYPRLAND_COLOR_ACCENT2" ]; then
    COLOR_ACCENT2="$HYPRLAND_COLOR_ACCENT2"
elif [ -n "$THEME_ACCENT2" ]; then
    COLOR_ACCENT2="$THEME_ACCENT2"
else
    COLOR_ACCENT2=$(get_accent2_color "$THEME_ACCENT")
fi

# Sync Hyprland configuration
mkdir -p "$HYPR_CONFIG_DIR"
sync_contents_of_two_dirs "$APP_CONFIGS_HYPR_DIR" "$HYPR_CONFIG_DIR"

echo "Editing Hyprland variables configuration..."
sed -i "s/^\$COLOR_THEME = .*$/\$COLOR_THEME = ${THEME_NAME}-${THEME_FLAVOR}/g" "$HYPR_CONFIG_DIR"/hyprland/variables.conf
sed -i "s/^\$ANIMATIONS_STYLE = .*$/\$ANIMATIONS_STYLE = ${HYPRLAND_ANIMATIONS_STYLE}/g" "$HYPR_CONFIG_DIR"/hyprland/variables.conf
sed -i "s/^\$COLOR_ACCENT = .*$/\$COLOR_ACCENT = \$${THEME_ACCENT}/g" "$HYPR_CONFIG_DIR"/hyprland/variables.conf
sed -i "s/^\$COLOR_ACCENT_ALPHA = .*$/\$COLOR_ACCENT_ALPHA = \$${THEME_ACCENT}Alpha/g" "$HYPR_CONFIG_DIR"/hyprland/variables.conf
sed -i "s/^\$COLOR_ACCENT2 = .*$/\$COLOR_ACCENT2 = \$${COLOR_ACCENT2}/g" "$HYPR_CONFIG_DIR"/hyprland/variables.conf
sed -i "s/^\$COLOR_ACCENT2_ALPHA = .*$/\$COLOR_ACCENT2_ALPHA = \$${COLOR_ACCENT2}Alpha/g" "$HYPR_CONFIG_DIR"/hyprland/variables.conf

# Edit hyprlock configuration according to theme, flavor and accent
echo "Editing hyprlock configuration..."
sed -i "s/@@theme@@/$THEME_NAME/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$HYPRLOCK_CONFIG_FILE"

echo "Reloading Hyprland..."
hyprctl reload
