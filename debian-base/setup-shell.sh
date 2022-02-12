#!/bin/bash

installUser=${1:-$USER}
homeDir=$(eval echo "~$installUser")
echo "Setting up oh-my-psh for $installUser in $homeDir"

omzFolder="$homeDir/.oh-my-zsh"
ompThemeFolder="$homeDir/.poshthemes"
ompTheme="practical-pure.omp.json"

# install dependencies
echo "--- Installing dependencies"
sudo apt-get update -q
sudo apt-get install -qy zsh wget unzip git

# install & configure oh-my-zsh
if [ ! -d "$omzFolder" ]; then
    CHSH='no' RUNZSH='no' sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-completions.git $omzFolder/custom/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $omzFolder/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $omzFolder/custom/plugins/zsh-autosuggestions
    sed -i "s/plugins=.git./plugins=(git dotnet pip npm docker docker-compose kubectl terraform dircycle command-not-found zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/" $homeDir/.zshrc
fi

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

    wget https://github.com/Kuyoh/ShellSetup/archive/refs/heads/main.zip -qO $archive
    unzip -j $archive "ShellSetup-main/themes/practical-pure.omp.json" -d $ompThemeFolder

    chmod u+rw $ompThemeFolder/*.json
    chown -R $installUser $ompThemeFolder
fi

isInteractiveShell="( ! -z \"$PS1\" )"

# configure zsh
if [ -z "$(grep $homeDir/.zshrc -e oh-my-posh)" ]; then 
    echo "--- Configuring oh-my-posh for zsh"

    # fix for omz/xterm-256, where home and end keys are not correctly mapped by default
    echo "if [[ \"\$TERM\" == \"xterm-256color\" ]]; then" >> $homeDir/.zshrc
    echo "    bindkey \"^[[H\" beginning-of-line" >> $homeDir/.zshrc
    echo "    bindkey \"^[[F\" end-of-line" >> $homeDir/.zshrc
    echo "fi" >> $homeDir/.zshrc

    # oh-my-posh initialization
    echo "eval \"\$(oh-my-posh --init --shell zsh --config $ompThemeFolder/$ompTheme)\"" >> $homeDir/.zshrc
    echo "enable_poshtransientprompt" >> $homeDir/.zshrc
    echo "enable_poshtooltips" >> $homeDir/.zshrc
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


if command -v pwsh &> /dev/null; then
    pwshProfile=$(pwsh -Command "echo \$PROFILE")
    if [ -z "$(grep $pwshProfile -e oh-my-posh)" ]; then
        mkdir -p $(dirname $pwshProfile)
        echo "--- Configuring oh-my-posh for pwsh"
        echo "oh-my-posh --init --shell pwsh --config $ompThemeFolder/$ompTheme | Invoke-Expression" >> $pwshProfile
        echo "Enable-PoshTransientPrompt" >> $pwshProfile
        echo "Enable-PoshTooltips" >> $pwshProfile
        chown -R $USER $pwshProfile
    fi
fi
