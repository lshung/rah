#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Fcitx5 configuration..."

    declare_variables
    install_required_packages_if_missing
    prepare_config_dir
    copy_config
    reload_fcitx5

    log_ok "Configuration updated successfully. Please relogin or restart session to apply changes."
}

declare_variables() {
    FCITX5_PACKAGES=(fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-unikey)
}

install_required_packages_if_missing() {
    log_info "Installing required packages if missing..."

    local missing_packages=()
    for package in "${FCITX5_PACKAGES[@]}"; do
        if ! util_check_if_package_is_installed "$package"; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        sudo -v
        util_update_system
        util_install_packages "${missing_packages[@]}"

        log_ok "Required packages installed successfully."
        return 0
    fi

    log_ok "There are no missing packages."
}

prepare_config_dir() {
    log_info "Preparing configuration directory..."

    if ! mkdir -p "$FCITX5_CONFIG_DIR"; then
        log_failed "Failed to prepare configuration directory."
        return 1
    fi

    log_ok "Configuration directory prepared successfully."
}

copy_config() {
    log_info "Copying config files..."

    if cp "$APP_CONFIGS_FCITX5_DIR/profile" "$FCITX5_PROFILE_FILE" \
        && cp "$APP_CONFIGS_FCITX5_DIR/config" "$FCITX5_CONFIG_FILE"; then
        log_ok "Config files copied successfully."
    else
        log_failed "Failed to copy config files."
        return 1
    fi
}

reload_fcitx5() {
    log_info "Reloading Fcitx5..."

    if ! fcitx5-remote -r; then
        log_failed "Failed to reload Fcitx5."
        return 1
    fi

    log_ok "Fcitx5 reloaded successfully."
}

main
