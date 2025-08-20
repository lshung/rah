#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Function to show usage
show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION [SUBCOMMAND] [ARGS]"
    echo ""
    echo "Options:"
    echo "  --help, -h          Show help"
    echo ""
    echo "Subcommands:"
    echo "  rofi-launcher       Launch rofi"
}

# Get first option (--exec or -x)
ACTION="$1"
# Shift once to remove first option
shift

# Process command line arguments
if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
else
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        rofi-launcher)
            shift
            # Source and forward remaining arguments
            # shellcheck disable=SC1090
            source "$APP_SCRIPTS_DIR/rofi-launcher.sh" "$@"
            ;;
        *)
            echo "Error: Invalid subcommand '$1'"
            show_usage
            exit 1
            ;;
    esac
fi
