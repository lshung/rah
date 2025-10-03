#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating VSCode configuration..."

    declare_variables || { log_failed "Failed to declare variables."; return 1; }
    copy_config_to_existing_vscode_dirs || { log_failed "Failed to copy config to existing VSCode dirs."; return 1; }

    log_ok "VSCode configuration updated successfully."
}

declare_variables() {
    log_info "Declaring variables..."

    VSCODE_CONFIG_USER_DIRS=(
        "${CODE_CONFIG_USER_DIR}"
        "${CODEOSS_CONFIG_USER_DIR}"
        "${VSCODIUM_CONFIG_USER_DIR}"
        "${CURSOR_CONFIG_USER_DIR}"
    )
}

copy_config_to_existing_vscode_dirs() {
    log_info "Copying configuration to existing VSCode dirs..."

    for config_dir in "${VSCODE_CONFIG_USER_DIRS[@]}"; do
        if [[ -d "$config_dir" ]]; then
            log_info "Copying configuration to '$config_dir'..."
            cp "$APP_CONFIGS_VSCODE_DIR/settings.json" "$config_dir/settings.json"
        else
            log_warning "Directory '$config_dir' does not exist, so skip copying."
        fi
    done
}

main
