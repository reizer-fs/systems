#!/bin/bash

INSTALL_DIR="$HOME/Git"

sudo apt-get -q update &>/dev/null
sudo apt-get -q install -y openssh-server git vim tmux htop iotop &>/dev/null

# Default Editor 
sudo update-alternatives --config editor

# Git settings
git config --global push.default matching
git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

# ssh key generation
[[ ! -f "$HOME/.ssh/id_rsa" ]] && ssh-keygen -t rsa -b 4096
grep -qf ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

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
