#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

util_check_if_package_is_installed() {
    local package="$1"
    pacman -Q "$package" >/dev/null 2>&1 || return 1
}

util_install_packages() {
    sudo pacman -S --needed --noconfirm "$@" || return 1
}

util_update_system() {
    sudo pacman -Syu --noconfirm || return 1
}
