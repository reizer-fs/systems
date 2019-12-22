#!/bin/bash

INSTALL_DIR="$HOME/Git/"

sudo apt-get -q update
sudo apt-get -q install -y openssh-server git vim docker.io tmux htop iotop

# Default Editor 
update-alternatives --config editor

# Git settings
git config --global push.default matching
git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

# Change Docker data dir to custom path
#systemctl stop docker
#[ ! -L "/var/lib/docker" ] && [ -d "/data/VM/LXC" ] && rm -rf /var/lib/docker ; ln -s /data/VM/LXC/ /var/lib/docker
#systemctl daemon-reload
#systemctl start docker

# ssh key generation
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Vmware enable proprietary 3D driver
#echo 'mks.gl.allowBlacklistedDrivers = "TRUE"' >> ~/.vmware/preferences

# Install kvm and libvirt packages
#apt-get install kvm qemu-kvm libvirt-bin virtinst spice-client-gtk gir1.2-spice-client-gtk-3.0

#Add common user to kvm group 
#usermod -a -G libvirtd $(id -un)
#usermod -a -G kvm $(id -un)

# Python commodities
sudo apt install python3 python3-pip python3-venv

# Create Ansible python env
ANSIBLE_VERSIONS="2.9"
for ansible_version in $ANSIBLE_VERSIONS ; do
	mkdir -p $HOME/Python/ansible-${ansible_version}
	python3 -m venv $HOME/Python/ansible-${ansible_version}
done
