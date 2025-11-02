#!/bin/bash
set -e

cd /usr/local/share/nfl-clock/raspberry-pi

alacritty --config-file ./alacritty.toml --command "./start.sh"
