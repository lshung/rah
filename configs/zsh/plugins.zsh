main() {
    install_zinit_if_not_exists
    load_plugins
}

install_zinit_if_not_exists() {
    [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
    [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    source "${ZINIT_HOME}/zinit.zsh"
}

load_plugins() {
    zinit light romkatv/powerlevel10k

    zinit ice wait"0" lucid
    zinit load zdharma-continuum/history-search-multi-word
    zinit light zsh-users/zsh-autosuggestions
    zinit light zdharma-continuum/fast-syntax-highlighting
    zinit light rupa/z
    zinit light zsh-users/zsh-completions
    zinit light zsh-users/zsh-history-substring-search
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
    zinit light hlissner/zsh-autopair
    zinit light Aloxaf/fzf-tab
    zinit light MichaelAquilina/zsh-you-should-use
}

main
