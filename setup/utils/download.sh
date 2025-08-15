#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

# Download function with retry and timeout
_download_with_retry() {
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
