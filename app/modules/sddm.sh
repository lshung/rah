#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating SDDM configuration..."

    sudo -v
    declare_variables || { log_failed "Failed to declare variables."; return 1; }
    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    download_theme || { log_failed "Failed to download theme."; return 1; }
    copy_wallpapers || { log_failed "Failed to copy wallpapers."; return 1; }
    edit_theme_config || { log_failed "Failed to edit theme config."; return 1; }
    set_current_theme || { log_failed "Failed to set current theme."; return 1; }

    log_ok "SDDM configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    SDDM_THEME_DIR="$SDDM_THEMES_DIR/$SDDM_THEME_NAME"
}

prepare_before_update() {
    log_info "Preparing before update..."

    sudo rm -rf "$SDDM_THEME_DIR"
    sudo mkdir -p "$SDDM_THEMES_DIR"
}

download_theme() {
    log_info "Downloading theme '$SDDM_THEME_NAME'..."

    if [[ "$SDDM_THEME_NAME" == "sugar-candy" ]]; then
        download_theme_sugar_candy
    fi
}

download_theme_sugar_candy() {
    sudo git clone "https://github.com/lshung/sddm-sugar-candy.git" "$SDDM_THEME_DIR" --quiet
    sudo rm -rf "$SDDM_THEME_DIR"/{.git,*.sh,README.md}
}

copy_wallpapers() {
    log_info "Copying wallpapers for the theme..."

    if [[ "$SDDM_THEME_NAME" == "sugar-candy" ]]; then
        copy_wallpapers_for_sugar_candy
    fi
}

copy_wallpapers_for_sugar_candy() {
    sudo cp -r "$WALLPAPERS_DIR"/* "$SDDM_THEME_DIR/Backgrounds"
}

edit_theme_config() {
    log_info "Editing theme config..."

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
    log_info "Setting '$SDDM_THEME_NAME' as current theme..."

    echo "[Theme]" | sudo tee "$SDDM_CONFIG_FILE" >/dev/null
    echo "Current=$SDDM_THEME_NAME" | sudo tee -a "$SDDM_CONFIG_FILE" >/dev/null
}

main
