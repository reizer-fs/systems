############# First Method ############
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-enp1s0
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="enp1s0"
UUID="d5f41bf4-de0a-43b3-b633-7e2ec6212e58"
DEVICE="enp1s0"
ONBOOT="yes"
IPADDR=192.168.122.66
PREFIX=24
GATEWAY=192.168.122.1
DNS1=192.168.122.1
EOF

sudo nmcli connection down enp1s0 && sudo nmcli connection up enp1s0


############# Second Method ##############
sudo nmcli connection modify enp1s0 IPv4.address X.X.X.X/24
sudo nmcli connection modify enp1s0 IPv4.gateway 192.168.122.1
sudo nmcli connection modify enp1s0 IPv4.dns 192.168.122.1
sudo nmcli connection modify enp1s0 IPv4.method manual

############# Wireless connexion ##############
nmcli c add type wifi con-name <name> ifname wlan0 ssid <ssid>
nmcli c modify <name> wifi-sec.key-mgmt wpa-psk wifi-sec.psk <password>
