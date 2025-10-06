#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Wlogout configuration..."

    declare_variables || { log_failed "Failed to declare variables."; return 1; }

    if ! check_if_wlogout_is_installed; then
        install_wlogout || { log_failed "Failed to install Wlogout."; return 1; }
    fi

    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    copy_config_files || { log_failed "Failed to copy config files."; return 1; }
    edit_files_for_all_styles || { log_failed "Failed to edit files for all styles."; return 1; }

    log_ok "Wlogout configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    WLOGOUT_COMPILATION_PACKAGES=("meson" "ninja" "gtk3" "gtk-layer-shell" "wayland")
    WLOGOUT_MISSING_COMPILATION_PACKAGES=()
    WLOGOUT_REPO_DIR="$HOME/.local/lib/wlogout"
}

check_if_wlogout_is_installed() {
    log_info "Checking if Wlogout is installed..."

    if ! command -v wlogout >/dev/null 2>&1; then
        log_warning "Wlogout is not installed."
        return 1
    fi

    log_ok "Wlogout is already installed."
}

install_wlogout() {
    log_info "Installing Wlogout..."

    install_required_compilation_packages_if_needed
    clone_wlogout_repository || { log_failed "Failed to clone Wlogout repository."; return 1; }
    compile_wlogout || { log_failed "Failed to compile Wlogout."; return 1; }

    log_ok "Wlogout installed successfully."
}

install_required_compilation_packages_if_needed() {
    get_missing_compilation_packages || { log_failed "Failed to get missing compilation packages."; return 1; }

    if [[ ${#WLOGOUT_MISSING_COMPILATION_PACKAGES[@]} -eq 0 ]]; then
        log_info "There are no missing compilation packages."
        return 0
    fi

    log_warning "Missing compilation packages: ${WLOGOUT_MISSING_COMPILATION_PACKAGES[*]}."

    install_required_compilation_packages || { log_failed "Failed to install required compilation packages."; return 1; }
}

get_missing_compilation_packages() {
    log_info "Getting missing compilation packages..."

    for package in "${WLOGOUT_COMPILATION_PACKAGES[@]}"; do
        if ! util_check_if_package_is_installed "$package"; then
            WLOGOUT_MISSING_COMPILATION_PACKAGES+=("$package")
        fi
    done
}

install_required_compilation_packages() {
    log_info "Installing required compilation packages..."

    sudo -v
    util_update_system
    util_install_packages "${WLOGOUT_MISSING_COMPILATION_PACKAGES[@]}"
}

clone_wlogout_repository() {
    log_info "Cloning Wlogout repository..."

    rm -rf "$WLOGOUT_REPO_DIR"
    mkdir -p "$WLOGOUT_REPO_DIR"
    git clone "https://github.com/ArtsyMacaw/wlogout" "$WLOGOUT_REPO_DIR" --quiet
}

compile_wlogout() {
    log_info "Compiling Wlogout..."

    cd "$WLOGOUT_REPO_DIR"
    meson build
    ninja -C build
    sudo ninja -C build install
}

prepare_before_update() {
    log_info "Preparing before update..."

    rm -rf "$WLOGOUT_CONFIG_DIR"
    mkdir -p "$WLOGOUT_CONFIG_DIR"
}

copy_config_files() {
    log_info "Copying config files..."

    cp -r "$APP_CONFIGS_WLOGOUT_DIR/styles" "$WLOGOUT_CONFIG_DIR"/
}

edit_files_for_all_styles() {
    log_info "Editing files for all styles..."

    for style_dir in "$WLOGOUT_CONFIG_DIR"/styles/*; do
        local style_name=$(basename "$style_dir")
        edit_style_css_file "$style_name" || { log_failed "Failed to edit file '$style_name/style.css'."; return 1; }
        edit_layout_file "$style_name" || { log_failed "Failed to edit file '$style_name/layout'."; return 1; }
    done
}

edit_style_css_file() {
    log_info "Editing file '$1/style.css'..."

    local style_name="$1"
    source "$WLOGOUT_CONFIG_DIR/styles/$style_name/config"

    export THEME_NAME
    export THEME_FLAVOR
    export CACHE_WALLPAPERS_DIR
    export POWER_MENU_CACHE_DIR
    export WLOGOUT_FONT_SIZE
    export WLOGOUT_TEXT_COLOR
    export WLOGOUT_TEXT_HOVER_COLOR
    export WLOGOUT_BUTTON_COLOR
    export WLOGOUT_BUTTON_HOVER_COLOR
    export WLOGOUT_BUTTON_BACKGROUND_COLOR
    export WLOGOUT_BUTTON_HOVER_BACKGROUND_COLOR
    export WLOGOUT_BUTTON_BORDER_COLOR
    export WLOGOUT_VERTICAL_MARGIN
    export WLOGOUT_HORIZONTAL_MARGIN
    export WLOGOUT_BUTTON_HOVER_MARGIN

    envsubst < "$WLOGOUT_CONFIG_DIR/styles/$style_name/style.css" > "$WLOGOUT_CONFIG_DIR/styles/$style_name/style.css.tmp"
    mv "$WLOGOUT_CONFIG_DIR/styles/$style_name/style.css.tmp" "$WLOGOUT_CONFIG_DIR/styles/$style_name/style.css"
}

edit_layout_file() {
    log_info "Editing file '$1/layout'..."

    local style_name="$1"

    export POWER_MENU_LOCK_CMD
    export POWER_MENU_LOGOUT_CMD
    export POWER_MENU_SUSPEND_CMD
    export POWER_MENU_HIBERNATE_CMD
    export POWER_MENU_SHUTDOWN_CMD
    export POWER_MENU_REBOOT_CMD

    envsubst < "$WLOGOUT_CONFIG_DIR/styles/$style_name/layout" > "$WLOGOUT_CONFIG_DIR/styles/$style_name/layout.tmp"
    mv "$WLOGOUT_CONFIG_DIR/styles/$style_name/layout.tmp" "$WLOGOUT_CONFIG_DIR/styles/$style_name/layout"
}

main
