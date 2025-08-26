#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will select a wallpaper from a rofi menu

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
    get_wallpapers_list
    generate_thumbnail_for_all_wallpapers
    launch_rofi_menu_for_wallpaper_selection
}

declare_variables() {
    WALLPAPERS=()
    GENERATE_THUMBNAILS_MODE="no"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -g|--generate-thumbnails)
                GENERATE_THUMBNAILS_MODE="yes"
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
    echo "Usage: $APP_NAME_LOWER $ACTION wallpaper-selection [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                      Show help"
    echo "  -g, --generate-thumbnails       Generate thumbnails for all wallpapers"
}

get_wallpapers_list() {
    util_wallpaper_validate_wallpapers_dir || return 1
    WALLPAPERS=($(util_wallpaper_get_wallpapers_list))
}

generate_thumbnail_for_all_wallpapers() {
    mkdir -p "$CACHE_WALLPAPERS_THUMBNAILS_DIR"

    for file in "${WALLPAPERS[@]}"; do
        if [ ! -f "$CACHE_WALLPAPERS_THUMBNAILS_DIR/$(basename "$file")" ]; then
            generate_thumbnail_for_single_wallpaper "$file"
        fi
    done
}

generate_thumbnail_for_single_wallpaper() {
    local file="$1"
    local output_file="$CACHE_WALLPAPERS_THUMBNAILS_DIR/$(basename "$file")"

    echo "Generating thumbnail for $file"

    ffmpeg -i "$file" \
        -vf "scale=w=$WALLPAPER_SELECTION_THUMBNAIL_WIDTH:h=$WALLPAPER_SELECTION_THUMBNAIL_HEIGHT:force_original_aspect_ratio=increase:flags=lanczos,crop=$WALLPAPER_SELECTION_THUMBNAIL_WIDTH:$WALLPAPER_SELECTION_THUMBNAIL_HEIGHT" \
        -frames:v 1 \
        -update 1 \
        "$output_file" \
        -y >/dev/null 2>&1
}

launch_rofi_menu_for_wallpaper_selection() {
    if [ "$GENERATE_THUMBNAILS_MODE" == "no" ]; then
        # Show rofi menu and get selected file name
        local selected_file=$(build_rofi_entries | rofi -dmenu -i -config "$WALLPAPER_SELECTION_STYLE_FILE")

        # Change wallpaper if selected file is not empty
        if [ -n "$selected_file" ]; then
            echo "Selected file: $selected_file"
            rah -x wallpaper -f "$WALLPAPERS_DIR/$selected_file"
        fi
    fi
}

build_rofi_entries() {
    for file in "${WALLPAPERS[@]}"; do
        # Entry format: text\0icon\x1f/path
        printf "%s\0icon\x1f%s\n" "$(basename "$file")" "$CACHE_WALLPAPERS_THUMBNAILS_DIR/$(basename "$file")"
    done
}

# Call main function with arguments
main "$@"
