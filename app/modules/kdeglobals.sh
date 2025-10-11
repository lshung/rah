#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Kdeglobals configuration..."

    copy_config_file || { log_failed "Failed to copy 'kdeglobals' file."; return 1; }
    edit_kdeglobals_file || { log_failed "Failed to edit 'kdeglobals' file."; return 1; }

    log_ok "Kdeglobals configuration updated successfully."
}

copy_config_file() {
    log_info "Copying 'kdeglobals' file..."

    cp "$APP_CONFIGS_KDEGLOBALS_DIR/kdeglobals" "$KDEGLOBALS_CONFIG_FILE"
}

edit_kdeglobals_file() {
    log_info "Editing 'kdeglobals' file..."

    sed -i "s/@@theme@@/$THEME_NAME/g" "$KDEGLOBALS_CONFIG_FILE"
    sed -i "s/@@flavor@@/$THEME_FLAVOR/g" "$KDEGLOBALS_CONFIG_FILE"
    sed -i "s/@@accent@@/$THEME_ACCENT/g" "$KDEGLOBALS_CONFIG_FILE"
}

main
