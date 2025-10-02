#!/bin/bash

# Get key bindings of hyprland or zsh, and show on terminal or rofi menu

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    declare_variables
    parse_arguments "$@"
    validate_arguments
    get_key_bindings_list
}

declare_variables() {
    KEY_BINDINGS_TYPE=""
    KEY_BINDINGS_STYLE=""
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -t|--type)
                current_arg="$1"
                shift
                KEY_BINDINGS_TYPE="${1:-}"
                [[ -z "$KEY_BINDINGS_TYPE" ]] && { echo "Error: Option $current_arg requires a type value"; show_usage; exit 1; }
                ;;
            -s|--style)
                current_arg="$1"
                shift
                KEY_BINDINGS_STYLE="${1:-}"
                [[ -z "$KEY_BINDINGS_STYLE" ]] && { echo "Error: Option $current_arg requires a style value"; show_usage; exit 1; }
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
    echo "Usage: $APP_NAME_LOWER $ACTION key-bindings [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                      Show help"
    echo "  -t, --type VALUE                Get key bindings for 'hyprland' or 'zsh'"
    echo "  -s, --style VALUE               Output style as 'rofi', 'table', or 'tab'"
}

validate_arguments() {
    validate_type_argument
    validate_style_argument
}

validate_type_argument() {
    if [[ "$KEY_BINDINGS_TYPE" != "hyprland" && "$KEY_BINDINGS_TYPE" != "zsh" ]]; then
        echo "Error: Invalid type '$KEY_BINDINGS_TYPE'"
        show_usage
        exit 1
    fi
}

validate_style_argument() {
    if [[ "$KEY_BINDINGS_STYLE" != "rofi" && "$KEY_BINDINGS_STYLE" != "table" && "$KEY_BINDINGS_STYLE" != "tab" ]]; then
        echo "Error: Invalid style '$KEY_BINDINGS_STYLE'"
        show_usage
        exit 1
    fi
}

get_key_bindings_list() {
    if [[ "$KEY_BINDINGS_STYLE" == "rofi" ]]; then
        python3 "$APP_SCRIPTS_DIR/key-bindings.py" "$KEY_BINDINGS_TYPE" "$KEY_BINDINGS_STYLE" | rofi -dmenu -i -config "$KEY_BINDINGS_STYLE_FILE"
    else
        python3 "$APP_SCRIPTS_DIR/key-bindings.py" "$KEY_BINDINGS_TYPE" "$KEY_BINDINGS_STYLE"
    fi
}

main "$@"
