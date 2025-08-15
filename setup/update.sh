#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Thoát nếu có lỗi
set -e

# Hàm để source một module cụ thể
source_module() {
    local module_name="$1"
    local module_file="$APP_SETUP_MODULES_DIR/${module_name}.sh"

    if [[ -f "$module_file" ]]; then
        source "$module_file"
    else
        echo "Lỗi: Không tìm thấy module '$module_name' tại $module_file"
        exit 1
    fi
}

# Hàm để hiển thị hướng dẫn sử dụng
show_usage() {
    echo "Cách sử dụng: $APP_NAME_LOWER $ACTION [TÙY_CHỌN]"
    echo ""
    echo "Các tùy chọn:"
    echo "  --help, -h      Hiển thị hướng dẫn"
    echo "  fonts           Cập nhật module fonts"
    echo "  hyprland        Cập nhật module hyprland"
    echo "  icon-themes     Cập nhật module icon-themes"
    echo "  kitty           Cập nhật module kitty"
    echo "  kvantum         Cập nhật module kvantum"
    echo "  nwg-look        Cập nhật module nwg-look"
    echo "  qtct            Cập nhật module qtct"
    echo "  rofi            Cập nhật module rofi"
    echo "  waybar          Cập nhật module waybar"
    echo "  wlogout         Cập nhật module wlogout"
    echo ""
    echo "Nếu không có tùy chọn nào được cung cấp, cập nhật tất cả các modules."
}

# Lấy option đầu tiên (--update hoặc -u)
ACTION="$1"
# Shift 1 lần để loại bỏ option đầu tiên
shift

# Xử lý các tham số dòng lệnh
if [[ $# -eq 0 ]]; then
    # Không có tham số, source tất cả các modules
    source_module "fonts"
    source_module "icon-themes"
    source_module "kitty"
    source_module "wlogout"
    source_module "nwg-look"
    source_module "qtct"
    source_module "rofi"
    source_module "kvantum"
    source_module "hyprland"
    source_module "waybar"
    echo "Cập nhật cấu hình thành công! Hãy logout để áp dụng các thay đổi."
else
    case "$1" in
        --help|-h)
            show_usage "$@"
            exit 0
            ;;
        fonts)
            source_module "fonts"
            ;;
        hyprland)
            source_module "hyprland"
            ;;
        icon-themes)
            source_module "icon-themes"
            ;;
        kitty)
            source_module "kitty"
            ;;
        kvantum)
            source_module "kvantum"
            ;;
        nwg-look)
            source_module "nwg-look"
            ;;
        qtct)
            source_module "qtct"
            ;;
        rofi)
            source_module "rofi"
            ;;
        waybar)
            source_module "waybar"
            ;;
        wlogout)
            source_module "wlogout"
            ;;
        *)
            echo "Lỗi: Tuỳ chọn không hợp lệ '$1'"
            show_usage "$@"
            exit 1
            ;;
    esac
fi
