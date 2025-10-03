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
    edit_style_css_file || { log_failed "Failed to edit 'style.css' file."; return 1; }
    create_colored_icons || { log_failed "Failed to create colored icons."; return 1; }

    log_ok "Wlogout configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    WLOGOUT_COMPILATION_PACKAGES=("meson" "ninja" "gtk3" "gtk-layer-shell" "wayland")
    WLOGOUT_MISSING_COMPILATION_PACKAGES=()
    WLOGOUT_REPO_DIR="$HOME/.local/lib/wlogout"

    source "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/config"
    ICON_NAMES=("hibernate" "lock" "logout" "reboot" "shutdown" "suspend")
    COLOR_NAMES=("$WLOGOUT_BUTTON_COLOR" "$WLOGOUT_BUTTON_HOVER_COLOR")
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

    mkdir -p "$WLOGOUT_CONFIG_DIR"
    mkdir -p "$WLOGOUT_CONFIG_DIR/icons"
    rm -rf "$WLOGOUT_CONFIG_DIR"/icons/*
}

copy_config_files() {
    log_info "Copying config files..."

    cp "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/layout" "$WLOGOUT_CONFIG_DIR/layout"
    cp "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/config" "$WLOGOUT_CONFIG_DIR/config"
    cp "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/style.css" "$WLOGOUT_CONFIG_DIR/style.css"
}

edit_style_css_file() {
    log_info "Editing 'style.css' file..."

    export THEME_NAME
    export THEME_FLAVOR
    export CACHE_WALLPAPERS_DIR
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

    envsubst < "$WLOGOUT_CONFIG_DIR/style.css" > "$WLOGOUT_CONFIG_DIR/style.css.tmp"
    mv "$WLOGOUT_CONFIG_DIR/style.css.tmp" "$WLOGOUT_CONFIG_DIR/style.css"
}

create_colored_icons() {
    log_info "Creating colored icons..."

    for icon in "${ICON_NAMES[@]}"; do
        create_icon_with_multiple_colors "$icon"
    done
}

create_icon_with_multiple_colors() {
    local icon_name="$1"
    local source_icon_file="$APP_CONFIGS_WLOGOUT_DIR/icons/${icon_name}.svg"

    [ -f "$source_icon_file" ] || { log_error "Source icon not found at '$source_icon_file'."; return 1; }

    for color_name in "${COLOR_NAMES[@]}"; do
        create_icon_with_single_color "$icon_name" "$source_icon_file" "$color_name"
    done
}

create_icon_with_single_color() {
    local icon_name="$1"
    local source_icon_file="$2"
    local color_name="$3"
    local output_icon_file="$WLOGOUT_CONFIG_DIR/icons/${icon_name}-${THEME_NAME}-${THEME_FLAVOR}-${color_name}.svg"

    if ! util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$color_name" >/dev/null 2>&1; then
        log_error "Failed to get color '$color_name' for theme '$THEME_NAME-$THEME_FLAVOR'."
        return 1
    fi

    local color_value_hex=$(util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$color_name")
    sed "s/fill=\"#[0-9a-fA-F]\{6\}\"/fill=\"$color_value_hex\"/g" "$source_icon_file" > "$output_icon_file"

    log_info "Created file '$output_icon_file'."
}

main
