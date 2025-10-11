#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Qt5ct and Qt6ct configuration..."

    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    copy_config_files || { log_failed "Failed to copy config files."; return 1; }

    log_ok "Qt5ct and Qt6ct configuration updated successfully."
}

prepare_before_update() {
    log_info "Preparing before update..."

    rm -rf "$QT5CT_CONFIG_DIR"
    rm -rf "$QT6CT_CONFIG_DIR"
    mkdir -p "$QT5CT_CONFIG_DIR"
    mkdir -p "$QT6CT_CONFIG_DIR"
}

copy_config_files() {
    log_info "Copying config files..."

    cp "$APP_CONFIGS_QTCT_DIR"/qt5ct.conf "$QT5CT_CONFIG_DIR"/
    cp "$APP_CONFIGS_QTCT_DIR"/qt6ct.conf "$QT6CT_CONFIG_DIR"/
}

main
