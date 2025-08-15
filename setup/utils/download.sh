#!/bin/bash

# Kiểm tra xem script có được source hay không
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Lỗi: Script này chỉ được phép source, không được phép chạy trực tiếp."
    exit 1
fi

# Hàm tải về với retry và timeout
_download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local timeout=30
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        echo "Đang tải về $(basename "$output") (lần thử $((retry_count + 1))/$max_retries)..."

        if curl -LsS --connect-timeout $timeout --max-time $((timeout * 2)) -o "$output" "$url"; then
            echo "Tải về $(basename "$output") thành công!"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo "Tải về $(basename "$output") thất bại. Đang thử lại sau 3 giây... (lần thử $retry_count/$max_retries)"
                sleep 3
            else
                echo "Tải về $(basename "$output") thất bại sau $max_retries lần thử. Vui lòng kiểm tra kết nối mạng."
                return 1
            fi
        fi
    done
}
