#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

main() {
    sudo -v

    echo "Updating SDDM configuration..."

    declare_variables
    prepare_themes_dir
    download_theme
    copy_wallpapers
    edit_theme_config
    set_current_theme
}

declare_variables() {
    SDDM_THEME_DIR="$SDDM_THEMES_DIR/$SDDM_THEME_NAME"
}

prepare_themes_dir() {
    echo "Preparing themes directory..."

    sudo mkdir -p "$SDDM_THEMES_DIR"
}

download_theme() {
    echo "Downloading theme '$SDDM_THEME_NAME'..."

    if [[ "$SDDM_THEME_NAME" == "sugar-candy" ]]; then
        download_theme_sugar_candy
    fi
}

download_theme_sugar_candy() {
    sudo rm -rf "$SDDM_THEME_DIR"
    sudo git clone "https://github.com/lshung/sddm-sugar-candy.git" "$SDDM_THEME_DIR" --quiet
    sudo rm -rf "$SDDM_THEME_DIR"/{.git,*.sh,README.md}
}

copy_wallpapers() {
    echo "Copying wallpapers for '$SDDM_THEME_NAME'..."

    if [[ "$SDDM_THEME_NAME" == "sugar-candy" ]]; then
        copy_wallpapers_for_sugar_candy
    fi
}

copy_wallpapers_for_sugar_candy() {
    sudo cp -r "$WALLPAPERS_DIR"/* "$SDDM_THEME_DIR/Backgrounds"
}

edit_theme_config() {
    echo "Editing theme config for '$SDDM_THEME_NAME'..."

    if [[ "$SDDM_THEME_NAME" == "sugar-candy" ]]; then
        edit_theme_config_for_sugar_candy
    fi
}

edit_theme_config_for_sugar_candy() {
    local theme_config_file="$SDDM_THEME_DIR/theme.conf"

    # Change wallpapers list
    local wallpapers_list=($(util_wallpaper_get_wallpapers_list "$SDDM_THEME_DIR/Backgrounds"))
    local joined_backgrounds
    printf -v joined_backgrounds '%s ' "${wallpapers_list[@]}"
    joined_backgrounds="${joined_backgrounds% }"
    sudo sed -i "s|^Backgrounds=\"[^\"]*\"|Backgrounds=\"$joined_backgrounds\"|" "$theme_config_file"

    # Change some colors
    sudo sed -i "s|^MainColor=\"[^\"]*\"|MainColor=\"$(util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "text")\"|" "$theme_config_file"
    sudo sed -i "s|^AccentColor=\"[^\"]*\"|AccentColor=\"$(util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$THEME_ACCENT")\"|" "$theme_config_file"
    sudo sed -i "s|^BackgroundColor=\"[^\"]*\"|BackgroundColor=\"$(util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "base")\"|" "$theme_config_file"
}

set_current_theme() {
    echo "Setting '$SDDM_THEME_NAME' as current theme..."

    echo "[Theme]" | sudo tee "$SDDM_CONFIG_FILE" >/dev/null
    echo "Current=$SDDM_THEME_NAME" | sudo tee -a "$SDDM_CONFIG_FILE" >/dev/null
}

# Call main function
main
