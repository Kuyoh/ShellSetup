#!/bin/bash

scriptPath=$0
function printUsage {
    echo "Usage: setup-shell.sh [USER]"
    echo "    USER the user for which to configure the shell"
}
function error {
    echo "ERROR: $scriptPath: $1" >&2
    exit 1
}
function errorAndUsage {
    echo "ERROR: $scriptPath: $1" >&2
    printUsage
    exit 1
}
function userDoesntExist {
    if id -u $1 &> /dev/null; then return 1; else return 0; fi
}
function rcNeedsConfiguration {
    if test ! -f "$1"; then return; fi
    test -z "$(grep $1 -e oh-my-posh)"
}

installUser=${1:-$USER}
if [[ "$installUser" == "" ]]; then
    errorAndUsage "a user must be specified for which to configure the shell"
fi
if userDoesntExist $installUser; then
    errorAndUsage "the specified user does not exist"
fi

sudoCmd="sudo"
if [[ "$USER" == "root" || "$EUID" -eq 0 ]]; then
    sudoCmd=""
elif command -v sudo &> /dev/null; then
    if groups | grep sudo &> /dev/null; then
        sudoCmd="sudo"
    else
        error "the script must be executed by root, or a user in the sudo group"
    fi
else
    error "the script must be executed by root"
fi

homeDir=$(eval echo "~$installUser")
echo "Setting up oh-my-psh for $installUser in $homeDir"

omzFolder="$homeDir/.oh-my-zsh"
ompThemeFolder="$homeDir/.poshthemes"
ompTheme="practical-pure.omp.json"

# install dependencies
echo "--- Installing dependencies"
if command -v apt-get &> /dev/null; then
    $sudoCmd apt-get update -q
    if [[ $? -ne 0 ]]; then error "apt update failed"; fi
    $sudoCmd apt-get install -qy zsh wget unzip git
    if [[ $? -ne 0 ]]; then error "dependency installation failed"; fi
elif command -v apk &> /dev/null; then
    $sudoCmd apk --no-cache add zsh wget unzip git
    if [[ $? -ne 0 ]]; then error "dependency installation failed"; fi
elif command -v yum &> /dev/null; then
    $sudoCmd yum install -qy zsh wget unzip git
    if [[ $? -ne 0 ]]; then error "dependency installation failed"; fi
elif command -v pacman &> /dev/null; then
    $sudoCmd pacman -Sy --noconfirm zsh wget unzip git
    if [[ $? -ne 0 ]]; then error "dependency installation failed"; fi
elif command -v emerge &> /dev/null; then
    $sudoCmd emerge -q zsh wget unzip dev-vcs/git
    if [[ $? -ne 0 ]]; then error "dependency installation failed"; fi
else
    error "no compatible package manager found"
fi

# install & configure oh-my-zsh
if [ ! -d "$omzFolder" ]; then
    CHSH='no' RUNZSH='no' sh -c "$(wget -O - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [[ $? -ne 0 ]]; then error "oh-my-zsh installation failed"; fi
    git clone https://github.com/zsh-users/zsh-completions.git $omzFolder/custom/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $omzFolder/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $omzFolder/custom/plugins/zsh-autosuggestions
    sed -i "s/plugins=.git./plugins=(git dotnet pip npm docker docker-compose kubectl terraform dircycle command-not-found zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/" $homeDir/.zshrc
fi

# install oh-my-posh
if [ ! -f "/usr/local/bin/oh-my-posh" ]; then
    echo "--- Oh-My-Posh executable not found. Installing..."
    $sudoCmd wget -qO /usr/local/bin/oh-my-posh https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64
    if [[ $? -ne 0 ]]; then error "oh-my-posh installation failed"; fi
    $sudoCmd chmod +x /usr/local/bin/oh-my-posh
fi

# download the oh-my-posh themes
if [ ! -d "$ompThemeFolder" ]; then
    echo "--- Oh-My-Posh themes not found. Installing..."
    archive="$(mktemp -u).zip"
    trap 'rm -f $archive' EXIT
    mkdir $ompThemeFolder
    wget -qO $archive https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip
    unzip $archive -d $ompThemeFolder

    wget -qO $archive https://github.com/Kuyoh/ShellSetup/archive/refs/heads/main.zip
    unzip -j $archive "ShellSetup-main/themes/practical-pure.omp.json" -d $ompThemeFolder

    chmod u+rw $ompThemeFolder/*.json
    chown -R $installUser $ompThemeFolder
fi

isInteractiveShell="( ! -z \"$PS1\" )"

# configure zsh
if rcNeedsConfiguration "$homeDir/.zshrc"; then 
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
    chown -R $installUser $homeDir/.zshrc
fi
if [[ $isInteractiveShell && "$SHELL" == *"/zsh" ]]; then
    echo "--- Interactive zsh detected. Initializing theme"
    eval "$(oh-my-posh --init --shell zsh --config $ompThemeFolder/$ompTheme)"
fi

# configure bash
if rcNeedsConfiguration "$homeDir/.bashrc"; then 
    echo "--- Configuring oh-my-posh for bash"
    echo "eval \"\$(oh-my-posh --init --shell bash --config $ompThemeFolder/$ompTheme)\"" >> $homeDir/.bashrc
    chown -R $installUser $homeDir/.bashrc
fi
if [ $isInteractiveShell -a "$SHELL" = "/bin/bash" ]; then
    echo "--- Interactive bash detected. Initializing theme"
    eval "$(oh-my-posh --init --shell bash --config $ompThemeFolder/$ompTheme)"
fi


if command -v pwsh &> /dev/null; then
    pwshProfile=$(pwsh -Command "echo \$PROFILE")
    if [[ -f "$pwshProfile" || -z "$(grep $pwshProfile -e oh-my-posh)" ]]; then
        mkdir -p $(dirname $pwshProfile)
        echo "--- Configuring oh-my-posh for pwsh"
        echo "oh-my-posh --init --shell pwsh --config $ompThemeFolder/$ompTheme | Invoke-Expression" >> $pwshProfile
        echo "Enable-PoshTransientPrompt" >> $pwshProfile
        echo "Enable-PoshTooltips" >> $pwshProfile
        chown -R $installUser $pwshProfile
    fi
fi
