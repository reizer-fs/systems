#!/bin/bash

INSTALL_DIR="/opt/ffx"

apt-get update
apt-get -y install git
apt-get -y install vim
apt-get -y install docker.io
apt-get -y install tmux
apt-get -y install htop
apt-get -y install iotop

mkdir -p $INSTALL_DIR
for i in systems scripts windows-client docker ; do 
	cd $INSTALL_DIR && git clone https://github.com/reizer-fs/$i.git &
done

rm ~/.bashrc ; ln -s $INSTALL_DIR/scripts/config_host/.bashrc ~/.bashrc
rm /root/.bashrc ; ln -s $INSTALL_DIR/scripts/config_host/.bashrc /root/.bashrc

mkdir /etc/tmux.conf.d/
ln -s $INSTALL_DIR/scripts/tmux/tmux.conf /etc/tmux.conf.d/tmux.conf

# Default Editor 
update-alternatives --config editor

# Git settings
git config --global push.default matching

git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

# Vmware enable proprietary 3D driver
echo 'mks.gl.allowBlacklistedDrivers = "TRUE"' >> ~/.vmware/preferences

# Install kvm and libvirt packages
apt-get install kvm qemu-kvm libvirt-bin virtinst spice-client-gtk gir1.2-spice-client-gtk-3.0

#Add common user to kvm group 
usermod -a -G libvirtd fx
usermod -a -G kvm fx

