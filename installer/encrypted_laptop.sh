#!/bin/sh
#
# install alpine on a laptop
# 
# runtime: 4 - 5 minutes
#
# usually the setup-alpine is enough to setup a basic partition system. but for
# my purposes, i want an encrypted volume as a modicum of security. only for
# threats that don't have nation state resources. abandon all hope to the
# rubberhose attack at that point.
#
# this script assumes a usb stick (/dev/sdb) installation on /dev/sda, you
# have booted to root and you're connected to an ethernet port.
#

# my assumption is, you somehow downloaded this script. so...
#echo 'iface eth0 inet dhcp' > /etc/network/interfaces
#ifup eth0

# starter prompts / repo setup
read -p 'host: ' hname
read -p 'swap (_GB): ' swaps
setup-keymap us us
setup-hostname $hname
setup-timezone -z US/Pacific
rc-update add networking boot
rc-update add urandom boot
rc-update add acpid default
rc-service acpid start
sed -i "s/localhost localhost.localdomain/$hname $hname.localdomain localhost localhost.localdomain" /etc/hosts
echo 'http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories
echo 'http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
apk update && apk upgrade
apk add cryptsetup lvm2 e2fsprogs parted

# disk partitioning
parted -s -a optimal -- /dev/sda \
    mklabel msdos \
    mkpart primary 1MiB 512MiB \
    mkpart primary 512MiB 100%
parted /dev/sda set 1 boot on

# encypted volume setup
cryptsetup -v -c serpent-xts-plain64 -s 512 --hash whirlpool --iter-time 5000 --use-random luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 crypt
pvcreate --dataalignment 1m /dev/mapper/crypt
vgcreate volume /dev/mapper/crypt
lvcreate -L $(swaps)GB volume -n swap 
lvcreate -l 100%FREE volume -n root
modprobe dm_mod
modprobe dm_crypt
#vgscan
vgchange -ay

# format all the things
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/volume/root
mkswap /dev/volume/swap
swapon /dev/volume/swap
mount -t ext4 /dev/volume/root /mnt
mkdir /mnt/boot
mount -t ext4 /dev/sda1 /mnt/boot 

# alpine installation
setup-disk -m sys /mnt

# fstab / crypttab / mkinitfs setup
blkid -s UUID -o value /dev/sda2 > ~/uuid
echo "lvmcrypt    UUID=$(cat ~/uuid)    none    luks" > /mnt/etc/crypttab
echo "/dev/volume/swap    swap    swap    defaults    0 0" >> /mnt/etc/fstab
sed -i "s/lvm/lvm cryptsetup/" /mnt/etc/mkinitfs/mkinitfs.conf
mkinitfs -c /mnt/etc/mkinitfs/mkinitfs.conf -b /mnt/ $(ls /mnt/lib/modules/)

# syslinux
apk add syslinux
sed -i "s/rootfstype=ext4/rootfstype=ext4 cryptroot=UUID=$(cat ~/uuid) cryptdm=lvmcrypt/" /mnt/etc/update-extlinux.conf 
chroot /mnt/ update-extlinux
dd bs=440 count=1 conv=notrunc if=/mnt/usr/share/syslinux/mbr.bin of=/dev/sda

echo 'done. chroot /mnt passwd when you get a chance. then reboot.'
