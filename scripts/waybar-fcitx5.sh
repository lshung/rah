#!/bin/bash

# This file is meant to be sourced by scripts/exec.sh
# It will get abbreviation of Fcitx5 input method

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

main() {
    declare_variables
    get_abbreviation_of_fcitx5_input_method
}

declare_variables() {
    CURRENT_INPUT_METHOD=$(fcitx5-remote -n 2>/dev/null)
}

get_abbreviation_of_fcitx5_input_method() {
    case "$CURRENT_INPUT_METHOD" in
        "keyboard-us")
            echo '{"text": "EN", "tooltip": "English", "class": "english"}'
            ;;
        "Unikey"|"unikey")
            echo '{"text": "VN", "tooltip": "Vietnamese - Unikey", "class": "vietnamese"}'
            ;;
        "mozc-jp")
            echo '{"text": "JP", "tooltip": "Japanese", "class": "japanese"}'
            ;;
        "hangul")
            echo '{"text": "KR", "tooltip": "Korean", "class": "korean"}'
            ;;
        "pinyin")
            echo '{"text": "CN", "tooltip": "Chinese", "class": "chinese"}'
            ;;
        *)
            echo '{"text": "XX", "tooltip": "'"$CURRENT_INPUT_METHOD"'", "class": "unknown"}'
            ;;
    esac
}

# Call main function with arguments
main "$@"
