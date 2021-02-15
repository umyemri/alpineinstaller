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
# if you want to use the libuser package:
#echo 'http://mirror.math.princeton.edu/pub/alpinelinux/edge/testing/' >> /etc/apk/repositories
#apk update
#apk add libuser
#read -p 'user: ' uname
#read -sp 'pass: ' upass
#adduser $uname -p $upass -s /bin/zsh
# run visudo to add the proper passwd setting for wheel users.
#visudo
#addgroup $uname wheel
