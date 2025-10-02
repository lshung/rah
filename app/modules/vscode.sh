#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating VSCode configuration..."

    declare_variables
    copy_config_to_existing_vscode_dirs
}

declare_variables() {
    VSCODE_CONFIG_USER_DIRS=(
        "${CODE_CONFIG_USER_DIR}"
        "${CODEOSS_CONFIG_USER_DIR}"
        "${VSCODIUM_CONFIG_USER_DIR}"
        "${CURSOR_CONFIG_USER_DIR}"
    )
}

copy_config_to_existing_vscode_dirs() {
    for config_dir in "${VSCODE_CONFIG_USER_DIRS[@]}"; do
        if [[ -d "$config_dir" ]]; then
            cp "$APP_CONFIGS_VSCODE_DIR/settings.json" "$config_dir/settings.json"
        fi
    done
}

main
