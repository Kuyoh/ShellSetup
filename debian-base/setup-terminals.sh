#!/bin/bash

fontFile="Meslo LG M Regular Nerd Font Complete Mono.ttf"
fontFolder="/usr/local/share/fonts/meslo/"
fontArchiveUrl="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"

sudo apt-get update -q
sudo apt-get install -qy wget tilix jq moreutils

# install font
if [ ! -f "$fontFolder$fontFile" ]; then
    archive=$(tempfile -s .zip)
    trap 'rm -f $archive' EXIT
    wget $fontArchiveUrl -qO $archive
    sudo mkdir $fontFolder
    sudo unzip $archive "$fontFile" -d "$fontFolder"
fi

# configure vscode font
if command -v code &> /dev/null; then
    vscodeSettings=$(realpath ~/.config/Code/User/settings.json)
    jqFilter=".\"terminal.integrated.fontFamily\" = \"'MesloLGM Nerd Font Mono'\""
    jqFilter=".\"terminal.integrated.fontSize\" = 16 | $jqFilter"
    jq "$jqFiter" $vscodeSettings | sponge $vscodeSettings
fi

# configure tilix font
dconf write '/com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d/font' "'MesloLGM Nerd Font Mono 12'"

# set gnome default terminal
gsettings set org.gnome.desktop.default-applications.terminal exec tilix
