#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31mERR\033[0m] This script cannot be executed directly" 1>&2; exit 1; }

# Exit on error
set -e

# Source the configuration file of the selected style
source "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/config"

# Declare variables
ICON_NAMES=("hibernate" "lock" "logout" "reboot" "shutdown" "suspend")
COLOR_NAMES=("$WLOGOUT_BUTTON_COLOR" "$WLOGOUT_BUTTON_HOVER_COLOR")

# Main execution function
main() {
    echo "Updating Wlogout configuration..."

    prepare_config_dir
    setup_style
    setup_icons
}

# Function to prepare configuration directory
prepare_config_dir() {
    echo "Preparing configuration directory..."

    mkdir -p "$WLOGOUT_CONFIG_DIR"
    mkdir -p "$WLOGOUT_CONFIG_DIR/icons"
    rm -rf "$WLOGOUT_CONFIG_DIR"/icons/*
}

# Function to setup wlogout configuration
setup_style() {
    echo "Setting up style..."

    # Copy configuration files
    cp "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/layout" "$WLOGOUT_CONFIG_DIR/layout"
    cp "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/config" "$WLOGOUT_CONFIG_DIR/config"

    # Process style.css with environment variables
    export THEME_NAME
    export THEME_FLAVOR
    export CACHE_WALLPAPERS_DIR
    export WLOGOUT_FONT_SIZE
    export WLOGOUT_TEXT_COLOR
    export WLOGOUT_TEXT_HOVER_COLOR
    export WLOGOUT_BUTTON_COLOR
    export WLOGOUT_BUTTON_HOVER_COLOR
    export WLOGOUT_BUTTON_BACKGROUND_COLOR
    export WLOGOUT_BUTTON_HOVER_BACKGROUND_COLOR
    export WLOGOUT_BUTTON_BORDER_COLOR
    export WLOGOUT_VERTICAL_MARGIN
    export WLOGOUT_HORIZONTAL_MARGIN
    export WLOGOUT_BUTTON_HOVER_MARGIN
    envsubst < "$APP_CONFIGS_WLOGOUT_DIR/styles/$WLOGOUT_STYLE/style.css" > "$WLOGOUT_CONFIG_DIR/style.css"
}

# Function to update icons if needed
setup_icons() {
    echo "Setting up icons..."

    for icon in "${ICON_NAMES[@]}"; do
        process_single_icon "$icon"
    done

    echo "Icon setup completed."
}

# Function to process a single icon with all color variants
process_single_icon() {
    local icon_name="$1"
    local source_icon_file="$APP_CONFIGS_WLOGOUT_DIR/icons/${icon_name}.svg"

    if [ ! -f "$source_icon_file" ]; then
        echo "Warning: Source icon not found: $source_icon_file"
        return
    fi

    for color_name in "${COLOR_NAMES[@]}"; do
        create_themed_icon "$icon_name" "$source_icon_file" "$color_name"
    done
}

# Function to create a themed icon variant
create_themed_icon() {
    local icon_name="$1"
    local source_icon_file="$2"
    local color_name="$3"
    local output_icon_file="$WLOGOUT_CONFIG_DIR/icons/${icon_name}-${THEME_NAME}-${THEME_FLAVOR}-${color_name}.svg"
    local color_value_hex

    # Check if the color is valid
    if get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$color_name" >/dev/null 2>&1; then
        # Get the color value
        color_value_hex=$(get_theme_color "$THEME_NAME" "$THEME_FLAVOR" "$color_name")

        # Create themed icon by replacing the fill color
        sed "s/fill=\"#[0-9a-fA-F]\{6\}\"/fill=\"$color_value_hex\"/g" "$source_icon_file" > "$output_icon_file"
        echo "Created: $output_icon_file"
    else
        echo "Error: Failed to get color $color_name for theme $THEME_NAME-$THEME_FLAVOR"
    fi
}

# Execute main function
main
