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
