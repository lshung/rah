#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "Cập nhật cấu hình Wlogout..."

mkdir -p "$HOME"/.config/wlogout
mkdir -p "$HOME"/.config/wlogout/icons

rm -rf "$HOME"/.config/wlogout/style.css
cp "$CONFIGS_DIR"/wlogout/style.css "$HOME"/.config/wlogout/style.css
rm -rf "$HOME"/.config/wlogout/layout
cp "$CONFIGS_DIR"/wlogout/layout "$HOME"/.config/wlogout/layout

# Mảng tên các icon cần tải xuống
icons=("hibernate" "lock" "logout" "reboot" "shutdown" "suspend")
# URL cơ sở cho các icon
base_url="https://raw.githubusercontent.com/catppuccin/wlogout/main/icons/wlogout/mocha/peach"

# Tải xuống từng icon
for icon in "${icons[@]}"; do
    if [ ! -f "$HOME/.config/wlogout/icons/${icon}.svg" ]; then
        echo "Đang tải xuống ${icon}.svg..."
        curl -L -o "$HOME/.config/wlogout/icons/${icon}.svg" "${base_url}/${icon}.svg" || \
            wget --no-check-certificate -P "$HOME/.config/wlogout/icons/" "${base_url}/${icon}.svg"
    fi
done
