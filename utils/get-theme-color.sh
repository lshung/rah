#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

# Get the color of the theme
get_theme_color() {
    local theme_name="$1"
    local theme_flavor="$2"
    local color_name="$3"
    local output_format="${4:-hex}"  # Default to hex if not specified
    local alpha_value="${5:-1}"      # Default alpha to 1 if not specified
    local color_file="$APP_CONFIGS_ROFI_DIR/colors/${theme_name}-${theme_flavor}.rasi"
    local color_value

    # Validate input parameters
    if [ -z "$theme_name" ] || [ -z "$theme_flavor" ] || [ -z "$color_name" ]; then
        echo "Usage: get_theme_color <theme_name> <theme_flavor> <color_name> [output_format] [alpha]" >&2
        echo "Output formats: hex, rgb, rgba" >&2
        echo "Alpha: 0.0 to 1.0 (only used with rgba format)" >&2
        return 1
    fi

    # Validate output format
    if [[ ! "$output_format" =~ ^(hex|rgb|rgba)$ ]]; then
        echo "Invalid output format: $output_format. Use: hex, rgb, or rgba" >&2
        return 1
    fi

    # Validate alpha value if using rgba format
    if [ "$output_format" = "rgba" ]; then
        if ! [[ "$alpha_value" =~ ^[0-9]*\.?[0-9]+$ ]] || (( $(echo "$alpha_value < 0" | bc -l) )) || (( $(echo "$alpha_value > 1" | bc -l) )); then
            echo "Invalid alpha value: $alpha_value. Must be between 0.0 and 1.0" >&2
            return 1
        fi
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

    # Convert to requested format
    case "$output_format" in
        "hex")
            echo "$color_value"
            ;;
        "rgb")
            convert_hex_to_rgb "$color_value"
            ;;
        "rgba")
            convert_hex_to_rgba "$color_value" "$alpha_value"
            ;;
    esac

    return 0
}

# Function to convert hex color to RGB format
convert_hex_to_rgb() {
    local hex_color="$1"

    # Remove the # prefix
    hex_color="${hex_color#\#}"

    # Extract RGB components
    local r=$((16#${hex_color:0:2}))
    local g=$((16#${hex_color:2:2}))
    local b=$((16#${hex_color:4:2}))

    echo "rgb($r, $g, $b)"
}

# Function to convert hex color to RGBA format
convert_hex_to_rgba() {
    local hex_color="$1"
    local alpha_value="$2"

    # Remove the # prefix
    hex_color="${hex_color#\#}"

    # Extract RGB components
    local r=$((16#${hex_color:0:2}))
    local g=$((16#${hex_color:2:2}))
    local b=$((16#${hex_color:4:2}))

    echo "rgba($r, $g, $b, $alpha_value)"
}
