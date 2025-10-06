#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

util_check_if_power_menu_icon_exists() {
    local icon_name="$1"
    local color_name="$2"

    [ -f "$POWER_MENU_CACHE_DIR/${icon_name}-${THEME_NAME}-${THEME_FLAVOR}-${color_name}.svg" ]
}

util_create_power_menu_icon() {
    local icon_name="$1"
    local color_name="$2"
    local source_icon_file="$APP_CONFIGS_WLOGOUT_DIR/icons/${icon_name}.svg"
    local output_icon_file="$POWER_MENU_CACHE_DIR/${icon_name}-${THEME_NAME}-${THEME_FLAVOR}-${color_name}.svg"

    if ! util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$color_name" >/dev/null 2>&1; then
        return 1
    fi

    local color_value_hex=$(util_get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$color_name")

    mkdir -p "$(dirname "$output_icon_file")"
    cp "$source_icon_file" "$output_icon_file"
    sed 's/stroke="[^"]*"/stroke="'"$color_value_hex"'"/g' "$source_icon_file" > "$output_icon_file"
}
