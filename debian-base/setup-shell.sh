#!/bin/bash

installUser=${1:-$USER}
homeDir=$(eval echo "~$installUser")
echo "Setting up oh-my-psh for $installUser in $homeDir"

ompThemeFolder="$homeDir/.poshthemes"
ompTheme="powerlevel10k_rainbow.omp.json"

# install dependencies
echo "--- Installing dependencies"
sudo apt-get update -q
sudo apt-get install -qy zsh wget unzip

# install oh-my-posh
if [ ! -f "/usr/local/bin/oh-my-posh" ]; then
    echo "--- Oh-My-Posh executable not found. Installing..."
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -qO /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
fi

# download the oh-my-posh themes
if [ ! -d "$ompThemeFolder" ]; then
    echo "--- Oh-My-Posh themes not found. Installing..."
    archive=$(tempfile -s .zip)
    trap 'rm -f $archive' EXIT
    mkdir $ompThemeFolder
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -qO $archive
    unzip $archive -d $ompThemeFolder
    chmod u+rw $ompThemeFolder/*.json
    chown -R $installUser $ompThemeFolder
fi

isInteractiveShell="( ! -z \"$PS1\" )"

# configure zsh
if [ -z "$(grep $homeDir/.zshrc -e oh-my-posh)" ]; then 
    echo "--- Configuring oh-my-posh for zsh"
    echo "eval \"\$(oh-my-posh --init --shell zsh --config $ompThemeFolder/$ompTheme)\"" >> $homeDir/.zshrc
    chown -R $USER $homeDir/.zshrc
fi
if [ $isInteractiveShell -a "$SHELL" = "/usr/bin/zsh" ]; then
    echo "--- Interactive zsh detected. Initializing theme"
    eval "$(oh-my-posh --init --shell zsh --config $ompThemeFolder/$ompTheme)"
fi

# configure bash
if [ -z "$(grep $homeDir/.bashrc -e oh-my-posh)" ]; then
    echo "--- Configuring oh-my-posh for bash"
    echo "eval \"\$(oh-my-posh --init --shell bash --config $ompThemeFolder/$ompTheme)\"" >> $homeDir/.bashrc
    chown -R $USER $homeDir/.bashrc
fi
if [ $isInteractiveShell -a "$SHELL" = "/bin/bash" ]; then
    echo "--- Interactive bash detected. Initializing theme"
    eval "$(oh-my-posh --init --shell bash --config $ompThemeFolder/$ompTheme)"
fi

