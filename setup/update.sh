#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Function to source a specific module
source_module() {
    local module_name="$1"
    local module_file="$APP_SETUP_MODULES_DIR/${module_name}.sh"

    if [[ -f "$module_file" ]]; then
        source "$module_file"
    else
        echo "Error: Module '$module_name' not found at $module_file"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h      Show help"
    echo "  fonts           Update fonts module"
    echo "  hyprland        Update hyprland module"
    echo "  icon-themes     Update icon-themes module"
    echo "  kitty           Update kitty module"
    echo "  kvantum         Update kvantum module"
    echo "  nwg-look        Update nwg-look module"
    echo "  qtct            Update qtct module"
    echo "  rofi            Update rofi module"
    echo "  waybar          Update waybar module"
    echo "  wlogout         Update wlogout module"
    echo ""
    echo "If no options are provided, all modules will be updated."
}

# Get first option (--update or -u)
ACTION="$1"
# Shift once to remove first option
shift

# Process command line arguments
if [[ $# -eq 0 ]]; then
    # No arguments, source all modules
    source_module "fonts"
    source_module "icon-themes"
    source_module "kitty"
    source_module "wlogout"
    source_module "nwg-look"
    source_module "qtct"
    source_module "rofi"
    source_module "kvantum"
    source_module "hyprland"
    source_module "waybar"
    echo "Configuration updated successfully! Please logout to apply changes."
else
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        fonts)
            source_module "fonts"
            ;;
        hyprland)
            source_module "hyprland"
            ;;
        icon-themes)
            source_module "icon-themes"
            ;;
        kitty)
            source_module "kitty"
            ;;
        kvantum)
            source_module "kvantum"
            ;;
        nwg-look)
            source_module "nwg-look"
            ;;
        qtct)
            source_module "qtct"
            ;;
        rofi)
            source_module "rofi"
            ;;
        waybar)
            source_module "waybar"
            ;;
        wlogout)
            source_module "wlogout"
            ;;
        *)
            echo "Error: Invalid option '$1'"
            show_usage
            exit 1
            ;;
    esac
fi
