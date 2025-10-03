#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Hyprland configuration..."

    declare_variables || { log_failed "Failed to declare variables."; return 1; }
    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    sync_config || { log_failed "Failed to synchronize configuration."; return 1; }
    edit_hyprland_variables_config || { log_failed "Failed to edit Hyprland variables configuration."; return 1; }
    edit_hyprlock_config || { log_failed "Failed to edit Hyprlock configuration."; return 1; }
    edit_hypridle_config || { log_failed "Failed to edit Hypridle configuration."; return 1; }
    reload_hyprland || { log_failed "Failed to reload Hyprland."; return 1; }

    log_ok "Hyprland configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    COLOR_ACCENT2=$(util_get_accent2_color_name "$THEME_ACCENT")

    if [ -n "$HYPRLAND_COLOR_ACCENT2" ]; then
        COLOR_ACCENT2="$HYPRLAND_COLOR_ACCENT2"
    elif [ -n "$THEME_ACCENT2" ]; then
        COLOR_ACCENT2="$THEME_ACCENT2"
    fi
}

prepare_before_update() {
    log_info "Preparing before update..."

    mkdir -p "$HYPR_CONFIG_DIR"
}

sync_config() {
    util_sync_contents_of_two_dirs "$APP_CONFIGS_HYPR_DIR" "$HYPR_CONFIG_DIR"
}

edit_hyprland_variables_config() {
    local file="$HYPRLAND_CONFIG_DIR/variables.conf"

    log_info "Editing Hyprland variables configuration..."

    sed -i "s/^\$COLOR_THEME = .*$/\$COLOR_THEME = ${THEME_NAME}-${THEME_FLAVOR}/g" "$file"
    sed -i "s/^\$ANIMATIONS_STYLE = .*$/\$ANIMATIONS_STYLE = ${HYPRLAND_ANIMATIONS_STYLE}/g" "$file"
    sed -i "s/^\$COLOR_ACCENT = .*$/\$COLOR_ACCENT = \$${THEME_ACCENT}/g" "$file"
    sed -i "s/^\$COLOR_ACCENT_ALPHA = .*$/\$COLOR_ACCENT_ALPHA = \$${THEME_ACCENT}Alpha/g" "$file"
    sed -i "s/^\$COLOR_ACCENT2 = .*$/\$COLOR_ACCENT2 = \$${COLOR_ACCENT2}/g" "$file"
    sed -i "s/^\$COLOR_ACCENT2_ALPHA = .*$/\$COLOR_ACCENT2_ALPHA = \$${COLOR_ACCENT2}Alpha/g" "$file"
}

edit_hyprlock_config() {
    log_info "Editing Hyprlock configuration..."

    sed -i "s/@@theme@@/$THEME_NAME/g" "$HYPRLOCK_CONFIG_FILE"
    sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$HYPRLOCK_CONFIG_FILE"
    sed -i "s/@@accent@@/$THEME_ACCENT/g" "$HYPRLOCK_CONFIG_FILE"
}

edit_hypridle_config() {
    log_info "Editing Hypridle configuration..."

    export HYPRIDLE_DIM_DISPLAY_TIMEOUT
    export HYPRIDLE_LOCK_SESSION_TIMEOUT
    export HYPRIDLE_TURN_OFF_DISPLAY_TIMEOUT
    export HYPRIDLE_SUSPEND_TIMEOUT
    envsubst < "$APP_CONFIGS_HYPR_DIR/hypridle.conf" > "$HYPRIDLE_CONFIG_FILE"
}

reload_hyprland() {
    log_info "Reloading Hyprland..."

    hyprctl reload >/dev/null
}

main
