#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

# Declare constants and variables
readonly UTIL_DOWNLOAD_MAX_RETRIES=3
readonly UTIL_DOWNLOAD_TIMEOUT=30

util_download_with_retry() {
    local url="$1"
    local output="$2"
    local retry_count=1

    while [ $retry_count -le $UTIL_DOWNLOAD_MAX_RETRIES ]; do
        echo "Downloading $(basename "$output") (attempt $retry_count/$UTIL_DOWNLOAD_MAX_RETRIES)..."

        if _try_to_download_via_curl "$url" "$output"; then
            echo "Downloaded $(basename "$output") successfully!"
            return 0
        fi

        retry_count=$(( retry_count + 1 ))
        _should_retry_to_download "$retry_count" || return 1
    done
}

_try_to_download_via_curl() {
    local url="$1"
    local output="$2"

    curl -LsS \
        --connect-timeout $UTIL_DOWNLOAD_TIMEOUT \
        --max-time $((UTIL_DOWNLOAD_TIMEOUT * 2)) \
        -o "$output" \
        "$url" >/dev/null 2>&1
}

_should_retry_to_download() {
    local retry_count="$1"

    if [ $retry_count -le $UTIL_DOWNLOAD_MAX_RETRIES ]; then
        echo "Warning: Download failed, retrying after 3 seconds..."
        sleep 3
    else
        echo "Error: Download failed after $UTIL_DOWNLOAD_MAX_RETRIES attempts"
        return 1
    fi
}
