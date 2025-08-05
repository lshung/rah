#!/bin/bash

# Thoát nếu có lỗi
set -e

source ./exec/fonts.sh
source ./exec/kitty.sh
source ./exec/wlogout.sh
source ./exec/hyprland.sh
source ./exec/waybar.sh

echo "Cập nhật cấu hình thành công! Hãy logout để áp dụng các thay đổi."
