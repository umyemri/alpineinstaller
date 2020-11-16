#!/bin/sh
#
# post install scripts
#
# this is only the most basic of setup. any configuration there after is on you.
# this assumes you have a wifi.conf made for wpa_supplicant

# user setup
wpa_supplicant -i wlan0 -c wifi.conf -B
udhcpcd -i wlan0

read -p 'user: ' uname
read -sp 'pass: ' upass
apk add dash
adduser -a -G video,audio,wheel $uname -p $upass -s dash
echo '$uname ALL=(ALL) NOPASSWD: ALL' >> ./$uname
mv ./$uname /etc/sudoers.d/
su $uname
cd ~

# make basic folder structure - these are my preferences
mkdir tl dl dx px vx ax mt .config
mkdir px/walls
wget https://unsplash.it/1920/1080?random -O ~/px/walls/wall.png

# dwm setup from source
sudo setup-xorg-base
sudo apk add git make gcc g++ libx11-dev libxft-dev libxinerama-dev dbus-x11 firefox adwaita-gtk2-theme adwaita-icon-theme ttf-dejavu
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
echo "feh --bg-fill ~/px/walls/wall.png &" > ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc

# install anything else you want at start up.
sudo apk add ranger w3m feh sxiv p7zip dosfstools exfat-utils wireguard-tools ip6tables libxinerama xrandr python3 py3-pip

# done
echo 'post install complete.'
echo 'this is a very basic setup. anything you might want to add is on you.'
echo 'good luck!'
