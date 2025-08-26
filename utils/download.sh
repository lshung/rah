#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

# Download function with retry and timeout
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local timeout=30
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        echo "Downloading $(basename "$output") (attempt $((retry_count + 1))/$max_retries)..."

        if curl -LsS --connect-timeout $timeout --max-time $((timeout * 2)) -o "$output" "$url"; then
            echo "Downloaded $(basename "$output") successfully!"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo "Download of $(basename "$output") failed. Retrying after 3 seconds... (attempt $retry_count/$max_retries)"
                sleep 3
            else
                echo "Download of $(basename "$output") failed after $max_retries attempts. Please check your network connection."
                return 1
            fi
        fi
    done
}
