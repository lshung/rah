#!/bin/bash

# Thoát nếu có lỗi
set -e

# Khai báo biến
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

source "$SCRIPT_DIR/exec/modules/fonts.sh"
source "$SCRIPT_DIR/exec/modules/kitty.sh"
source "$SCRIPT_DIR/exec/modules/wlogout.sh"
source "$SCRIPT_DIR/exec/modules/hyprland.sh"
source "$SCRIPT_DIR/exec/modules/waybar.sh"

echo "Cập nhật cấu hình thành công! Hãy logout để áp dụng các thay đổi."
