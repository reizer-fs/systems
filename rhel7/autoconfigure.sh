#!/bin/bash

INSTALL_DIR="/opt/ffx"

yum update
yum -y install git
yum -y install vim
yum -y install docker.io
yum -y install tmux
yum -y install iotop

mkdir -p $INSTALL_DIR
for i in systems scripts windows-client docker vim misc kvm; do 
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
#echo 'mks.gl.allowBlacklistedDrivers = "TRUE"' >> ~/.vmware/preferences

# Install kvm and libvirt packages
#yum install kvm qemu-kvm libvirt-bin virtinst spice-client-gtk gir1.2-spice-client-gtk-3.0

#Add common user to kvm group 
usermod -a -G libvirtd fx
usermod -a -G kvm fx

# Enable services 
systemctl enable docker
systemctl restart docker
systemctl daemon-reload
