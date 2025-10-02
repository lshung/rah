#!/bin/bash

# Launch color picker application

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    parse_arguments "$@"
    launch_color_picker
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
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
    echo "Usage: $APP_NAME_LOWER $ACTION color-picker [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                      Show help"
}

launch_color_picker() {
    $COLOR_PICKER_COMMAND
}

main "$@"
