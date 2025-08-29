#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

main() {
    echo "Updating Zsh configuration..."

    prepare
    sync_config

    echo "Zsh configuration updated successfully!"
    echo "To apply changes, please manually run command 'source $HOME/.zshenv'"
}

prepare() {
    mkdir -p "$ZSH_CONFIG_DIR"
}

sync_config() {
    util_sync_contents_of_two_dirs "$APP_CONFIGS_ZSH_DIR" "$ZSH_CONFIG_DIR"
    mv "$ZSH_CONFIG_DIR"/.zshenv "$HOME/.zshenv"
}

main "$@"
