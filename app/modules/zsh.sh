#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    log_info "Updating Zsh configuration..."

    prepare
    sync_config
    test_new_config

    log_ok "Zsh configuration updated successfully."
    log_warning "To apply changes, please manually run command 'source $HOME/.zshenv'"
}

prepare() {
    mkdir -p "$ZSH_CONFIG_DIR"
}

sync_config() {
    util_sync_contents_of_two_dirs "$APP_CONFIGS_ZSH_DIR" "$ZSH_CONFIG_DIR"
    mv "$ZSH_CONFIG_DIR"/.zshenv "$HOME/.zshenv"
}

test_new_config() {
    log_info "Testing new Zsh configuration..."

    if ! zsh -c "source $ZSH_CONFIG_DIR/.zshrc"; then
        log_failed "Failed to test new Zsh configuration."
        return 1
    fi

    log_ok "New Zsh configuration tested successfully."
}

main
