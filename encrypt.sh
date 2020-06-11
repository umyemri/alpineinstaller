#!/bin/bash
#
# install alpine on a laptop - with basic encryption
#
# usually the setup-alpine is enough to setup a basic partition system. but for
# my purposes, i want an encrypted volume as a modicum of security. only for
# threats that don't have nation state resources. abandon all hope to the
# rubberhose attack at that point.
#
# this script assumes a usb stick (/dev/sdb) installation on /dev/sda and you
# have booted to root and you've generated a wpa_passphrase to wifi.conf
#

wpa_supplicant -i wlan0 -c wifi.conf -B
udhcpc -i wlan0
apk update
apk add cryptsetup sgdisk lvm2 dmcrypt boot

# disk partitioning
sgdisk -og /dev/sda
sgdisk -n 1:2048:+200MiB -t 1:ef00 /dev/sda
start_of=$(sgdisk -f /dev/sda)
end_of=$(sgdisk -E /dev/sda)
sgdisk -n 2:$start_of:$end_of -t 2:8e00 /dev/sda
sgdisk -p /dev/sda

# luks lvm
cryptsetup luksFormat /dev/sda2
cryptsetup open --type luks /dev/sda2 lvm
pvcreate --dataalignment 1m /dev/mapper/lvm
vgcreate volume /dev/mapper/lvm
lvcreate -L 20GB volume -n root
lvcreate -L 12GB volume -n swap # might be excessive?
lvcreate -l 100%FREE volume -n home
modprobe dm_mod
vgscan
vgchange -ay

# vg file system
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/volume/root
mkfs.ext4 /dev/volume/home
mkswap /dev/volume/swap && swapon /dev/volume/swap
mount /dev/volume/root /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
mount /dev/volume/home /mnt/home

# alpine installation
apk add --root=/mnt/root --initdb $(cat /etc/apk/world)
# add edge repo to /etc/apk/repositories & /mnt/root/etc/apk/repositories
apk add --root=/mnt/root dhcpcd chrony wireless-tools wpa_supplicant
apk add --root=/mnt/root grub mkinitfs e2fsprogs grub-bios grub-efi
apk add --root=/mnt/root dosfstools exfat-utils
apk add --root=/mnt/root sudo vim tmux gotop ncurses ncdu
apk add --root=/mnt/root linux
mount --bind /dev /mnt/root/dev
mount --bind /sys /mnt/root/sys
cp /etc/reslov.conf /mnt/root/etc
chroot /mnt ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
chroot /mnt hwclock --systohc --utc
