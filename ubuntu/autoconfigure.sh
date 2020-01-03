#!/bin/bash

INSTALL_DIR="$HOME/Git/"

sudo apt-get -q update
sudo apt-get -q install -y openssh-server git vim tmux htop iotop

# Default Editor 
update-alternatives --config editor

# Git settings
git config --global push.default matching
git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

# ssh key generation
[[ ! -f "~/.ssh/id_rsa" ]] && ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Python commodities
sudo apt-get -q install -y python3 python3-pip python3-venv

# Create Ansible python env
ANSIBLE_VERSIONS="2.9"
for ansible_version in $ANSIBLE_VERSIONS ; do
	mkdir -p $HOME/Python/ansible-${ansible_version}
	python3 -m venv $HOME/Python/ansible-${ansible_version}
	echo "Please run the commands below: 
	. $HOME/Python/ansible-${ansible_version}
	pip3 install --upgrade pip ansible"
done
