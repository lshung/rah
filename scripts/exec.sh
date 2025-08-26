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
    echo "  --help, -h              Show help"
    echo ""
    echo "Subcommands:"
    echo "  hyprlock                Launch hyprlock"
    echo "  rofi                    Launch rofi"
    echo "  wallpaper               Change wallpaper"
    echo "  wallpaper-selection     Select wallpaper from rofi menu"
    echo "  wlogout                 Launch wlogout"
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
        hyprlock)
            shift
            source "$APP_SCRIPTS_DIR/hyprlock.sh" "$@"
            ;;
        rofi)
            shift
            source "$APP_SCRIPTS_DIR/rofi.sh" "$@"
            ;;
        wallpaper)
            shift
            source "$APP_SCRIPTS_DIR/wallpaper.sh" "$@"
            ;;
        wallpaper-selection)
            shift
            source "$APP_SCRIPTS_DIR/wallpaper-selection.sh" "$@"
            ;;
        wlogout)
            shift
            source "$APP_SCRIPTS_DIR/wlogout.sh" "$@"
            ;;
        *)
            echo "Error: Invalid subcommand '$1'"
            show_usage
            exit 1
            ;;
    esac
fi
