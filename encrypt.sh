#!/bin/bash
#
# install alpine on a laptop
#
# usually the setup-alpine is enough to setup a basic partition system. but for
# my purposes, i want an encrypted volume as a modicum of security. only for
# threats that don't have nation state resources. abandon all hope to the
# rubberhose attack at that point.
#
# this script assumes a usb stick (/dev/sdb) installation on /dev/sda and you
# have booted to root and you're connected to an ethernet port.
#

read -p 'host: ' hname
echo 'auto eth0' > /etc/network/interfaces
echo 'iface eth0 inet dhcp' >> /etc/network/interfaces
ifup eth0
apk update
apk add cryptsetup sgdisk lvm2 dmcrypt boot mkdir # yeah... gnu but that {} method

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
modprobe dm_crypt
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
apk add --root=/mnt/ --initdb $(cat /etc/apk/world)
# add edge repo to /etc/apk/repositories & /mnt/root/etc/apk/repositories
apk add --root=/mnt/ chrony wireless-tools wpa_supplicant
apk add --root=/mnt/ grub mkinitfs e2fsprogs grub-bios grub-efi
apk add --root=/mnt/ dosfstools exfat-utils ntfs-3g
apk add --root=/mnt/ sudo vim tmux gotop ncurses ncdu
apk add --root=/mnt/ linux util-linux man man-pages mkdir
mount --bind /dev /mnt/dev
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc

# setup names, times, langs
chroot /mnt ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
chroot /mnt hwclock --systohc --utc
echo "en_US.UTF-8 UTF-8  " >> /mnt/etc/locale.gen
echo "ja_JP.UTF-8 UTF-8  " >> /mnt/etc/locale.gen
chroot /mnt locale-gen
echo "$hname" > /mnt/etc/hostname # finally using that variable /phew
chroot /mnt hostname -F /etc/hostname

# grub installation
chroot /mnt grub-install /dev/sda1
chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
echo 'done'
echo 'some manual configuration of the grub file will be needed.'
