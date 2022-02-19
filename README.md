This repository contains script I use to configure my shells.
It relies mainly on instlaling and configuring oh-my-posh, oh-mz-zsh/bash/powershell.

# Installation
## Terminal setup
### Linux

The linux terminal setup is currently designed and tested only for Ubuntu/Gnome.

For your terminals to work with oh-my-posh themes, a nerdfont is required.
`linux/setup-terminals-ubuntu.sh` will install the recommended font and configure tilix as well as vscode (if found in PATH).

```bash
wget https://raw.githubusercontent.com/Kuyoh/ShellSetup/main/linux/setup-terminals.sh -qO - | /bin/bash
```

## Shell setup

### Linux

To configure your shells, simply execute `linux/setup-shell.sh`, it will install zsh and oh-my-posh and configure zsh, bash, and powershell (if found in PATH) to run the oh-my-posh theme.
Note that this installation is user specific but also requires root priviliges. Therefore it optionally accepts a user name as argument, so that installation can be done for a different user.

```bash
wget https://raw.githubusercontent.com/Kuyoh/ShellSetup/main/linux/setup-shell.sh -qO - | /bin/bash
```