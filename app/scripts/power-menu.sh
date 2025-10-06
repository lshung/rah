#!/bin/bash

# Show power menu as rofi or wlogout, allow to specify the style

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    declare_variables
    parse_arguments "$@"
    validate_arguments
    show_power_menu
}

declare_variables() {
    POWER_MENU_TYPE="$POWER_MENU_APP"

    if [[ "$POWER_MENU_TYPE" == "rofi" ]]; then
        POWER_MENU_STYLE="$POWER_MENU_ROFI_STYLE"
    elif [[ "$POWER_MENU_TYPE" == "wlogout" ]]; then
        POWER_MENU_STYLE="$POWER_MENU_WLOGOUT_STYLE"
    fi
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
                POWER_MENU_TYPE="${1:-}"
                [[ -z "$POWER_MENU_TYPE" ]] && { log_error "Option '$current_arg' requires a type value." "$LOG_SCRIPT_ENABLED"; show_usage; exit 1; }
                ;;
            -s|--style)
                current_arg="$1"
                shift
                POWER_MENU_STYLE="${1:-}"
                [[ -z "$POWER_MENU_STYLE" ]] && { log_error "Option '$current_arg' requires a style value." "$LOG_SCRIPT_ENABLED"; show_usage; exit 1; }
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
    echo "Usage: $APP_NAME_LOWER $ACTION power-menu [OPTIONS]"
    echo ""
    echo "Options:"
    echo "    -h, --help            Show help"
    echo "    -t, --type VALUE      Menu type as 'rofi' or 'wlogout'"
    echo "    -s, --style VALUE     Output style as 'rofi', 'table', or 'tab'"
}

validate_arguments() {
    validate_type_argument
    validate_style_argument
}

validate_type_argument() {
    if [[ "$POWER_MENU_TYPE" != "rofi" && "$POWER_MENU_TYPE" != "wlogout" ]]; then
        log_error "Invalid type '$POWER_MENU_TYPE'." "$LOG_SCRIPT_ENABLED"
        show_usage
        return 1
    fi
}

validate_style_argument() {
    if [[ -z "$POWER_MENU_STYLE" ]]; then
        log_error "Style is required." "$LOG_SCRIPT_ENABLED"
        show_usage
        return 1
    fi

    if [[ "$POWER_MENU_TYPE" == "rofi" ]] && [[ ! -f "$ROFI_CONFIG_STYLES_DIR/$POWER_MENU_STYLE.rasi" ]]; then
        log_error "Invalid rofi style '$POWER_MENU_STYLE'." "$LOG_SCRIPT_ENABLED"
        show_usage
        return 1
    fi

    if [[ "$POWER_MENU_TYPE" == "wlogout" ]] && [[ ! -d "$WLOGOUT_CONFIG_DIR/styles/$POWER_MENU_STYLE" ]]; then
        log_error "Invalid wlogout style '$POWER_MENU_STYLE'." "$LOG_SCRIPT_ENABLED"
        show_usage
        return 1
    fi
}

show_power_menu() {
    if [[ "$POWER_MENU_TYPE" == "rofi" ]]; then
        show_power_menu_with_rofi
    elif [[ "$POWER_MENU_TYPE" == "wlogout" ]]; then
        show_power_menu_with_wlogout
    fi
}

show_power_menu_with_rofi() {
    local selected=$(build_rofi_entries | rofi -dmenu -i -config "$ROFI_CONFIG_STYLES_DIR/$POWER_MENU_STYLE.rasi")

    case "$selected" in
        "Lock") $POWER_MENU_LOCK_CMD ;;
        "Logout") $POWER_MENU_LOGOUT_CMD ;;
        "Suspend") $POWER_MENU_SUSPEND_CMD ;;
        "Hibernate") $POWER_MENU_HIBERNATE_CMD ;;
        "Shutdown") $POWER_MENU_SHUTDOWN_CMD ;;
        "Reboot") $POWER_MENU_REBOOT_CMD ;;
    esac
}

build_rofi_entries() {
    printf "%s\0icon\x1f%s\n" "Lock" "system-lock-screen"
    printf "%s\0icon\x1f%s\n" "Logout" "system-log-out"
    printf "%s\0icon\x1f%s\n" "Suspend" "system-suspend"
    printf "%s\0icon\x1f%s\n" "Hibernate" "system-hibernate"
    printf "%s\0icon\x1f%s\n" "Shutdown" "system-shutdown"
    printf "%s\0icon\x1f%s\n" "Reboot" "system-reboot"
}

show_power_menu_with_wlogout() {
    $APP_NAME_LOWER -x wlogout
}

main "$@"
