#!/bin/bash

# Launch wlogout with specified style

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    declare_variables
    parse_arguments "$@"
    validate_style_argument
    copy_config_of_style
    source_config_of_style
    create_power_menu_icons_if_needed
    launch_wlogout
}

declare_variables() {
    STYLE="$POWER_MENU_WLOGOUT_STYLE"
    BUTTONS=("lock" "logout" "suspend" "hibernate" "shutdown" "reboot")
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
                [[ -z "$STYLE" ]] && { log_error "Option '$current_arg' requires a style value." "$LOG_SCRIPT_ENABLED"; show_usage; exit 1; }
                ;;
            *)
                log_error "Invalid option '$1'." "$LOG_SCRIPT_ENABLED"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION wlogout [--style STYLE|-s STYLE]"
    echo ""
    echo "Options:"
    echo "    -h, --help            Show help"
    echo "    -s, --style STYLE     Wlogout style name under \$HOME/.config/wlogout/styles"
}

validate_style_argument() {
    if [[ -z "$STYLE" ]]; then
        log_error "Style is required." "$LOG_SCRIPT_ENABLED"
        show_usage
        return 1
    fi

    if [[ ! -d "$WLOGOUT_CONFIG_DIR/styles/$STYLE" ]]; then
        log_error "Wlogout style '$STYLE' not found." "$LOG_SCRIPT_ENABLED"
        show_usage
        return 1
    fi
}

copy_config_of_style() {
    local style_dir="$WLOGOUT_CONFIG_DIR/styles/$STYLE"

    if [[ ! -f "$WLOGOUT_CONFIG_DIR/config" ]] || ! cmp -s "$style_dir/config" "$WLOGOUT_CONFIG_DIR/config"; then
        cp "$style_dir/config" "$WLOGOUT_CONFIG_DIR"/
    fi

    if [[ ! -f "$WLOGOUT_CONFIG_DIR/layout" ]] || ! cmp -s "$style_dir/layout" "$WLOGOUT_CONFIG_DIR/layout"; then
        cp "$style_dir/layout" "$WLOGOUT_CONFIG_DIR"/
    fi

    if [[ ! -f "$WLOGOUT_CONFIG_DIR/style.css" ]] || ! cmp -s "$style_dir/style.css" "$WLOGOUT_CONFIG_DIR/style.css"; then
        cp "$style_dir/style.css" "$WLOGOUT_CONFIG_DIR"/
    fi
}

source_config_of_style() {
    source "$WLOGOUT_CONFIG_DIR/config"
}

create_power_menu_icons_if_needed() {
    local button_colors=("$WLOGOUT_BUTTON_COLOR" "$WLOGOUT_BUTTON_HOVER_COLOR")

    for color in "${button_colors[@]}"; do
        for button in "${BUTTONS[@]}"; do
            if ! util_check_if_power_menu_icon_exists "$button" "$color"; then
                util_create_power_menu_icon "$button" "$color"
            fi
        done
    done
}

launch_wlogout() {
    wlogout -b "$WLOGOUT_BUTTONS_PER_ROW" \
        -r "$WLOGOUT_ROW_SPACING" \
        -c "$WLOGOUT_COLUMN_SPACING" \
        --protocol layer-shell
}

main "$@"
