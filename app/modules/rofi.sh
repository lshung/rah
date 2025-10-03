#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Rofi configuration..."

    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    copy_config_files || { log_failed "Failed to copy config files."; return 1; }
    edit_rasi_files || { log_failed "Failed to edit rasi files."; return 1; }

    log_ok "Rofi configuration updated successfully."
}

prepare_before_update() {
    log_info "Preparing before update..."

    rm -rf "$ROFI_CONFIG_DIR"
    mkdir -p "$ROFI_CONFIG_DIR"
    mkdir -p "$ROFI_CONFIG_STYLES_DIR"
    mkdir -p "$ROFI_CONFIG_COLORS_DIR"
}

copy_config_files() {
    log_info "Copying config files..."

    cp "$APP_CONFIGS_ROFI_DIR/styles/$ROFI_STYLE.rasi" "$ROFI_CONFIG_DIR"/config.rasi
    cp "$APP_CONFIGS_ROFI_DIR/styles"/*.rasi "$ROFI_CONFIG_STYLES_DIR"/
    cp "$APP_CONFIGS_ROFI_DIR/colors/$THEME_NAME-$THEME_FLAVOR.rasi" "$ROFI_CONFIG_COLORS_DIR"/
}

edit_rasi_files() {
    log_info "Editing rasi files..."

    for file in "$ROFI_CONFIG_DIR"/config.rasi "$ROFI_CONFIG_STYLES_DIR"/*.rasi; do
        sed -i "s/@@theme@@/$THEME_NAME/g" "$file"
        sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$file"
        sed -i "s/@@accent@@/$THEME_ACCENT/g" "$file"
    done
}

main
