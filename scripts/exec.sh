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
        show_usage
        exit 0
    else
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            hyprlock|\
            key-bindings|\
            rofi|\
            wallpaper|\
            wallpaper-selection|\
            waybar-fcitx5|\
            wlogout)
                source_shell_script "$@"
                ;;
            *)
                echo "Error: Invalid subcommand '$1'"
                show_usage
                exit 1
                ;;
        esac
    fi
}

show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION [SUBCOMMAND] [ARGS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show help"
    echo ""
    echo "Subcommands:"
    echo "  hyprlock                Launch hyprlock"
    echo "  key-bindings            Launch key bindings"
    echo "  rofi                    Launch rofi"
    echo "  wallpaper               Change wallpaper"
    echo "  wallpaper-selection     Select wallpaper from rofi menu"
    echo "  waybar-fcitx5           Display Fcitx5 input method in waybar"
    echo "  wlogout                 Launch wlogout"
}

source_shell_script() {
    local script_name="$1"
    local script_file="$APP_SCRIPTS_DIR/${script_name}.sh"

    if [[ -r "$script_file" ]]; then
        shift
        source "$script_file" "$@"
    else
        echo "Error: Script '${script_name}.sh' not found or not readable"
        exit 1
    fi
}

# Call main function with arguments
main "$@"
