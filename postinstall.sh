#!/bin/sh
#
# post install scripts
#

visudo
adduser $name wheel
su $name
cd ~
mkdir tl dl dx px vx ax mt
sudo setup-xorg-base
sudo apk add git make gcc g++ libx11-dev libxft-dev libxinerama-dev dbus-x11 firefox adwaita-gtk2-theme adwaita-icon-theme ttf-dejavu
cd tl
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st
#make edits as you see fit
cd dwm
sudo make clean install
cd ../dmenu
sudo make clean install
cd ../st
sudo make clean install
echo "feh --bg-fill ~/px/walls/wall.png &" > ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc
