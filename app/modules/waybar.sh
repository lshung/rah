#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Waybar configuration..."

    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    copy_config_files || { log_failed "Failed to copy config files."; return 1; }
    edit_style_css_file || { log_failed "Failed to edit style.css file."; return 1; }
    reload_waybar || { log_failed "Failed to reload Waybar."; return 1; }

    log_ok "Waybar configuration updated successfully."
}

prepare_before_update() {
    log_info "Preparing before update..."

    rm -rf "$WAYBAR_CONFIG_DIR"
    mkdir -p "$WAYBAR_CONFIG_DIR"
    mkdir -p "$WAYBAR_CONFIG_DIR"/colors
}

copy_config_files() {
    log_info "Copying config files..."

    cp "$APP_CONFIGS_WAYBAR_DIR/config.jsonc" "$WAYBAR_CONFIG_DIR"/config.jsonc
    cp "$APP_CONFIGS_WAYBAR_DIR/style.css" "$WAYBAR_CONFIG_DIR"/style.css
    cp "$APP_CONFIGS_WAYBAR_DIR/colors/$THEME_NAME-$THEME_FLAVOR.css" "$WAYBAR_CONFIG_DIR"/colors/
}

edit_style_css_file() {
    log_info "Editing style.css file..."

    sed -i "s/@@theme@@/$THEME_NAME/g" "$WAYBAR_CONFIG_DIR"/style.css
    sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$WAYBAR_CONFIG_DIR"/style.css
    sed -i "s/@@accent@@/$THEME_ACCENT/g" "$WAYBAR_CONFIG_DIR"/style.css
}

reload_waybar() {
    log_info "Reloading Waybar..."

    killall waybar >/dev/null 2>&1 || true
    waybar >/dev/null 2>&1 &
}

main
