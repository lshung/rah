#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

# Sync contents of two directories
sync_contents_of_two_dirs() {
    local source_dir="$1"
    local dest_dir="$2"

    # Validate arguments
    if [[ $# -ne 2 ]]; then
        echo "Error: Two arguments are required"
        return 1
    fi

    if [[ ! -d "$source_dir" ]]; then
        echo "Error: Source directory '$source_dir' does not exist"
        return 1
    fi

    if [[ ! -d "$dest_dir" ]]; then
        echo "Error: Destination directory '$dest_dir' does not exist"
        return 1
    fi

    echo "Syncing contents of $source_dir to $dest_dir..."

    # Step 1: Copy all files from source to destination (preserving directory structure)
    find "$source_dir" -type f -print0 | while IFS= read -r -d '' source_file; do
        # Get relative path from source directory
        relative_path="${source_file#$source_dir/}"
        dest_file="$dest_dir/$relative_path"
        dest_dir_path="$(dirname "$dest_file")"

        # Create destination directory if it doesn't exist
        mkdir -p "$dest_dir_path"

        # Copy file if it doesn't exist or is different
        if [[ ! -f "$dest_file" ]] || ! cmp -s "$source_file" "$dest_file"; then
            echo "Copying: $relative_path"
            cp --preserve=timestamps "$source_file" "$dest_file"
        fi
    done

    # Step 2: Remove files in destination that don't exist in source
    find "$dest_dir" -type f -print0 | while IFS= read -r -d '' dest_file; do
        # Get relative path from destination directory
        relative_path="${dest_file#$dest_dir/}"
        source_file="$source_dir/$relative_path"

        # Remove file if it doesn't exist in source
        if [[ ! -f "$source_file" ]]; then
            echo "Removing: $relative_path"
            rm -f "$dest_file"
        fi
    done

    # Step 3: Remove empty directories in destination that don't exist in source
    find "$dest_dir" -type d -print0 | sort -r | while IFS= read -r -d '' dest_directory; do
        # Skip the destination directory itself
        [[ "$dest_directory" == "$dest_dir" ]] && continue

        # Get relative path from destination directory
        relative_path="${dest_directory#$dest_dir/}"
        source_directory="$source_dir/$relative_path"

        # Remove directory if it doesn't exist in source and is empty
        if [[ ! -d "$source_directory" ]] && [[ -z "$(ls -A "$dest_directory")" ]]; then
            echo "Removing empty directory: $relative_path"
            rmdir "$dest_directory" 2>/dev/null
        fi
    done

    echo "Sync completed!"
}
