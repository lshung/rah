#!/bin/bash

# Exit if this script is being executed directly
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo -e "[\033[31m ERRO \033[0m] This script cannot be executed directly." 1>&2; exit 1; }

set -euo pipefail

echo "Updating Qt5ct configuration..."
mkdir -p "$HOME"/.config/qt5ct
rm -rf "$HOME"/.config/qt5ct/*
cp -r "$APP_CONFIGS_QT5CT_DIR"/* "$HOME"/.config/qt5ct/

echo "Updating Qt6ct configuration..."
mkdir -p "$HOME"/.config/qt6ct
rm -rf "$HOME"/.config/qt6ct/*
cp -r "$APP_CONFIGS_QT6CT_DIR"/* "$HOME"/.config/qt6ct/
