#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

util_wallpaper_validate_wallpaper_file() {
    local file_path="$1"

    _validate_wallpaper_file_exists "$file_path" || return 1
    _validate_wallpaper_file_extension "$file_path" || return 1
}

_validate_wallpaper_file_exists() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Wallpaper file '$file_path' does not exist."
        return 1
    fi
}

_validate_wallpaper_file_extension() {
    local file_path="$1"
    local file_extension=$(echo "$file_path" | rev | cut -d'.' -f1 | rev | tr '[:upper:]' '[:lower:]')

    if echo "$file_extension" | grep -qE "^($WALLPAPER_ALLOWED_EXTENSIONS)$"; then
        return 0
    fi

    log_error "File extension '$file_extension' is not allowed. Allowed extensions are $WALLPAPER_ALLOWED_EXTENSIONS."
    return 1
}

util_wallpaper_validate_wallpapers_dir() {
    _validate_wallpapers_dir_exists || return 1
    _validate_wallpapers_dir_has_image_files || return 1
}

_validate_wallpapers_dir_exists() {
    if [ ! -d "$WALLPAPERS_DIR" ]; then
        log_error "Wallpaper directory '$WALLPAPERS_DIR' does not exist."
        return 1
    fi
}

_validate_wallpapers_dir_has_image_files() {
    # Convert | to \| for regex pattern of find command
    local allowed_extensions="${WALLPAPER_ALLOWED_EXTENSIONS//|/\\|}"

    if ! find "$WALLPAPERS_DIR" -maxdepth 1 -type f -iregex ".*\.\($allowed_extensions\)" | grep -q .; then
        log_error "No image files with supported extensions found in '$WALLPAPERS_DIR'."
        return 1
    fi
}

util_wallpaper_get_random_wallpaper() {
    local wallpapers_dir=${1:-$WALLPAPERS_DIR}
    local allowed_extensions=${2:-$WALLPAPER_ALLOWED_EXTENSIONS}

    # Convert | to \| for regex pattern of find command
    local allowed_extensions="${allowed_extensions//|/\\|}"
    local wallpapers_list=($(find "$wallpapers_dir" -maxdepth 1 -type f -iregex ".*\.\($allowed_extensions\)"))
    local random_wallpaper_file=${wallpapers_list[$RANDOM % ${#wallpapers_list[@]}]}

    echo "$random_wallpaper_file"
}

util_wallpaper_get_wallpapers_list() {
    local wallpapers_dir=${1:-$WALLPAPERS_DIR}
    local allowed_extensions=${2:-$WALLPAPER_ALLOWED_EXTENSIONS}

    # Convert | to \| for regex pattern of find command
    local allowed_extensions="${allowed_extensions//|/\\|}"
    local wallpapers_list=($(find "$wallpapers_dir" -maxdepth 1 -type f -iregex ".*\.\($allowed_extensions\)"))

    echo "${wallpapers_list[@]}"
}

util_wallpaper_get_current_wallpaper() {
    echo "$CACHE_WALLPAPERS_DIR/original.jpg"
}
