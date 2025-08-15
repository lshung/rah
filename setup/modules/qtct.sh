#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script can only be sourced, not run directly."
    exit 1
fi

# Exit on error
set -e

echo "Updating Qt5ct configuration..."
mkdir -p "$HOME"/.config/qt5ct
rm -rf "$HOME"/.config/qt5ct/*
cp -r "$APP_CONFIGS_QT5CT_DIR"/* "$HOME"/.config/qt5ct/

echo "Updating Qt6ct configuration..."
mkdir -p "$HOME"/.config/qt6ct
rm -rf "$HOME"/.config/qt6ct/*
cp -r "$APP_CONFIGS_QT6CT_DIR"/* "$HOME"/.config/qt6ct/
