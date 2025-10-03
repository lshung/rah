#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Zsh configuration..."

    prepare_before_update || { log_failed "Failed to prepare before update."; return 1; }
    sync_config || { log_failed "Failed to synchronize configuration."; return 1; }
    test_new_config || { log_failed "Failed to test new configuration."; return 1; }

    log_ok "Zsh configuration updated successfully."
    log_warning "To apply changes, please manually run command 'source $HOME/.zshenv'"
}

prepare_before_update() {
    log_info "Preparing before update..."

    mkdir -p "$ZSH_CONFIG_DIR"
}

sync_config() {
    util_sync_contents_of_two_dirs "$APP_CONFIGS_ZSH_DIR" "$ZSH_CONFIG_DIR"
    mv "$ZSH_CONFIG_DIR"/.zshenv "$HOME/.zshenv"
}

test_new_config() {
    log_info "Testing new configuration..."

    zsh -c "source $ZSH_CONFIG_DIR/.zshrc"
}

main
