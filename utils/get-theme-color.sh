#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

# Get the color of the theme
util_get_theme_color() {
    local theme_name="$1"
    local theme_flavor="$2"
    local color_name="$3"
    local output_format="${4:-hex}"  # Default to hex if not specified
    local alpha_value="${5:-1}"      # Default alpha to 1 if not specified
    local color_file="$APP_CONFIGS_ROFI_DIR/colors/${theme_name}-${theme_flavor}.rasi"
    local color_value=""

    _validate_arguments "$theme_name" "$theme_flavor" "$color_name" "$output_format" "$alpha_value" || return 1
    _check_if_color_file_exists "$color_file" || return 1
    _get_hex_color_value_from_color_file "$color_file" "$color_name" >/dev/null 2>&1 || return 1

    color_value=$(_get_hex_color_value_from_color_file "$color_file" "$color_name")

    _print_color_value_in_requested_format "$color_value" "$output_format" "$alpha_value"
    return 0
}

_validate_arguments() {
    local theme_name="$1"
    local theme_flavor="$2"
    local color_name="$3"
    local output_format="$4"
    local alpha_value="$5"

    _validate_minimum_number_of_arguments "$@" || return 1
    _validate_output_format "$output_format" || return 1
    _validate_alpha_value_if_rgba "$output_format" "$alpha_value" || return 1
}

_show_usage_to_get_theme_color() {
    echo "Usage: util_get_theme_color <theme_name> <theme_flavor> <color_name> [output_format] [alpha]"
    echo "With output formats is 'hex', 'rgb', or 'rgba'"
    echo "And alpha is 0.0 to 1.0 if using 'rgba' format"
    echo "Example: util_get_theme_color 'catppuccin' 'mocha' 'peach' 'rgba' 0.5"
}

_validate_minimum_number_of_arguments() {
    if [[ $# -lt 3 ]]; then
        echo "Error: Not enough arguments" 1>&2
        _show_usage_to_get_theme_color
        return 1
    fi
}

_validate_output_format() {
    local output_format="$1"

    if [[ ! "$output_format" =~ ^(hex|rgb|rgba)$ ]]; then
        echo "Error: Invalid output format '$output_format'" 1>&2
        _show_usage_to_get_theme_color
        return 1
    fi
}

_validate_alpha_value_if_rgba() {
    local output_format="$1"
    local alpha_value="$2"

    if [[ "$output_format" != "rgba" ]]; then
        return 0
    fi

    if ! [[ "$alpha_value" =~ ^[0-9]*\.?[0-9]+$ ]] || (( $(echo "$alpha_value < 0" | bc -l) )) || (( $(echo "$alpha_value > 1" | bc -l) )); then
        echo "Error: Invalid alpha value '$alpha_value'" 1>&2
        _show_usage_to_get_theme_color
        return 1
    fi
}

_check_if_color_file_exists() {
    local color_file="$1"

    if [ ! -f "$color_file" ]; then
        echo "Error: Color file not found at '$color_file'" 1>&2
        return 1
    fi
}

_get_hex_color_value_from_color_file() {
    local color_file="$1"
    local color_name="$2"

    local color_value=$(grep "^[[:space:]]*${color_name}[[:space:]]*:" "$color_file" | sed 's/.*:[[:space:]]*\(#[0-9a-fA-F]\{6\}\);.*/\1/')

    if [ -z "$color_value" ] || [[ ! "$color_value" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        echo "Error: Color '$color_name' not found or invalid format in $color_file" 1>&2
        return 1
    fi

    echo "$color_value"
}

_print_color_value_in_requested_format() {
    local color_value="$1"
    local output_format="$2"
    local alpha_value="$3"

    case "$output_format" in
        "hex")
            echo "$color_value"
            ;;
        "rgb")
            _convert_hex_to_rgb "$color_value"
            ;;
        "rgba")
            _convert_hex_to_rgba "$color_value" "$alpha_value"
            ;;
    esac
}

_convert_hex_to_rgb() {
    local hex_color="$1"

    # Remove the # prefix
    hex_color="${hex_color#\#}"

    # Extract RGB components
    local r=$((16#${hex_color:0:2}))
    local g=$((16#${hex_color:2:2}))
    local b=$((16#${hex_color:4:2}))

    echo "rgb($r, $g, $b)"
}

_convert_hex_to_rgba() {
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
