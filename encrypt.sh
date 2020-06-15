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

# may not be needed if you somehow downloaded this script...
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
apk add cryptsetup sgdisk lvm2 e2fsprogs dosfstools haveged
# potentially a very long step. if you need a secure wipe, uncomment it
#rc-service haveged start
#haveged -n 0 | dd of=/dev/sda

# disk partitioning
sgdisk -og /dev/sda
sgdisk -n 1:2048:+200MiB -t 1:ef00 /dev/sda
start_of=$(sgdisk -f /dev/sda)
end_of=$(sgdisk -E /dev/sda)
sgdisk -n 2:$start_of:$end_of -t 2:8e00 /dev/sda
sgdisk -p /dev/sda

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
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/volume/root
mkfs.ext4 /dev/volume/boot
mkswap /dev/volume/swap && swapon /dev/volume/swap
mount -t ext4 /dev/volume/root /mnt
mkdir /mnt/boot
mount -t ext4 /dev/volume/boot /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat /dev/sda1 /mnt/boot/efi

# alpine installation
setup-disk -m sys /mnt

# fstab / crypttab / mkinitfs setup
blkid -s UUID -o value /dev/sda2 > ~/uuid
cp ~/uuid /mnt/root/
echo "lvmcrypt    UUID=$(cat ~/uuid)    none    luks" > /mnt/etc/crypttab
echo "/dev/volume/swap    swap    swap    defaults    0 0" >> /mnt/etc/fstab
sed -i "s/lvm/lvm cryptsetup/" /mnt/etc/mkinitfs/mkinitfs.conf
mkinitfs -c /mnt/etc/mkinitfs/mkinitfs.conf -b /mnt/ $(ls /mnt/lib/modules/)

# grub on uefi setup
mount -t proc /proc /mnt/proc
mount --rbind /dev /mnt/dev
mount --make-rslave /mnt/dev
mount --rbind /sys /mnt/sys
chroot /mnt
source /etc/profile
export PS1="(chroot) $PS1"
apk add grub grub-efi efibootmgr
apk del syslinux
echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"cryptroot=UUID=$(cat /root/uuid) cryptdm=lvmcrypt" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
exit

echo 'done.'
