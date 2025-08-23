#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Catppuccin accent color pairings
get_accent2_color() {
    local color_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    case $color_name in
        "rosewater") echo "green" ;;
        "flamingo") echo "teal" ;;
        "pink") echo "yellow" ;;
        "mauve") echo "peach" ;;
        "red") echo "sky" ;;
        "maroon") echo "sapphire" ;;
        "peach") echo "mauve" ;;
        "yellow") echo "pink" ;;
        "green") echo "rosewater" ;;
        "teal") echo "flamingo" ;;
        "sky") echo "red" ;;
        "sapphire") echo "maroon" ;;
        "blue") echo "peach" ;;
        "lavender") echo "yellow" ;;
        *) echo "mauve" ;; # default
    esac
}
