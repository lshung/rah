main() {
    enable_p10k_instant_prompt
    source_declared_variables
    source_utility_functions
    source_plugins
    copy_default_p10k_config_if_not_exists
    source_p10k_config_if_exists
    source_all_files_in_conf_d_dir
}

enable_p10k_instant_prompt() {
    local p10k_instant_prompt_file="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    [[ -r "$p10k_instant_prompt_file" ]] && source "$p10k_instant_prompt_file"
}

source_declared_variables() {
    source "$ZDOTDIR/variables.zsh"
}

source_utility_functions() {
    source "$ZDOTDIR/utils.zsh"
}

source_plugins() {
    source "$ZDOTDIR/plugins.zsh"
}

copy_default_p10k_config_if_not_exists() {
    local p10k_config_file="$ZINIT_DIR/plugins/romkatv---powerlevel10k/config/p10k-rainbow.zsh"

    if [[ ! -f "$ZDOTDIR/.p10k.zsh" && -f "$p10k_config_file" ]]; then
        cp "$p10k_config_file" "$ZDOTDIR/.p10k.zsh"
    fi
}

source_p10k_config_if_exists() {
    util_source_file_if_exists "$ZDOTDIR/.p10k.zsh"
}

source_all_files_in_conf_d_dir() {
    util_source_all_files_in_dir "$ZDOTDIR/conf.d"
}

main
