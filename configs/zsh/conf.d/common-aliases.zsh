# Source $HOME/.zshenv
szsh() {
    source "$HOME/.zshenv"
    echo "Source '$HOME/.zshenv' successfully."
}

# Clear screen
alias cl='clear'
alias cls='clear'

# List files and directories
alias ll='ls -l'
alias la='ls -la'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
