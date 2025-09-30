#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    echo "Updating Fcitx5 configuration..."

    declare_variables
    install_required_packages_if_missing
    prepare_config_dir
    copy_profile
    update_config
    reload_fcitx5

    echo "Setup completed. Please relogin or restart session to apply changes."
}

declare_variables() {
    FCITX5_PACKAGES=(fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-unikey)
}

install_required_packages_if_missing() {
    echo "Installing required packages if missing..."

    local missing=()
    for pkg in "${FCITX5_PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
}

prepare_config_dir() {
    echo "Preparing configuration directory..."

    mkdir -p "$FCITX5_CONFIG_DIR"
}

copy_profile() {
    echo "Copying profile..."

    cp "$APP_CONFIGS_FCITX5_DIR/profile" "$FCITX5_PROFILE_FILE"
}

update_config() {
    echo "Updating config..."

    sed -i "s/^ActiveByDefault=.*/ActiveByDefault=True/g" "$FCITX5_CONFIG_FILE"
    sed -i "s/^ShowInputMethodInformation=.*/ShowInputMethodInformation=False/g" "$FCITX5_CONFIG_FILE"
}

reload_fcitx5() {
    echo "Reloading Fcitx5..."

    fcitx5-remote -r
}

# Call main function
main
