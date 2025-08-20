#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will execute rofi with an optional style name (no extension)
# The style name is the name of the .rasi file under $HOME/.config/rofi/styles

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Function to show usage
show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION rofi-launcher [--style STYLE|-s STYLE]"
    echo ""
    echo "Options:"
    echo "  --help, -h                 Show help"
    echo "  --style, -s STYLE          Rofi style name under $HOME/.config/rofi/styles (e.g., style-1), without extension (optional)"
}

# Declare variables
style=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_usage
            return 0
            ;;
        --style|-s)
            current_arg="$1"
            shift
            style="${1:-}"
            [[ -z "$style" ]] && { echo "Error: Option $current_arg requires a value"; show_usage; return 1; }
            ;;
        *)
            echo "Error: Invalid option '$1'"
            show_usage
            return 1
            ;;
    esac
    shift
done

# If style is empty, just run rofi -show
if [[ -z "$style" ]]; then
    rofi -show
    return 0
fi

# Style file path
config_file="$HOME/.config/rofi/styles/$style.rasi"

# Check if style file exists
if [[ ! -f "$config_file" ]]; then
    echo "Error: Rofi style '$style' not found at $config_file"
    return 1
fi

# Execute rofi with the style file
rofi -config "$config_file" -show
