#!/bin/zsh
#
# userspace.h

# wpa_supplicant -i wlan0 -c wifi.conf -B
# udhcpcd -i wlan0

mkdir tl dl dx px vx ax mt .config
mkdir px/walls
wget https://unsplash.it/1920/1080?random -O ~/px/walls/wall.png
echo "feh --bg-fill ~/px/walls/wall.png &" > ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc

# dwm setup from source
sudo setup-xorg-base
sudo apk add git make gcc g++ libx11-dev libxft-dev libxinerama-dev dbus-x11 firefox adwaita-gtk2-theme adwaita-icon-theme ttf-dejavu libxinerama xrandr
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
