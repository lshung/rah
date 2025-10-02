#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

util_sync_contents_of_two_dirs() {
    local source_dir="$1"
    local dest_dir="$2"

    _validate_two_dirs_provided "$source_dir" "$dest_dir" || return 1

    log_info "Synchronizing contents from '$source_dir' to '$dest_dir'..."

    _copy_files_if_new_or_different "$source_dir" "$dest_dir"
    _remove_files_in_destination_but_not_in_source "$source_dir" "$dest_dir"
    _remove_empty_dirs_in_destination_but_not_in_source "$source_dir" "$dest_dir"

    log_ok "Synchronized contents successfully."
}

_validate_two_dirs_provided() {
    local source_dir="$1"
    local dest_dir="$2"

    if [[ $# -ne 2 ]]; then
        log_error "Two arguments are required."
        return 1
    fi

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory '$source_dir' does not exist."
        return 1
    fi

    if [[ ! -d "$dest_dir" ]]; then
        log_error "Destination directory '$dest_dir' does not exist."
        return 1
    fi
}

_copy_files_if_new_or_different() {
    local source_dir="$1"
    local dest_dir="$2"

    find "$source_dir" -type f -print0 | while IFS= read -r -d '' source_file; do
        local relative_path=$(_get_relative_path_of_a_path_from_dir "$source_file" "$source_dir")
        local dest_file="$dest_dir/$relative_path"
        local dest_dir_path="$(dirname "$dest_file")"

        mkdir -p "$dest_dir_path"

        if [[ ! -f "$dest_file" ]] || ! cmp -s "$source_file" "$dest_file"; then
            cp --preserve=timestamps "$source_file" "$dest_file"
            log_info "Copied file '$relative_path'."
        fi
    done
}

_get_relative_path_of_a_path_from_dir() {
    local path="$1"
    local dir="$2"
    local relative_path="${path#$dir/}"
    echo "$relative_path"
}

_remove_files_in_destination_but_not_in_source() {
    local source_dir="$1"
    local dest_dir="$2"

    find "$dest_dir" -type f -print0 | while IFS= read -r -d '' dest_file; do
        local relative_path=$(_get_relative_path_of_a_path_from_dir "$dest_file" "$dest_dir")
        local source_file="$source_dir/$relative_path"

        if [[ ! -f "$source_file" ]]; then
            rm -f "$dest_file"
            log_info "Removed file '$relative_path'."
        fi
    done
}

_remove_empty_dirs_in_destination_but_not_in_source() {
    local source_dir="$1"
    local dest_dir="$2"

    find "$dest_dir" -type d -print0 | sort -r | while IFS= read -r -d '' dest_directory; do
        # Skip the destination directory itself
        [[ "$dest_directory" == "$dest_dir" ]] && continue

        local relative_path=$(_get_relative_path_of_a_path_from_dir "$dest_directory" "$dest_dir")
        local source_directory="$source_dir/$relative_path"

        if [[ ! -d "$source_directory" ]] && [[ -z "$(ls -A "$dest_directory")" ]]; then
            rmdir "$dest_directory" 2>/dev/null
            log_info "Removed empty directory '$relative_path'."
        fi
    done
}
