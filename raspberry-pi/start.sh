#!/bin/bash
set -e

# Ensure network connection is set up
alacritty --config-file ./alacritty.toml --command "./configure-networking.sh"

# Start the app
../src-tauri/target/release/bundle/appimage/nfl-clock_0.1.0_aarch64.AppImage
