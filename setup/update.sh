#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

main() {
    declare_variables "$@"
    parse_arguments "$@"
}

declare_variables() {
    ACTION="$1"
}

parse_arguments() {
    shift

    if [[ $# -eq 0 ]]; then
        source_all_modules
    else
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            fonts|\
            hyprland|\
            icon-themes|\
            kitty|\
            kvantum|\
            nwg-look|\
            qtct|\
            rofi|\
            sddm|\
            vscode|\
            waybar|\
            wlogout|\
            zsh)
                source_module "$1"
                ;;
            *)
                echo "Error: Invalid option '$1'"
                show_usage
                exit 1
                ;;
        esac
    fi
}

source_all_modules() {
    source_module "fonts"
    source_module "icon-themes"
    source_module "kitty"
    source_module "wlogout"
    source_module "nwg-look"
    source_module "qtct"
    source_module "rofi"
    source_module "kvantum"
    source_module "sddm"
    source_module "vscode"
    source_module "zsh"
    source_module "hyprland"
    source_module "waybar"
}

source_module() {
    local module_name="$1"
    local module_file="$APP_SETUP_MODULES_DIR/${module_name}.sh"

    if [[ -r "$module_file" ]]; then
        source "$module_file"
    else
        echo "Error: Module '$module_name' not found or not readable"
        exit 1
    fi
}

show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show help"
    echo "  fonts           Update fonts module"
    echo "  hyprland        Update hyprland module"
    echo "  icon-themes     Update icon-themes module"
    echo "  kitty           Update kitty module"
    echo "  kvantum         Update kvantum module"
    echo "  nwg-look        Update nwg-look module"
    echo "  qtct            Update qtct module"
    echo "  rofi            Update rofi module"
    echo "  sddm            Update sddm module"
    echo "  vscode          Update vscode module (Code, Code - OSS, VSCodium, Cursor)"
    echo "  waybar          Update waybar module"
    echo "  wlogout         Update wlogout module"
    echo "  zsh             Update zsh module"
    echo ""
    echo "If no options are provided, all modules will be updated."
}

# Call main function with arguments
main "$@"
