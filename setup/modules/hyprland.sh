#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

echo "Updating Hyprland configuration..."

# Declare variables
if [ -n "$HYPRLAND_COLOR_ACCENT2" ]; then
    COLOR_ACCENT2="$HYPRLAND_COLOR_ACCENT2"
elif [ -n "$THEME_ACCENT2" ]; then
    COLOR_ACCENT2="$THEME_ACCENT2"
else
    COLOR_ACCENT2=$(util_get_accent2_color_name "$THEME_ACCENT")
fi

# Sync Hyprland configuration
mkdir -p "$HYPR_CONFIG_DIR"
util_sync_contents_of_two_dirs "$APP_CONFIGS_HYPR_DIR" "$HYPR_CONFIG_DIR"

echo "Editing Hyprland variables configuration..."
sed -i "s/^\$COLOR_THEME = .*$/\$COLOR_THEME = ${THEME_NAME}-${THEME_FLAVOR}/g" "$HYPRLAND_CONFIG_DIR"/variables.conf
sed -i "s/^\$ANIMATIONS_STYLE = .*$/\$ANIMATIONS_STYLE = ${HYPRLAND_ANIMATIONS_STYLE}/g" "$HYPRLAND_CONFIG_DIR"/variables.conf
sed -i "s/^\$COLOR_ACCENT = .*$/\$COLOR_ACCENT = \$${THEME_ACCENT}/g" "$HYPRLAND_CONFIG_DIR"/variables.conf
sed -i "s/^\$COLOR_ACCENT_ALPHA = .*$/\$COLOR_ACCENT_ALPHA = \$${THEME_ACCENT}Alpha/g" "$HYPRLAND_CONFIG_DIR"/variables.conf
sed -i "s/^\$COLOR_ACCENT2 = .*$/\$COLOR_ACCENT2 = \$${COLOR_ACCENT2}/g" "$HYPRLAND_CONFIG_DIR"/variables.conf
sed -i "s/^\$COLOR_ACCENT2_ALPHA = .*$/\$COLOR_ACCENT2_ALPHA = \$${COLOR_ACCENT2}Alpha/g" "$HYPRLAND_CONFIG_DIR"/variables.conf

# Edit hyprlock configuration according to theme, flavor and accent
echo "Editing hyprlock configuration..."
sed -i "s/@@theme@@/$THEME_NAME/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$HYPRLOCK_CONFIG_FILE"
sed -i "s/@@accent@@/$THEME_ACCENT/g" "$HYPRLOCK_CONFIG_FILE"

# Edit hypridle configuration
echo "Editing hypridle configuration..."
export HYPRIDLE_DIM_DISPLAY_TIMEOUT
export HYPRIDLE_LOCK_SESSION_TIMEOUT
export HYPRIDLE_TURN_OFF_DISPLAY_TIMEOUT
export HYPRIDLE_SUSPEND_TIMEOUT
envsubst < "$APP_CONFIGS_HYPR_DIR/hypridle.conf" > "$HYPRIDLE_CONFIG_FILE"

echo "Reloading Hyprland..."
hyprctl reload
