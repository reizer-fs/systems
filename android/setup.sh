#!/bin/bash
set -u

[[ "$EUID" == 0 ]] && echo "Must not be run as root." && exit 1

INSTALL_DIR="$HOME/git"
INSTALL_USER=$(id -un)

echo "[info]: installing packages ..." && pkg install -y git tmux python-pip python-cryptography rust vim &>/dev/null

# Default Editor 
BIN_VIM=$(type -p vim)
BIN_EDITOR=$(type -p editor)
update-alternatives --install $BIN_EDITOR editor $BIN_VIM 100
update-alternatives --set editor $BIN_VIM

# Git settings
/usr/bin/git config --global push.default matching
/usr/bin/git config --global user.email "sebastianpetrovich@gmail.com"
/usr/bin/git config --global user.name "Sebastian Petrovich"

# ssh key generation
[[ ! -f "$HOME/.ssh/id_ed25519" ]] && ssh-keygen -t ed25519 -b 4096
grep -qf ~/.ssh/id_ed25519.pub ~/.ssh/authorized_keys &>/dev/null || cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
[[ -f "$HOME/.ssh/config" ]] && chmod 644 ~/.ssh/config

chmod 700 ~/.ssh

while true ; do
    echo "[info]: public key is : "
    echo ""
    echo "$(cat ~/.ssh/id_ed25519.pub)"
    echo ""
    read -r -p "Is this key registered in the authorized ssh keys on github? [Y/n] " input

    case $input in
        [yY][eE][sS]|[yY])
        break ;;
        [nN][oO]|[nN])
        echo "No" ;;
        *)
        echo "Invalid input..." ;;
    esac
done

for i in systems ansible scripts ; do
    echo "[info]: cloning git repo $i ..."
    [[ ! -d "$INSTALL_DIR/${i}" ]] && git clone --origin origin git@github.com:reizer-fs/${i}.git $INSTALL_DIR/${i}
done

echo "[info]: creating python env for ansible..."
export ANDROID_API_LEVEL=35
export CARGO_BUILD_TARGET="$(rustc -vV | sed -n 's|host: ||p')"
rm -rf $HOME/projects/ansible && mkdir -p $HOME/projects/ansible && python3 -m venv $HOME/projects/ansible && . $HOME/projects/ansible/bin/activate && pip install --upgrade pip && pip install ansible
