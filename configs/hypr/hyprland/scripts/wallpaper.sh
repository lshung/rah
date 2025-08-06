#!/bin/bash

# Thư mục chứa hình nền
WALLPAPER_DIR="$HOME/.config/wallpapers"

# Kiểm tra xem swww-daemon có đang chạy không, nếu không thì khởi động
if ! pgrep -x "swww-daemon" > /dev/null; then
    echo "Đang khởi động swww-daemon..."
    swww-daemon &
    sleep 1  # Đợi một chút để daemon khởi động
fi

# Kiểm tra xem thư mục có tồn tại không
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Thư mục hình nền $WALLPAPER_DIR không tồn tại!"
    exit 1
fi

# Lấy danh sách các file hình ảnh (jpg, jpeg, png, bmp, gif)
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \)))

# Kiểm tra xem có tìm thấy hình nền nào không
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Không tìm thấy hình nền nào trong $WALLPAPER_DIR"
    exit 1
fi

# Chọn hình nền ngẫu nhiên
RANDOM_WALLPAPER="${WALLPAPERS[$((RANDOM % ${#WALLPAPERS[@]}))]}"

# Kiểm tra xem có phải là preload không
if [ "$1" = "--preload" ]; then
    # Đặt hình nền không có chuyển cảnh (preload)
    swww img "$RANDOM_WALLPAPER" --transition-type none
    echo "Đã preload hình nền: $(basename "$RANDOM_WALLPAPER")"
else
    # Đặt hình nền bằng swww với chuyển cảnh bo tròn ngẫu nhiên
    swww img "$RANDOM_WALLPAPER" --transition-type any
    echo "Đã đổi hình nền thành: $(basename "$RANDOM_WALLPAPER")"
fi
