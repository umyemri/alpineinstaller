#!/bin/sh
#
# post install scripts
#
# basic packages suite.
# a lot of this is commented out. open up what you need

# tools i like
#apk add vim tmux

# wireless & network tools
# note on wireguard - this is only for basic security. they note that they are not quantum protected.
#apk add wpa_supplicant wireless-tools wireguard-tools wireguard-tools-doc iptables iptables-doc ip6tables

# disk handling & compression
#apk add p7zip dosfstools exfat-utils ntfs-3g blkid lsblk

# shells & sudo
#apk add zsh zsh-doc zsh-autosuggestions zsh-syntax-highlighting zsh-syntax-highlighting-doc sudo sudo-doc

# setting up a user
#read -p 'user: ' uname
#read -sp 'pass: ' upass
#adduser -a -G video,audio,wheel $uname -p $upass -s zsh
#echo '$uname ALL=(ALL) NOPASSWD: ALL' >> ./$uname
#mv ./$uname /etc/sudoers.d/
