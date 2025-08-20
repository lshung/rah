#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will change wallpaper using swww

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Default variables
WALLPAPER_FILE=""
ALLOWED_EXTENSIONS=("jpg" "jpeg" "png" "bmp" "gif" "webp")
PRELOAD="no"
TRANSITION_TYPE="any"
TRANSITION_BEZIER="0.43,1.19,1,0.4"
TRANSITION_DURATION=0.5
TRANSITION_FPS=60
BLUR_SIGMA=20
BRIGHTNESS=-0.1
CONTRAST=1.05
RESOLUTION_WIDTH=1920
RESOLUTION_HEIGHT=1080

# Function to show usage
show_usage() {
    echo "Usage: $APP_NAME_LOWER $ACTION wallpaper [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h                 Show help"
    echo "  --preload                  Preload wallpaper without transition"
    echo "  -f, --file FILE            Specify wallpaper file path"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_usage
                return 0
                ;;
            --preload)
                PRELOAD="yes"
                ;;
            -f|--file)
                current_arg="$1"
                shift
                [[ -z "$1" ]] && { echo "Error: Option $current_arg requires a file path"; show_usage; return 1; }
                WALLPAPER_FILE="$1"
                ;;
            *)
                echo "Error: Invalid option '$1'"
                show_usage
                return 1
                ;;
        esac
        shift
    done
}

# Function to check and start swww daemon if not running
start_swww_daemon_if_not_running() {
    if ! pgrep -x "swww-daemon" > /dev/null; then
        echo "Starting swww-daemon..."
        swww-daemon &
        sleep 1  # Wait a bit for daemon to start
    fi
}

# Function to validate wallpaper file
validate_wallpaper_file() {
    local file_path="$1"

    validate_wallpaper_file_exists "$file_path" || return 1
    validate_wallpaper_file_extension "$file_path" || return 1
}

# Function to validate wallpaper file exists
validate_wallpaper_file_exists() {
    local file_path="$1"

    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        echo "Error: Wallpaper file '$file_path' does not exist"
        return 1
    fi
}

# Function to validate wallpaper file extension
validate_wallpaper_file_extension() {
    local file_path="$1"
    local file_extension=$(echo "$file_path" | rev | cut -d'.' -f1 | rev | tr '[:upper:]' '[:lower:]')

    for ext in "${ALLOWED_EXTENSIONS[@]}"; do
        if [[ "$file_extension" == "$ext" ]]; then
            return 0
        fi
    done

    echo "Error: File extension '$file_extension' not allowed. Allowed extensions: ${ALLOWED_EXTENSIONS[@]}"
    return 1
}

# Function to validate wallpaper directory
validate_wallpaper_dir() {
    if [ ! -d "$WALLPAPERS_DIR" ]; then
        echo "Wallpaper directory $WALLPAPERS_DIR does not exist!"
        return 1
    fi
}

# Function to get random wallpaper
get_random_wallpaper() {
    local find_args=$(build_find_command_to_find_wallpapers)

    # Get list of image files using the built command array
    local wallpapers=($(find $find_args))

    # Check if any wallpapers were found
    if [ ${#wallpapers[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPERS_DIR"
        return 1
    fi

    # Select random wallpaper and set global variable for other functions
    WALLPAPER_FILE="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"
}

# Function to build find command for finding wallpapers
build_find_command_to_find_wallpapers() {
    # Build find command array from allowed extensions
    local find_args=("$WALLPAPERS_DIR" "-type" "f")

    for ext in "${ALLOWED_EXTENSIONS[@]}"; do
        find_args+=("-o" "-iname" "*.$ext")
    done

    # Remove the first "-o" since it's not needed for the first condition
    if [[ ${#find_args[@]} -gt 3 ]]; then
        find_args=("${find_args[@]:0:3}" "${find_args[@]:4}")
    fi

    echo "${find_args[@]}"
}

# Function to change wallpaper
change_wallpaper() {
    if [ "$PRELOAD" = "yes" ]; then
        # Set wallpaper without transition (preload)
        swww img "$WALLPAPER_FILE" --transition-type none &
        echo "Preloaded wallpaper: $(basename "$WALLPAPER_FILE")"
    else
        # Set wallpaper using swww with random transition
        swww img "$WALLPAPER_FILE" \
            --transition-type "$TRANSITION_TYPE" \
            --transition-bezier "$TRANSITION_BEZIER" \
            --transition-duration "$TRANSITION_DURATION" \
            --transition-fps "$TRANSITION_FPS" &
        echo "Changed wallpaper to: $(basename "$WALLPAPER_FILE")"
    fi
}

# Function to cache wallpaper files
cache_wallpaper() {
    # Create cache directory if it doesn't exist
    mkdir -p "$CACHE_WALLPAPERS_DIR"

    # Detect resolution
    detect_resolution

    # Convert wallpaper to blur and save to cache
    ffmpeg -i "$WALLPAPER_FILE" \
        -vf "scale=w=${RESOLUTION_WIDTH}:h=${RESOLUTION_HEIGHT}:force_original_aspect_ratio=increase:flags=lanczos,crop=${RESOLUTION_WIDTH}:${RESOLUTION_HEIGHT},gblur=sigma=$BLUR_SIGMA,eq=brightness=$BRIGHTNESS:contrast=$CONTRAST" \
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

# Function to detect screen resolution
detect_resolution() {
    # Try to get resolution from hyprctl
    local resolution=$(hyprctl monitors -j | jq -r '.[] | "\(.width)x\(.height)"' 2>/dev/null)

    # Fallback: use default values
    if [ -z "$resolution" ] || [ "$resolution" = "null" ]; then
        echo "Warning: Could not detect resolution, defaulting to ${RESOLUTION_WIDTH}x${RESOLUTION_HEIGHT}"
    else
        # Get width and height from detected resolution and update global resolution variables
        RESOLUTION_WIDTH=$(echo "$resolution" | cut -d'x' -f1)
        RESOLUTION_HEIGHT=$(echo "$resolution" | cut -d'x' -f2)
    fi
}

# Main function
main() {
    parse_arguments "$@"
    start_swww_daemon_if_not_running

    if [[ -n "$WALLPAPER_FILE" ]]; then
        # Use specified file
        validate_wallpaper_file "$WALLPAPER_FILE" || return 1
    else
        # Use random wallpaper from directory
        validate_wallpaper_dir || return 1
        get_random_wallpaper || return 1
    fi

    change_wallpaper
    cache_wallpaper
}

# Call main function with arguments
main "$@"
