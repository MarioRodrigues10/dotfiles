#!/usr/bin/env bash

#set -Eeuo pipefail

BASE_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")
cd "${BASE_DIR}/.." || exit 127

# shellcheck source=../scripts/extras.sh
. scripts/extras.sh
# shellcheck source=../scripts/utils.sh
. scripts/utils.sh

download_wallpapers() {
  mkdir -p ~/Pictures

  curl -o ~/Pictures/desktop.jpg "https://w0.peakpx.com/wallpaper/700/756/HD-wallpaper-man-is-standing-near-car-during-sunset-vaporwave.jpg"

  sudo cp ~/Pictures/desktop.jpg /usr/share/backgrounds/awesome_background.jpg
}

ask_for_sudo

install_package nitrogen

mkdir -p "$HOME/.config/nitrogen"

symlink "$HOME/.dotfiles/nitrogen/nitrogen.cfg" "$HOME/.config/nitrogen/nitrogen.cfg"
symlink "$HOME/.dotfiles/nitrogen/bg-saved.cfg" "$HOME/.config/nitrogen/bg-saved.cfg"

execute download_wallpapers "Downloading Wallpapers..."

