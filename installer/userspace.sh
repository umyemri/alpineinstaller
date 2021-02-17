#!/bin/zsh
#
# userspace.sh
# 
# meant to run from a user with sudo wheel abilities.
#

# wpa_supplicant -i wlan0 -c wifi.conf -B
# udhcpcd -i wlan0

# install anything else you want at start up.
sudo apk add ranger w3m feh sxiv python3 py3-pip neofetch newsboat

mkdir tl dl dx px vx ax mt .config
mkdir px/walls
wget https://unsplash.it/1920/1080?random -O ~/px/walls/wall.png
echo "feh --bg-fill ~/px/walls/wall.png &" > ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc

# some fonts - ttf-dejavu is needed for the dwm compile process below.
sudo apk add ttf-dejavu terminus-font font-noto font-noto-cjk font-noto-cjk-extra font-noto-emoji

# dwm setup from source
sudo setup-xorg-base
sudo apk add git make gcc g++ libx11-dev libxft-dev libxinerama-dev dbus-x11 firefox adwaita-gtk2-theme adwaita-icon-theme libxinerama xrandr
cd tl
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st
git clone https://git.suckless.org/dwmstatus
cd dwm
sudo make clean install
cd ../dmenu
sudo make clean install
cd ../st
sudo make clean install

# audio
sudo apk add alsa-utils alsa-utils-doc alsa-lib alsaconf
sudo rc-service alsa start
sudo rc-update add alsa
# later you might need to restart
#sudo alsactl restore
#sudo alsactl init

# some networking
sudo cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback 
  
iface eth0 inet dhcp
iface eth0 inet6 dhcp

iface wlan0 inet dhcp
    pre-up wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wifi.conf -B
    post-down wpa_cli terminate
iface wlan0 inet6 dhcp
    
iface wg0 inet static
    # replace with proper IP
    address 10.0.2.1/24
    pre-up ip link add wg0 type wireguard
    pre-up wg setconf wg0 /etc/wireguard/server.conf
    post-up sysctl --write net.ipv4.ip_forward=1
    post-down sysctl --write net.ipv4.ip_forward=1
iface wg0 inet6 static
    # replace with proper IP
    address fc00:23:5::1/64
    # not ipv6?
    post-up sysctl --write net.ipv4.conf.all.forwarding=1
    post-down sysctl --write net.ipv4.conf.all.forwarding=0

EOF
