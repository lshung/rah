#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Kitty configuration..."

    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    copy_config_files || { log_failed "Failed to copy config files."; return 1; }
    edit_kitty_config || { log_failed "Failed to edit Kitty configuration."; return 1; }

    log_ok "Kitty configuration updated successfully."
}

prepare_before_update() {
    log_info "Preparing before update..."

    rm -rf "$KITTY_CONFIG_DIR"
    mkdir -p "$KITTY_CONFIG_DIR"
    mkdir -p "$KITTY_CONFIG_COLORS_DIR"
}

copy_config_files() {
    log_info "Copying config files..."

    cp "$APP_CONFIGS_KITTY_DIR/kitty.conf" "$KITTY_CONFIG_FILE"
    cp "$APP_CONFIGS_KITTY_DIR/colors/$THEME_NAME-$THEME_FLAVOR.conf" "$KITTY_CONFIG_COLORS_DIR"/
}

edit_kitty_config() {
    log_info "Editing Kitty configuration..."

    sed -i "s/@@theme@@/$THEME_NAME/g" "$KITTY_CONFIG_FILE"
    sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$KITTY_CONFIG_FILE"
}

main
