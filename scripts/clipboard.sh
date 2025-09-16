#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will get clipboard history and show on rofi menu

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

main() {
    declare_variables
    parse_arguments "$@"
    save_clipboard_history_into_temp_files
    show_clipboard_history_for_selection
    remove_temp_file
}

declare_variables() {
    CLIBOARD_HISTORY_TEMP_FILE=$(mktemp)
    CLIBOARD_HISTORY_ENCODED_TEMP_FILE=$(mktemp)
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
    echo "Usage: $APP_NAME_LOWER $ACTION clipboard [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                      Show help"
}

save_clipboard_history_into_temp_files() {
    cliphist list | while read -r index content; do
        local encoded_content=$(encode_base64 "$content")

        echo "$index|$content" >> "$CLIBOARD_HISTORY_TEMP_FILE"
        echo "$index|$encoded_content" >> "$CLIBOARD_HISTORY_ENCODED_TEMP_FILE"
    done
}

encode_base64() {
    local content="$1"
    echo -n "$content" | base64 -w 0
}

show_clipboard_history_for_selection() {
    sed 's/^[0-9]*|//' "$CLIBOARD_HISTORY_TEMP_FILE" \
        | rofi -dmenu -config "$CLIPBOARD_STYLE_FILE" -i \
        | while read -r selected; do
            copy_selected_entry_to_clipboard "$selected"
        done
}

copy_selected_entry_to_clipboard() {
    local selected="$1"
    local encoded_selected=$(encode_base64 "$selected")
    local matching_line=$(grep "^[0-9]*|$encoded_selected$" "$CLIBOARD_HISTORY_ENCODED_TEMP_FILE" | head -n 1)

    if [ -n "$matching_line" ]; then
        local index=$(echo "$matching_line" | cut -d'|' -f1)
        cliphist decode "$index" | wl-copy
    fi
}

remove_temp_file() {
    rm -f "$CLIBOARD_HISTORY_TEMP_FILE"
    rm -f "$CLIBOARD_HISTORY_ENCODED_TEMP_FILE"
}

# Call main function with arguments
main "$@"
