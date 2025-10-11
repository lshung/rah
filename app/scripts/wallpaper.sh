#!/bin/bash

# Change wallpaper using swww

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    declare_variables
    parse_arguments "$@"
    start_swww_daemon_if_not_running
    get_wallpaper_file_path
    change_wallpaper
    cache_wallpaper
}

declare_variables() {
    WALLPAPER_FILE=""
    PRELOAD="no"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -p|--preload)
                PRELOAD="yes"
                ;;
            -f|--file)
                current_arg="$1"
                shift
                WALLPAPER_FILE="${1:-}"
                [[ -z "$WALLPAPER_FILE" ]] && { echo "Error: Option $current_arg requires a file path"; show_usage; exit 1; }
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
    echo "Usage: $APP_NAME_LOWER $ACTION wallpaper [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                 Show help"
    echo "  -p, --preload              Preload wallpaper without transition"
    echo "  -f, --file FILE            Specify wallpaper file path"
}

start_swww_daemon_if_not_running() {
    if ! pgrep -x "swww-daemon" >/dev/null; then
        echo "Starting swww-daemon..."
        swww-daemon &
        sleep 1  # Wait a bit for daemon to start
    fi
}

get_wallpaper_file_path() {
    if [[ -n "$WALLPAPER_FILE" ]]; then
        util_wallpaper_validate_wallpaper_file "$WALLPAPER_FILE" || return 1
    else
        util_wallpaper_validate_wallpapers_dir || return 1
        WALLPAPER_FILE="$(util_wallpaper_get_random_wallpaper)"
    fi
}

change_wallpaper() {
    if [ "$PRELOAD" = "yes" ]; then
        # Set wallpaper without transition (preload)
        swww img "$WALLPAPER_FILE" --transition-type none &
        echo "Preloaded wallpaper: $(basename "$WALLPAPER_FILE")"
    else
        # Set wallpaper using swww with random transition
        swww img "$WALLPAPER_FILE" \
            --transition-type "$SWWW_TRANSITION_TYPE" \
            --transition-bezier "$SWWW_TRANSITION_BEZIER" \
            --transition-duration "$SWWW_TRANSITION_DURATION" \
            --transition-fps "$SWWW_TRANSITION_FPS" &
        echo "Changed wallpaper to: $(basename "$WALLPAPER_FILE")"
    fi
}

cache_wallpaper() {
    mkdir -p "$CACHE_WALLPAPERS_DIR"
    detect_screen_resolution

    # Convert wallpaper to blur and save to cache
    ffmpeg -i "$WALLPAPER_FILE" \
        -vf "scale=w=${RESOLUTION_WIDTH}:h=${RESOLUTION_HEIGHT}:force_original_aspect_ratio=increase:flags=lanczos,crop=${RESOLUTION_WIDTH}:${RESOLUTION_HEIGHT},gblur=sigma=$WALLPAPER_BLUR_SIGMA,eq=brightness=$WALLPAPER_BLUR_BRIGHTNESS:contrast=$WALLPAPER_BLUR_CONTRAST" \
        -frames:v 1 \
        -update 1 \
        "$CACHE_WALLPAPERS_DIR/blur.jpg" \
        -y >/dev/null 2>&1

    # Copy original wallpaper to cache
    ffmpeg -i "$WALLPAPER_FILE" \
        -vf "scale=w=${RESOLUTION_WIDTH}:h=${RESOLUTION_HEIGHT}:force_original_aspect_ratio=increase:flags=lanczos,crop=${RESOLUTION_WIDTH}:${RESOLUTION_HEIGHT}" \
        -frames:v 1 \
        -update 1 \
        "$CACHE_WALLPAPERS_DIR/original.jpg" \
        -y >/dev/null 2>&1

    # Crop wallpaper to square format
    ffmpeg -i "$WALLPAPER_FILE" \
        -vf "scale=w=${RESOLUTION_WIDTH}:h=${RESOLUTION_HEIGHT}:force_original_aspect_ratio=increase:flags=lanczos,crop=${RESOLUTION_HEIGHT}:${RESOLUTION_HEIGHT}" \
        -frames:v 1 \
        -update 1 \
        "$CACHE_WALLPAPERS_DIR/square.jpg" \
        -y >/dev/null 2>&1
}

detect_screen_resolution() {
    # Try to get resolution from hyprctl
    RESOLUTION_WIDTH=$(hyprctl monitors -j | jq -r '.[] | "\(.width)"' 2>/dev/null)
    RESOLUTION_HEIGHT=$(hyprctl monitors -j | jq -r '.[] | "\(.height)"' 2>/dev/null)

    # Fallback: use default values
    if [ -z "$RESOLUTION_WIDTH" ] || [ -z "$RESOLUTION_HEIGHT" ]; then
        echo "Warning: Could not detect resolution, defaulting to ${DEFAULT_RESOLUTION_WIDTH}x${DEFAULT_RESOLUTION_HEIGHT}" 1>&2
        RESOLUTION_WIDTH="$DEFAULT_RESOLUTION_WIDTH"
        RESOLUTION_HEIGHT="$DEFAULT_RESOLUTION_HEIGHT"
    fi
}

main "$@"
