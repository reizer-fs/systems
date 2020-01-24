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
echo "[info]: installing packages ..." && sudo apt-get -q install -y openssh-server git vim tmux htop iotop &>/dev/null

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

egrep -q '^AddKeysToAgent' ~/.ssh/config && sed -i 's/^AddKeysToAgent.*$/AddKeysToAgent yes/g' ~/.ssh/config || echo 'AddKeysToAgent yes' >> ~/.ssh/config
export SSH_AUTH_SOCK=/run/user/$(id -u)/systemd/ssh-agent.socket

# Default Editor 
sudo update-alternatives --config editor

# Git settings
git config --global push.default matching
git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

# ssh key generation
[[ ! -f "$HOME/.ssh/id_rsa" ]] && ssh-keygen -t rsa -b 4096
grep -qf ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys &>/dev/null || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Python commodities
sudo apt-get -q install -y python3 python3-pip python3-venv &>/dev/null

# Create Ansible python env
ANSIBLE_VERSIONS="2.9"
for ansible_version in $ANSIBLE_VERSIONS ; do
	mkdir -p $HOME/Python/ansible-${ansible_version}
	python3 -m venv $HOME/Python/ansible-${ansible_version}
	echo "Please run the commands below: 
	. $HOME/Python/ansible-${ansible_version}/bin/activate
	pip3 install --upgrade pip ansible"
done

for i in systems docker ansible windows-client ; do
	echo "Processing git repository: $i"
	[[ ! -d "$INSTALL_DIR/${i}" ]] && /usr/bin/git clone --origin origin git@github.com:reizer-fs/${i}.git $INSTALL_DIR/${i}
done
