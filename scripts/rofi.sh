#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will execute rofi with an optional style name (no extension)
# The style name is the name of the file .rasi located in the directory $ROFI_CONFIG_STYLES_DIR

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

main() {
    declare_variables
    parse_arguments "$@"
    validate_style_file_if_provided
    launch_rofi
}

declare_variables() {
    STYLE=""
    STYLE_FILE=""
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -s|--style)
                current_arg="$1"
                shift
                STYLE="${1:-}"
                [[ -z "$STYLE" ]] && { echo "Error: Option $current_arg requires a value"; show_usage; exit 1; }
                ;;
            *)
                echo "Error: Invalid option '$1'"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION rofi [--style STYLE|-s STYLE]"
    echo ""
    echo "Options:"
    echo "  -h, --help                 Show help"
    echo "  -s, --style STYLE          Rofi style name under $ROFI_CONFIG_STYLES_DIR (e.g., style-1 without extension)"
}

validate_style_file_if_provided() {
    if [[ -n "$STYLE" ]]; then
        STYLE_FILE="$ROFI_CONFIG_STYLES_DIR/$STYLE.rasi"
        if [[ ! -f "$STYLE_FILE" ]]; then
            echo "Error: Rofi style '$STYLE' not found at $STYLE_FILE" 1>&2
            return 1
        fi
    fi
}

launch_rofi() {
    if [[ -z "$STYLE_FILE" ]]; then
        rofi -show
    else
        rofi -config "$STYLE_FILE" -show
    fi
}

# Call main function with arguments
main "$@"
