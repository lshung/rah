#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    declare_variables

    if ! check_if_no_missing_packages; then
        update_system_beforehand
        install_missing_packages
        run_post_install_commands
    fi

    download_wallpapers_if_needed
    update_config_for_all_modules
    change_shell_to_zsh_if_not_set
    show_final_message
}

declare_variables() {
    MISSING_PACKAGES=()

    FONT_PACKAGES=("ttf-jetbrains-mono-nerd" "ttf-cascadia-code-nerd" "cantarell-fonts" "ttf-nerd-fonts-symbols")
    ICON_PACKAGES=("tela-circle-icon-theme-all")
    HYPRLAND_PACKAGES=("hyprland" "hypridle" "hyprlock" "hyprpicker" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk")
    QT_PACKAGES=("qt5-wayland" "qt6-wayland" "qt5ct" "qt6ct" "kvantum" "kvantum-qt5")
    SDDM_PACKAGES=("sddm" "qt5-graphicaleffects" "qt5-quickcontrols2")
    BLUETOOTH_PACKAGES=("bluez" "bluez-utils" "blueman")
    OTHER_PACKAGES=("bc" "cliphist" "firefox" "git" "jq" "kitty" "less" "nwg-displays" "nwg-look" "pavucontrol" "rofi" "swww" "unzip" "waybar" "zsh")

    PACKAGES=(
        "${FONT_PACKAGES[@]}"
        "${ICON_PACKAGES[@]}"
        "${HYPRLAND_PACKAGES[@]}"
        "${QT_PACKAGES[@]}"
        "${SDDM_PACKAGES[@]}"
        "${BLUETOOTH_PACKAGES[@]}"
        "${OTHER_PACKAGES[@]}"
    )
}

check_if_no_missing_packages() {
    log_info "Checking if there are missing packages..."

    for package in "${PACKAGES[@]}"; do
        if ! util_check_if_package_is_installed "$package"; then
            MISSING_PACKAGES+=("$package")
        fi
    done

    if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
        log_warning "Missing packages: ${MISSING_PACKAGES[*]}."
        return 1
    fi

    log_ok "There are no missing packages."
}

update_system_beforehand() {
    log_info "Updating system before installing missing packages..."

    sudo -v

    if ! util_update_system; then
        log_failed "Failed to update system."
        return 1
    fi

    log_ok "Updated system successfully."
}

install_missing_packages() {
    log_info "Installing missing packages..."

    if ! util_install_packages "${MISSING_PACKAGES[@]}"; then
        log_failed "Failed to install missing packages."
        return 1
    fi

    log_ok "Installed missing packages successfully."
}

run_post_install_commands() {
    log_info "Running post-install commands..."

    if ! fc-cache -fv > /dev/null 2>&1; then
        log_failed "Failed to reload font cache."
        return 1
    fi

    if ! sudo systemctl start bluetooth.service; then
        log_failed "Failed to start bluetooth service."
        return 1
    fi

    if ! sudo systemctl enable bluetooth.service; then
        log_failed "Failed to enable bluetooth service."
        return 1
    fi

    log_ok "Post-install commands completed successfully."
}

download_wallpapers_if_needed() {
    mkdir -p "$WALLPAPERS_DIR"

    if util_wallpaper_validate_wallpapers_dir; then
        log_info "Wallpapers already exist. No need to download."
        return 0
    fi

    log_info "Downloading wallpapers..."

    if ! curl -L https://raw.githubusercontent.com/lshung/rah-assets/master/wallpapers/japanese-samurai.jpg -o "$WALLPAPERS_DIR/japanese-samurai.jpg"; then
        log_failed "Failed to download wallpapers."
        return 1
    fi

    log_ok "Wallpapers downloaded successfully."
}

update_config_for_all_modules() {
    log_info "Updating configuration for all modules..."

    source "$APP_DIR/update.sh" "--update"
}

change_shell_to_zsh_if_not_set() {
    if [[ "$SHELL" == "$(which zsh)" ]]; then
        log_info "The current shell is already Zsh."
        return 0
    fi

    log_info "Changing shell to Zsh..."

    if ! chsh -s $(which zsh); then
        log_failed "Failed to change shell to Zsh."
        return 1
    fi

    log_ok "Changed shell to Zsh successfully."
    log_warning "Please logout and login back or manually run command 'exec zsh' for the shell change to take effect".
}

show_final_message() {
    log_ok "All done. You may need to reboot for the changes to take effect."
}

main
