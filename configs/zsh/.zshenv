# Add $HOME/.local/bin to PATH if it's not already there
if [[ ! $PATH =~ "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# XDG User Directory Specification
export XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
export XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
export XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
export XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
export XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
export XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
export XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
export XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"

# Zsh Configuration Directory
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"
