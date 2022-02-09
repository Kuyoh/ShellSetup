This repository contains script I use to configure my shells.
It relies mainly on oh-my-posh, zsh/bash/powershell.

# Installation
## Debian-base

For now this is tested only with Ubuntu/gnome, but it should apply to other debian-based distributions.
### Terminal setup

For your terminals to work with oh-my-posh themes, a nerdfont is required.
`debian-base/setup-terminals.sh` will install the recommended nerdfont and configure tilix, and configure vscode (if found in PATH).

```bash
wget https://raw.githubusercontent.com/Kuyoh/ShellSetup/main/debian-base/setup-terminals.sh -qO - | /bin/bash
```

### Shell setup

To configure your shells, simply execute `debian-base/setup-shell.sh`, it will install zsh and oh-my-posh and configure zsh and bash to run with the specified font.  
Note that this installation is user specific but also requires root priviliges. Therefore it optionally accepts a user name as argument, so that installation can be done for a different user.


```bash
wget https://raw.githubusercontent.com/Kuyoh/ShellSetup/main/debian-base/setup-shell.sh -qO - | /bin/bash
```