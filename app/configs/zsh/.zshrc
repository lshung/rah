main() {
    enable_p10k_instant_prompt
    copy_default_p10k_config_if_not_exists
    source_p10k_config_if_exists
    source_all_files_in_conf_d_dir
}

enable_p10k_instant_prompt() {
    local p10k_instant_prompt_file="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    [[ -r "$p10k_instant_prompt_file" ]] && source "$p10k_instant_prompt_file"
}

copy_default_p10k_config_if_not_exists() {
    local zinit_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
    local p10k_config_file="$zinit_dir/plugins/romkatv---powerlevel10k/config/p10k-rainbow.zsh"

    if [[ ! -f "$ZDOTDIR/.p10k.zsh" && -f "$p10k_config_file" ]]; then
        cp "$p10k_config_file" "$ZDOTDIR/.p10k.zsh"
    fi
}

source_p10k_config_if_exists() {
    [ -r "$ZDOTDIR/.p10k.zsh" ] && source "$ZDOTDIR/.p10k.zsh"
}

source_all_files_in_conf_d_dir() {
    local dir="$ZDOTDIR/conf.d"

    for file in $(find "$dir" -maxdepth 1 -name "*.zsh" | sort); do
        [ -r "$file" ] && source "$file" || { echo -e "[\033[31mERR\033[0m] Failed to source file '$file'." 1>&2; return 1; }
    done
}

main
