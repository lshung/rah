util_source_file_if_exists() {
    local file="$1"
    [ -r "$file" ] && source "$file" || { echo -e "[\033[31mERR\033[0m] File '$file' not found or not readable" 1>&2; return 1; }
}

util_source_all_files_in_dir() {
    local dir="$1"

    [ ! -d "$dir" ] && { echo -e "[\033[31mERR\033[0m] Directory '$dir' does not exist" 1>&2; return 1; }

    for file in "$dir"/*.zsh; do
        util_source_file_if_exists "$file"
    done
}
