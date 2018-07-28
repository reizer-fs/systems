#!/bin/bash

DATA_DRIVE="/data"
INSTALL_DIR="/opt/ffx"
TMUX_DIR="/etc/tmux.conf.d/"
ALL_DIR="${INSTALL_DIR} ${TMUX_DIR}"

apt-get -q update
apt-get -q install -y git vim docker.io tmux htop iotop virtualbox

mkdir -p $INSTALL_DIR
for i in systems scripts windows-client docker ; do 
	cd $INSTALL_DIR && git clone https://github.com/reizer-fs/$i.git &
done

# Custom peofile
rm ~/.bashrc ; ln -s $INSTALL_DIR/scripts/config_host/.bashrc ~/.bashrc
rm /root/.bashrc ; ln -s $INSTALL_DIR/scripts/config_host/.bashrc /root/.bashrc

for DIR in ${ALL_DIR} ; do
	[ ! -d "${DIR}" ] &&  mkdir ${DIR} 
done

# Tmux conf
[ ! -f /etc/tmux.conf.d/tmux.conf ] && ln -s $INSTALL_DIR/scripts/tmux/tmux.conf /etc/tmux.conf.d/tmux.conf

# Default Editor 
update-alternatives --config editor

# Git settings
git config --global push.default matching

git config --global user.email "sebastianpetrovich@gmail.com"
git config --global user.name "Sebastian Petrovich"

for DIR in Documents Downloads Pictures Music VM ; do
	[ ! -L "~/$DIR" ] && [ -d "/data/$DIR" ] && rm -rf ~/$DIR ; ln -s /data/$DIR ~/$DIR
	ls -d ~/$DIR
done

# Change Docker data dir to custom path
systemctl stop docker
[ ! -L "/var/lib/docker" ] && [ -d "/data/VM/LXC" ] && rm -rf /var/lib/docker ; ln -s /data/VM/LXC/ /var/lib/docker
systemctl daemon-reload
systemctl start docker

# Vmware enable proprietary 3D driver
#echo 'mks.gl.allowBlacklistedDrivers = "TRUE"' >> ~/.vmware/preferences

# Install kvm and libvirt packages
#apt-get install kvm qemu-kvm libvirt-bin virtinst spice-client-gtk gir1.2-spice-client-gtk-3.0

#Add common user to kvm group 
#usermod -a -G libvirtd fx
#usermod -a -G kvm fx

# Python commodities
apt install python-pip
pip install sphinx sphinx-autobuild

