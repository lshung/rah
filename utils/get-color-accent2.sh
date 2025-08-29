#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

# Catppuccin accent color pairings
util_get_accent2_color_name() {
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
