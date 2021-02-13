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
read -p 'host: ' hname
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
apk add cryptsetup lvm2 e2fsprogs dosfstools parted
# a very long step. if you need a secure wipe, uncomment it
#apk add haveged
#rc-service haveged start
#haveged -n 0 | dd of=/dev/sda

# disk partitioning
#sgdisk -og /dev/sda # gpt partition erase
#sgdisk -z /dev/sda # zap all gpt records
#sgdisk -n 1:2048:+200MiB -t 1:ef00 /dev/sda
#start_of=$(sgdisk -f /dev/sda)
#end_of=$(sgdisk -E /dev/sda)
#sgdisk -n 2:$start_of:$end_of -t 2:8e00 /dev/sda
#sgdisk -p /dev/sda
parted -s -a optimal -- /dev/sda \
    mklabel msdos \
    mkpart primary 1MiB 100MiB \
    mkpart primary 100MiB 100%
parted /dev/sda set 1 boot on
# if the above doesn't work do it manually:
#parted -a optimal

# luks lvm
cryptsetup -v -c serpent-xts-plain64 -s 512 --hash whirlpool --iter-time 5000 --use-random luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 crypt
pvcreate --dataalignment 1m /dev/mapper/crypt
vgcreate volume /dev/mapper/crypt
lvcreate -L 2G volume -n boot
lvcreate -L 12GB volume -n swap 
lvcreate -l 100%FREE volume -n root
modprobe dm_mod
modprobe dm_crypt
vgscan
vgchange -ay

# vg file system
#mkfs.fat -F32 /dev/sda1 # grub boot only
mkfs.ext4 /dev/sda1 # syslinux boot only
mkfs.ext4 /dev/volume/root
mkfs.ext4 /dev/volume/boot
mkswap /dev/volume/swap && swapon /dev/volume/swap
mount -t ext4 /dev/volume/root /mnt
mkdir /mnt/boot
# grub commands
#mount -t ext4 /dev/volume/boot /mnt/boot
#mkdir /mnt/boot/efi
#mount -t vfat /dev/sda1 /mnt/boot/efi
mount -t ext4 /dev/sda1 /mnt/boot # syslinux boot only

# alpine installation
setup-disk -m sys /mnt

# fstab / crypttab / mkinitfs setup
blkid -s UUID -o value /dev/sda2 > ~/uuid
echo "lvmcrypt    UUID=$(cat ~/uuid)    none    luks" > /mnt/etc/crypttab
echo "/dev/volume/swap    swap    swap    defaults    0 0" >> /mnt/etc/fstab
sed -i "s/lvm/lvm cryptsetup/" /mnt/etc/mkinitfs/mkinitfs.conf
mkinitfs -c /mnt/etc/mkinitfs/mkinitfs.conf -b /mnt/ $(ls /mnt/lib/modules/)

# grub on uefi setup - not working trying syslinux now
#mount -t proc /proc /mnt/proc
#mount --rbind /dev /mnt/dev
#mount --make-rslave /mnt/dev
#mount --rbind /sys /mnt/sys
#chroot /mnt apk add grub grub-efi efibootmgr
#chroot /mnt apk del syslinux
#echo 'GRUB_ENABLE_CRYPTODISK=y' >> /mnt/etc/default/grub
#echo "GRUB_CMDLINE_LINUX_DEFAULT=\"cryptroot=UUID=$(cat ~/uuid) cryptdm=lvmcrypt\"" >> /mnt/etc/default/grub
#chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi
#chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# syslinux
apk add syslinux
sed -i "s/rootfstype=ext4/rootfstype=ext4 cryptroot=UUID=$(cat ~/uuid) cryptdm=lvmcrypt/" /mnt/etc/update-extlinux.conf 
chroot /mnt/ update-extlinux
dd bs=440 count=1 conv=notrunc if=/mnt/usr/share/syslinux/mbr.bin of=/dev/sda

wget https://raw.githubusercontent.com/umyemri/alpineinstaller/master/installer/postinstall.sh -O /mnt/root/postinstall.sh

echo 'done.'
