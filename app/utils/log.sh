#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

readonly NC='\033[0m'           # Reset color
readonly RED='\033[0;31m'       # Red
readonly GREEN='\033[0;32m'     # Green
readonly YELLOW='\033[0;33m'    # Yellow

log_message() {
    local level="$1"
    local message="$2"
    local include_tee="${3:-yes}"

    if [[ "$LOG_TIMESTAMP_INCLUDED" == "yes" ]]; then
        local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')] "
    else
        local timestamp=""
    fi

    case "$level" in
        "EMPTY")
            if [[ "$include_tee" == "no" ]]; then
                echo ""
            else
                echo "" | tee -a "$LOG_FILE"
            fi
            ;;
        "INFO")
            if [[ "$include_tee" == "no" ]]; then
                echo "$timestamp[ INFO ] $message"
            else
                echo "$timestamp[ INFO ] $message" | tee -a "$LOG_FILE"
            fi
            ;;
        "WARNING")
            if [[ "$include_tee" == "no" ]]; then
                echo -e "$timestamp[${YELLOW} WARN ${NC}] $message" 1>&2
            else
                echo -e "$timestamp[${YELLOW} WARN ${NC}] $message" | tee -a "$LOG_FILE" 1>&2
            fi
            ;;
        "ERROR")
            if [[ "$include_tee" == "no" ]]; then
                echo -e "$timestamp[${RED} ERRO ${NC}] $message" 1>&2
            else
                echo -e "$timestamp[${RED} ERRO ${NC}] $message" | tee -a "$LOG_FILE" 1>&2
            fi
            ;;
        "OK")
            if [[ "$include_tee" == "no" ]]; then
                echo -e "$timestamp[${GREEN}  OK  ${NC}] $message"
            else
                echo -e "$timestamp[${GREEN}  OK  ${NC}] $message" | tee -a "$LOG_FILE"
            fi
            ;;
        "FAILED")
            if [[ "$include_tee" == "no" ]]; then
                echo -e "$timestamp[${RED}FAILED${NC}] $message" 1>&2
            else
                echo -e "$timestamp[${RED}FAILED${NC}] $message" | tee -a "$LOG_FILE" 1>&2
            fi
            ;;
    esac
}

log_empty_line() {
    log_message "EMPTY" "EMPTY" "${1:-yes}"
}

log_info() {
    log_message "INFO" "$1" "${2:-yes}"
}

log_warning() {
    log_message "WARNING" "$1" "${2:-yes}"
}

log_error() {
    log_message "ERROR" "$1" "${2:-yes}"
}

log_ok() {
    log_message "OK" "$1" "${2:-yes}"
}

log_failed() {
    log_message "FAILED" "$1" "${2:-yes}"
}

util_clean_up_log_files() {
    local log_files_list=($(find "$LOG_DIR" -name "*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | cut -d' ' -f2-))
    local log_files_count=${#log_files_list[@]}

    if [[ $log_files_count -gt $LOG_FILE_COUNT ]]; then
        for ((i = LOG_FILE_COUNT; i < log_files_count; i++)); do
            [ -f "${log_files_list[$i]}" ] && rm -f "${log_files_list[$i]}"
        done
    fi
}
