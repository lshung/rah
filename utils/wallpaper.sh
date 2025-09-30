#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

# Function to validate wallpaper file
util_wallpaper_validate_wallpaper_file() {
    local file_path="$1"

    _validate_wallpaper_file_exists "$file_path" || return 1
    _validate_wallpaper_file_extension "$file_path" || return 1
}

# Private function to validate wallpaper file exists
_validate_wallpaper_file_exists() {
    local file_path="$1"

    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        echo "Error: Wallpaper file '$file_path' does not exist"
        return 1
    fi
}

# Private function to validate wallpaper file extension
_validate_wallpaper_file_extension() {
    local file_path="$1"
    local file_extension=$(echo "$file_path" | rev | cut -d'.' -f1 | rev | tr '[:upper:]' '[:lower:]')

    if echo "$file_extension" | grep -qE "^($WALLPAPER_ALLOWED_EXTENSIONS)$"; then
        return 0
    fi

    echo "Error: File extension '$file_extension' not allowed. Allowed extensions: $WALLPAPER_ALLOWED_EXTENSIONS"
    return 1
}

# Function to validate wallpapers directory
util_wallpaper_validate_wallpapers_dir() {
    _validate_wallpapers_dir_exists || return 1
    _validate_wallpapers_dir_has_image_files || return 1
}

# Private function to validate wallpaper directory exists
_validate_wallpapers_dir_exists() {
    if [ ! -d "$WALLPAPERS_DIR" ]; then
        echo "Error: Wallpaper directory $WALLPAPERS_DIR does not exist!"
        return 1
    fi
}

# Private function to validate wallpaper directory has image files
_validate_wallpapers_dir_has_image_files() {
    # Convert | to \| for regex pattern of find command
    local allowed_extensions="${WALLPAPER_ALLOWED_EXTENSIONS//|/\\|}"

    if ! find "$WALLPAPERS_DIR" -maxdepth 1 -type f -iregex ".*\.\($allowed_extensions\)" | grep -q .; then
        echo "Error: No image files with supported extensions found in $WALLPAPERS_DIR"
        return 1
    fi
}

# Function to get a random wallpaper
util_wallpaper_get_random_wallpaper() {
    local wallpapers_dir=${1:-$WALLPAPERS_DIR}
    local allowed_extensions=${2:-$WALLPAPER_ALLOWED_EXTENSIONS}

    # Convert | to \| for regex pattern of find command
    local allowed_extensions="${allowed_extensions//|/\\|}"
    # Get list of wallpapers with supported extensions using find command
    local wallpapers_list=($(find "$wallpapers_dir" -maxdepth 1 -type f -iregex ".*\.\($allowed_extensions\)"))
    # Get random wallpaper from list
    local wallpaper_file=${wallpapers_list[$RANDOM % ${#wallpapers_list[@]}]}
    # Print wallpaper file path
    echo "$wallpaper_file"
}

util_wallpaper_get_wallpapers_list() {
    local wallpapers_dir=${1:-$WALLPAPERS_DIR}
    local allowed_extensions=${2:-$WALLPAPER_ALLOWED_EXTENSIONS}

    # Convert | to \| for regex pattern of find command
    local allowed_extensions="${allowed_extensions//|/\\|}"
    # Get list of wallpapers with supported extensions using find command
    local wallpapers_list=($(find "$wallpapers_dir" -maxdepth 1 -type f -iregex ".*\.\($allowed_extensions\)"))
    # Print file paths
    echo "${wallpapers_list[@]}"
}

# Function to get the current wallpaper
util_wallpaper_get_current_wallpaper() {
    # Print current wallpaper file path
    echo "$CACHE_WALLPAPERS_DIR/original.jpg"
}
