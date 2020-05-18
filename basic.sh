#!/bin/bash
#
# this might largely be meaningless as the setup-alpine gets the bulk of the 
# work done. 

# grab the standard x86_64 image
# write it to a usb stick
# plugin and power up
# login as root

setup-alpine

# choose the usual
# reboot
# change the repo to add community

apk update

# add the usual
apk add sudo vim htop tmux ranger feh wireguard ip6tables
visudo
adduser name wheel
su name
mkdir tl dl dx px vx ax mt
sudo setup-xorg-base
sudo apk add git make gcc g++ libx11-dev libxft-dev libxinerama-dev ncurses dbus-x11 firefox-esr adwaita-gtk2-theme adwaita-icon-theme ttf-dejavu
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

