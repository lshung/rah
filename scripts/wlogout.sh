#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will execute wlogout with an optional style name

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

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
