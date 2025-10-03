#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Kvantum configuration..."

    declare_variables || { log_failed "Failed to declare variables."; return 1; }
    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    download_svg_and_kvconfig_files || { log_failed "Failed to download theme's SVG and KVConfig files."; return 1; }
    create_kvantum_kvconfig_file || { log_failed "Failed to create Kvantum's KVConfig file."; return 1; }

    log_ok "Kvantum configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    THEME_FULL_NAME="${THEME_NAME}-${THEME_FLAVOR}-${THEME_ACCENT}"
    THEME_DIR="$KVANTUM_CONFIG_DIR/${THEME_FULL_NAME}"

    BASE_URL="https://raw.githubusercontent.com/catppuccin/kvantum/main/themes"
    SVG_FILE_NAME="${THEME_FULL_NAME}.svg"
    SVG_FILE_URL="${BASE_URL}/${THEME_FULL_NAME}/${SVG_FILE_NAME}"
    KVCONFIG_FILE_NAME="${THEME_FULL_NAME}.kvconfig"
    KVCONFIG_FILE_URL="${BASE_URL}/${THEME_FULL_NAME}/${KVCONFIG_FILE_NAME}"
}

prepare_before_update() {
    log_info "Preparing before update..."

    mkdir -p "$KVANTUM_CONFIG_DIR"
    rm -rf "$THEME_DIR"
    mkdir -p "$THEME_DIR"
}

download_svg_and_kvconfig_files() {
    log_info "Downloading theme's SVG and KVConfig files..."

    util_download_with_retry "$SVG_FILE_URL" "$THEME_DIR/$SVG_FILE_NAME"
    util_download_with_retry "$KVCONFIG_FILE_URL" "$THEME_DIR/$KVCONFIG_FILE_NAME"
}

create_kvantum_kvconfig_file() {
    log_info "Creating KVConfig file..."

    echo "[General]" > "$KVANTUM_CONFIG_DIR/kvantum.kvconfig"
    echo "theme=${THEME_FULL_NAME}" >> "$KVANTUM_CONFIG_DIR/kvantum.kvconfig"
}

main
