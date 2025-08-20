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

# Default variables
WALLPAPERS=()
ALLOWED_EXTENSIONS=("jpg" "jpeg" "png" "bmp" "gif" "webp")
CONFIG_FILE="$HOME/.config/rofi/styles/style-wallpapers.rasi"
THUMBNAIL_WIDTH=400
THUMBNAIL_HEIGHT=400
GENERATE_THUMBNAILS_MODE="no"

# Function to show usage
show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION wallpaper-selection [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h                 Show help"
    echo "  --generate-thumbnails      Generate thumbnails for all wallpapers"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --generate-thumbnails)
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

# Function to get list of wallpapers
get_wallpapers_list() {
    local find_args=$(build_find_command_to_find_wallpapers)

    # Get list of image files using the built command array
    WALLPAPERS=($(find $find_args))

    # Check if any wallpapers were found
    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPERS_DIR"
        return 1
    fi
}

# Function to build find command for finding wallpapers
build_find_command_to_find_wallpapers() {
    # Build find command array from allowed extensions
    local find_args=("$WALLPAPERS_DIR" "-maxdepth" "1" "-type" "f")

    for ext in "${ALLOWED_EXTENSIONS[@]}"; do
        find_args+=("-o" "-iname" "*.$ext")
    done

    # Remove the first "-o" since it's not needed for the first condition
    if [[ ${#find_args[@]} -gt 5 ]]; then
        find_args=("${find_args[@]:0:5}" "${find_args[@]:6}")
    fi

    echo "${find_args[@]}"
}

# Function to generate all thumbnails
generate_all_thumbnails() {
    mkdir -p "$CACHE_WALLPAPERS_THUMBNAILS_DIR"

    for file in "${WALLPAPERS[@]}"; do
        if [ ! -f "$CACHE_WALLPAPERS_THUMBNAILS_DIR/$(basename "$file")" ]; then
            generate_thumbnail_for_an_image "$file"
        fi
    done
}

# Function to generate thumbnail for an image file
generate_thumbnail_for_an_image() {
    local file="$1"
    local output_file="$CACHE_WALLPAPERS_THUMBNAILS_DIR/$(basename "$file")"

    echo "Generating thumbnail for $file"

    ffmpeg -i "$file" \
        -vf "scale=w=$THUMBNAIL_WIDTH:h=$THUMBNAIL_HEIGHT:force_original_aspect_ratio=increase:flags=lanczos,crop=$THUMBNAIL_WIDTH:$THUMBNAIL_HEIGHT" \
        -frames:v 1 \
        -update 1 \
        "$output_file" \
        -y >/dev/null 2>&1
}

# Build rofi entries for rofi menu
build_rofi_entries() {
    for file in "${WALLPAPERS[@]}"; do
        # Entry format: text\0icon\x1f/path
        printf "%s\0icon\x1f%s\n" "$(basename "$file")" "$CACHE_WALLPAPERS_THUMBNAILS_DIR/$(basename "$file")"
    done
}

# Main function
main() {
    parse_arguments "$@"

    # Get list of wallpapers
    get_wallpapers_list || return 1

    # Generate thumbnails
    generate_all_thumbnails

    if [ "$GENERATE_THUMBNAILS_MODE" == "no" ]; then
        # Show rofi menu and get selected file name
        local selected_file=$(build_rofi_entries | rofi -dmenu -i -config "$CONFIG_FILE")

        # Change wallpaper if selected file is not empty
        if [ -n "$selected_file" ]; then
            echo "Selected file: $selected_file"
            rah -x wallpaper -f "$WALLPAPERS_DIR/$selected_file"
        fi
    fi
}

# Call main function with arguments
main "$@"
