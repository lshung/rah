#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will execute wlogout with an optional style name

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    source_config_of_style
    launch_wlogout
}

source_config_of_style() {
    source "$WLOGOUT_CONFIG_DIR/config"
}

launch_wlogout() {
    wlogout -b "$WLOGOUT_BUTTONS_PER_ROW" \
        -r "$WLOGOUT_ROW_SPACING" \
        -c "$WLOGOUT_COLUMN_SPACING" \
        --protocol layer-shell
}

# Call main function with arguments
main "$@"
