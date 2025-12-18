
#!/bin/bash
set -u

[[ "$EUID" == 0 ]] && echo "Must not be run as root." && exit 1

INSTALL_DIR="$HOME/Git"
INSTALL_USER=$(id -un)

# Add current user to sudoers
sudo rm -rf /etc/sudoers.d/$INSTALL_USER &>/dev/null

echo "User_Alias     ADMINISTRATORS=$INSTALL_USER
ADMINISTRATORS ALL=(ALL) NOPASSWD:ALL
%ADMINISTRATORS ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$INSTALL_USER &>/dev/null

echo "[info]: refreshing yum cache ..." && sudo zypper clean all &>/dev/null
echo "[info]: creating ssh agent service ..." 
mkdir -p ~/.config/systemd/user &>/dev/null
cat << EOF > ~/.config/systemd/user/ssh-agent-$(id -un).service
[Unit]
Description=SSH key agent
[Service]
Type=simple
ExecStart=/bin/sh -c "/usr/bin/ssh-agent -D -a /run/user/\$\$(id -u)/systemd/ssh-agent.socket"
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload &>/dev/null
systemctl --user enable ssh-agent-$(id -un) &>/dev/null
systemctl --user start ssh-agent-$(id -un) &>/dev/null

[[ -f "$HOME/.ssh/config" ]] && egrep -q '^AddKeysToAgent' ~/.ssh/config &>/dev/null && sed -i 's/^AddKeysToAgent.*$/AddKeysToAgent yes/g' ~/.ssh/config || echo 'AddKeysToAgent yes' >> ~/.ssh/config
export SSH_AUTH_SOCK=/run/user/$(id -u)/systemd/ssh-agent.socket

# Default Editor 
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100
sudo update-alternatives --set editor /usr/bin/vim

# Git settings
/usr/bin/git config --global push.default matching
/usr/bin/git config --global user.email "sebastianpetrovich@gmail.com"
/usr/bin/git config --global user.name "Sebastian Petrovich"

# ssh key generation
[[ ! -f "$HOME/.ssh/id_rsa" ]] && ssh-keygen -t rsa -b 4096
grep -qf ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys &>/dev/null || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
[[ -f "$HOME/.ssh/config" ]] && chmod 644 ~/.ssh/config

chmod 700 ~/.ssh
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

for i in systems docker ansible windows-client scripts kickstart ; do
    echo "[info]: cloning git repo $i ..."
    [[ ! -d "$INSTALL_DIR/${i}" ]] && /usr/bin/git clone --origin origin git@github.com:reizer-fs/${i}.git $INSTALL_DIR/${i}
done

echo "[info]: installing python ..." && sudo zypper install -y python3 python3-pip

echo "[info]: done."
ansible-galaxy collection install community.libvirt
ansible-galaxy collection install community.general
ansible-galaxy collection install containers.podman
ansible-galaxy collection install posix.firewalld
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.crypto


# Enable masquerade to NAT KVM traffic on private network
#echo 1 > /proc/sys/net/ipv4/ip_forward
#iptables -A FORWARD -i br-nodes -o wlan0 -j ACCEPT
#iptables -A FORWARD -i wlan0 -o br-nodes -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
#firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i br-nodes -j ACCEPT
#firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -o br-nodes -j ACCEPT
#firewall-cmd --reload
