#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Fcitx5 configuration..."

    declare_variables || { log_failed "Failed to declare variables."; return 1; }
    install_required_packages_if_missing || { log_failed "Failed to install required packages."; return 1; }
    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    copy_config_files || { log_failed "Failed to copy config files."; return 1; }
    reload_fcitx5 || { log_failed "Failed to reload Fcitx5."; return 1; }

    log_ok "Fcitx5 configuration updated successfully."
    log_warning "You may need to re-login or restart session to apply changes."
}

declare_variables() {
    log_info "Declaring variables..."

    FCITX5_PACKAGES=(fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-unikey)
    FCITX5_MISSING_PACKAGES=()
}

install_required_packages_if_missing() {
    log_info "Installing required packages if missing..."

    get_missing_packages || { log_failed "Failed to get missing packages."; return 1; }

    if [[ ${#FCITX5_MISSING_PACKAGES[@]} -eq 0 ]]; then
        log_info "There are no missing packages."
        return 0
    fi

    log_warning "Missing packages: ${FCITX5_MISSING_PACKAGES[*]}."

    install_required_packages || { log_failed "Failed to install required packages."; return 1; }
}

get_missing_packages() {
    log_info "Getting missing packages..."

    for package in "${FCITX5_PACKAGES[@]}"; do
        if ! util_check_if_package_is_installed "$package"; then
            FCITX5_MISSING_PACKAGES+=("$package")
        fi
    done
}

install_required_packages() {
    log_info "Installing required packages..."

    sudo -v
    util_update_system
    util_install_packages "${FCITX5_MISSING_PACKAGES[@]}"
}

prepare_before_update() {
    log_info "Preparing before update..."

    mkdir -p "$FCITX5_CONFIG_DIR"
}

copy_config_files() {
    log_info "Copying config files..."

    cp "$APP_CONFIGS_FCITX5_DIR/profile" "$FCITX5_PROFILE_FILE"
    cp "$APP_CONFIGS_FCITX5_DIR/config" "$FCITX5_CONFIG_FILE"
}

reload_fcitx5() {
    log_info "Reloading Fcitx5..."

    fcitx5-remote -r
}

main
