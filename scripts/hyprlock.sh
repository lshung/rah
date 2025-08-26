#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will launch hyprlock with custom configuration

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

main() {
    declare_variables
    parse_arguments "$@"
    validate_current_wallpaper
    resolve_wallpaper_by_type
    update_hyprlock_config
    launch_hyprlock
}

declare_variables() {
    WALLPAPER_TYPE="${HYPRLOCK_WALLPAPER:-current}"
    WALLPAPER_FILE="$(util_wallpaper_get_current_wallpaper)"
    IS_CURRENT_WALLPAPER_VALID="yes"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -w|--wallpaper)
                current_arg="$1"
                shift
                WALLPAPER_TYPE="${1:-}"
                [[ -z "$WALLPAPER_TYPE" ]] && { echo "Error: Option $current_arg requires a value"; show_usage; exit 1; }
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
    echo "Usage: $APP_NAME_LOWER $ACTION hyprlock [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                  Show help"
    echo "  -w, --wallpaper VALUE       Use 'current', 'random' or a valid image file path"
}

# Check if the current wallpaper is valid to be used for fallback
validate_current_wallpaper() {
    if ! util_wallpaper_validate_wallpaper_file "$WALLPAPER_FILE" >/dev/null 2>&1; then
        echo "Warning: Current wallpaper '$WALLPAPER_FILE' is invalid, can not be used for fallback" 1>&2
        IS_CURRENT_WALLPAPER_VALID="no"
    fi
}

resolve_wallpaper_by_type() {
    if [[ "$WALLPAPER_TYPE" == "current" ]]; then
        resolve_wallpaper_when_current
    elif [[ "$WALLPAPER_TYPE" == "random" ]]; then
        resolve_wallpaper_when_random
    else
        resolve_wallpaper_when_file_path
    fi
}

resolve_wallpaper_when_current() {
    if [[ "$IS_CURRENT_WALLPAPER_VALID" == "yes" ]]; then
        return 0
    else
        echo "Warning: Can not use current wallpaper, try to use random" 1>&2
        resolve_wallpaper_when_random
    fi
}

resolve_wallpaper_when_random() {
    if util_wallpaper_validate_wallpapers_dir; then
        WALLPAPER_FILE="$(util_wallpaper_get_random_wallpaper "$WALLPAPERS_DIR" "$HYPRLOCK_WALLPAPER_ALLOWED_EXTENSIONS")"
        return 0
    else
        if [[ "$IS_CURRENT_WALLPAPER_VALID" == "yes" ]]; then
            echo "Warning: Can not use random wallpaper, use current wallpaper instead" 1>&2
            return 0
        else
            echo "Error: Can not use either random or current wallpaper" 1>&2
            return 1
        fi
    fi
}

resolve_wallpaper_when_file_path() {
    if util_wallpaper_validate_wallpaper_file "$WALLPAPER_TYPE" >/dev/null 2>&1; then
        WALLPAPER_FILE="$WALLPAPER_TYPE"
        return 0
    else
        if [[ "$IS_CURRENT_WALLPAPER_VALID" == "yes" ]]; then
            echo "Warning: Invalid file path or unsupported file extension '$WALLPAPER_TYPE', use current wallpaper instead" 1>&2
            WALLPAPER_FILE="$WALLPAPER_FILE"
            return 0
        else
            echo "Error: Invalid file path or unsupported file extension '$WALLPAPER_TYPE'" 1>&2
            return 1
        fi
    fi
}

update_hyprlock_config() {
    if [[ ! -f "$HYPRLOCK_CONFIG_FILE" ]]; then
        echo "Error: Hyprlock config not found at '$HYPRLOCK_CONFIG_FILE'" 1>&2
        return 1
    fi

    # Escape / and & for sed replacement
    local escaped_path=$(printf '%s' "$WALLPAPER_FILE" | sed 's/[&\/]/\\&/g')
    # Replace the path line only within the background block
    sed -i "/^background {/,/^}/ s|^\s*path = .*|    path = $escaped_path|" "$HYPRLOCK_CONFIG_FILE"
    echo "Updated Hyprlock background path to '$WALLPAPER_FILE'"
}

launch_hyprlock() {
    if pidof hyprlock >/dev/null 2>&1; then
        killall hyprlock >/dev/null 2>&1
        sleep 0.5
    else
        hyprlock
    fi
}

# Call main function with arguments
main "$@"
