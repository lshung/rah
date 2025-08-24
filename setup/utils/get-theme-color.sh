#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Get the color of the theme
get_theme_color() {
    local theme_name="$1"
    local theme_flavor="$2"
    local color_name="$3"
    local color_file="$APP_CONFIGS_ROFI_DIR/colors/${theme_name}-${theme_flavor}.rasi"
    local color_value

    # Validate input parameters
    if [ -z "$theme_name" ] || [ -z "$theme_flavor" ] || [ -z "$color_name" ]; then
        echo "Usage: get_theme_color <theme_name> <theme_flavor> <color_name>" >&2
        return 1
    fi

    # Check if the color file exists
    if [ ! -f "$color_file" ]; then
        echo "Color file not found: $color_file" >&2
        return 1
    fi

    # Extract the color value using grep and sed
    # Format: color_name: #hexvalue;
    color_value=$(grep "^[[:space:]]*${color_name}:" "$color_file" | sed 's/.*:[[:space:]]*\(#[0-9a-fA-F]\{6\}\);.*/\1/')

    # Check if color was found
    if [ -z "$color_value" ] || [[ ! "$color_value" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        echo "Color '$color_name' not found or invalid format in $color_file" >&2
        return 1
    fi

    # Return the color value
    echo "$color_value"
    return 0
}
