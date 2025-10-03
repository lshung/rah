#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Nwg-look configuration..."

    declare_variables || { log_failed "Failed to declare variables."; return 1; }
    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    install_catppuccin_theme || { log_failed "Failed to install Catppuccin theme."; return 1; }
    create_gsettings_file || { log_failed "Failed to create gsettings file."; return 1; }
    reload_nwg_look || { log_failed "Failed to reload Nwg-look."; return 1; }

    log_ok "Nwg-look configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    THEMES_DIR="$HOME/.local/share/themes"
    THEME_FULL_NAME="${THEME_NAME}-${THEME_FLAVOR}-${THEME_ACCENT}"
    THEME_DIR="$THEMES_DIR/${THEME_FULL_NAME}"
    GSETTINGS_FILE="$HOME/.local/share/nwg-look/gsettings"
}

prepare_before_update() {
    log_info "Preparing before update..."

    mkdir -p "$THEMES_DIR"
    rm -rf "$THEMES_DIR/${THEME_FULL_NAME}"*
    mkdir -p "$(dirname "$GSETTINGS_FILE")"
}

install_catppuccin_theme() {
    log_info "Installing Catppuccin theme..."

    local base_url="https://github.com/catppuccin/gtk/releases/latest/download"
    local output_file_name="${THEME_FULL_NAME}-standard+default.zip"
    local output_dir_name="${THEME_FULL_NAME}-standard+default"
    local download_url="${base_url}/$output_file_name"
    local output_file="$THEMES_DIR/$output_file_name"

    util_download_with_retry "$download_url" "$output_file" || return 1

    # Unzip and remove the zip file
    unzip -q "$output_file" -d "$THEMES_DIR"
    rm -f "$output_file"

    # Rename theme directory (remove suffix '-standard+default')
    mv "$THEMES_DIR/$output_dir_name" "$THEME_DIR"

    # Add support for libadwaita
    mkdir -p "${HOME}/.config/gtk-4.0"
    ln -sf "${THEME_DIR}/gtk-4.0/assets" "${HOME}/.config/gtk-4.0/assets"
    ln -sf "${THEME_DIR}/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css"
    ln -sf "${THEME_DIR}/gtk-4.0/gtk-dark.css" "${HOME}/.config/gtk-4.0/gtk-dark.css"
}

create_gsettings_file() {
    log_info "Creating gsettings file..."

    cp "$APP_CONFIGS_NWG_LOOK_DIR/gsettings" "$GSETTINGS_FILE"
    sed -i "s/@@theme_full_name@@/$THEME_FULL_NAME/g" "$GSETTINGS_FILE"
}

reload_nwg_look() {
    log_info "Reloading Nwg-look..."

    nwg-look -a >/dev/null 2>&1
}

main
