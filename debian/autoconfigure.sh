#!/bin/bash

[[ "$EUID" == 0 ]] && echo "Must not be run as root." && exit 1

INSTALL_DIR="$HOME/Git"
INSTALL_USER=$(id -un)

# Add current user to sudoers
sudo rm -rf /etc/sudoers.d/$INSTALL_USER &>/dev/null

echo "User_Alias     ADMINISTRATORS=$INSTALL_USER
ADMINISTRATORS ALL=(ALL) NOPASSWD:ALL
%ADMINISTRATORS ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$INSTALL_USER &>/dev/null

echo "[info]: refreshing apt cache ..." && sudo apt-get -q update &>/dev/null
echo "[info]: installing packages ..." && sudo apt-get -q install -y openssh-server git vim-nox tmux htop iotop &>/dev/null

echo "[info]: creating ssh agent service ..." 
mkdir -p ~/.config/systemd/user &>/dev/null
cat << EOF > ~/.config/systemd/user/ssh-agent-$(id -un).service
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=/run/user/$(id -u)/systemd/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a \$SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload &>/dev/null
systemctl --user enable ssh-agent-$(id -un) &>/dev/null
systemctl --user start ssh-agent-$(id -un) &>/dev/null

egrep -q '^AddKeysToAgent' ~/.ssh/config &>/dev/null && sed -i 's/^AddKeysToAgent.*$/AddKeysToAgent yes/g' ~/.ssh/config || echo 'AddKeysToAgent yes' >> ~/.ssh/config
export SSH_AUTH_SOCK=/run/user/$(id -u)/systemd/ssh-agent.socket

# Default Editor 
sudo update-alternatives --set editor /usr/bin/vim.nox

# Git settings
git config --global push.default matching
git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

# ssh key generation
[[ ! -f "$HOME/.ssh/id_rsa" ]] && ssh-keygen -t rsa -b 4096
grep -qf ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys &>/dev/null || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


while true ; do
    echo "[info]: public key is : "
    echo ""
    echo "$(cat ~/.ssh/id_rsa.pub)"
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

for i in systems docker ansible windows-client ; do
    echo "[info]: cloning git repo $i ..." && sudo apt-get -q install -y python3 python3-pip python3-venv &>/dev/null
    [[ ! -d "$INSTALL_DIR/${i}" ]] && /usr/bin/git clone --origin origin git@github.com:reizer-fs/${i}.git $INSTALL_DIR/${i} &>/dev/null
done

echo "[info]: installing python ..." && sudo apt-get -q install -y python3 python3-pip python3-venv &>/dev/null

echo "[info]: creating python env for ansible..."
mkdir -p $HOME/Python/ansible-2.9
python3 -m venv $HOME/Python/ansible-2.9
echo "[info]: done."
echo "[info]: Please run the command: . $HOME/Python/ansible-2.9/bin/activate && pip3 install --upgrade pip ansible"
