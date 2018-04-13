#!/bin/bash

loadkeys() { return; }
timedatectl() {
    echo "                      Local time: Thu 2018-04-12 18:22:58 CEST"
    echo "                  Universal time: Thu 2018-04-12 16:22:58 UTC"
    echo "                        RTC time: Thu 2018-04-12 16:22:58"
    echo "                       Time zone: Europe/Zurich (CEST, +0200)"
    echo "       System clock synchronized: yes"
    echo "systemd-timesyncd.service active: yes"
    echo "                 RTC in local TZ: no"
    return;
}
lsblk() {
    echo "NAME   TYPE FSTYPE  LABEL             SIZE MOUNTPOINT HOTPLUG"
    echo "sda    disk                           128G                  0"
    echo "|-sda1 part swap                        4G [SWAP]           0"
    echo "\`-sda2 part ext4                      124G /                0"
    echo "sdc    disk                          14.4G                  1"
    echo "\`-sdc1 part ntfs    16GB-Patriot-Tab 14.4G                  1"
    echo "sr0    rom  iso9660 ARCH_201804       556M                  1"
}
ls() { return; }
locale-gen() { return; }
pacstrap() {
    echo "Installing..."
    return
}
genfstab() { return; }
fstab_file="/dev/null"
cp() { return; }
ln() { return; }
hwclock() { return; }
ip() { return; }
pacman() { return; }
mkinitcpio() { return; }
visudo() { return; }
sh() { return; }
mkdir() { return; }
useradd() { return; }
sudo() { return; }
git() { return; }
makepkg() { return; }

#AUR-helpers:
aurman() { return; }
aurutils() { return; }
bauerbill() { return; }
pakku() { return; }
pikaur() { return; }
PKGBUILDer() { return; }
auracle-git() { return; }
package-query() { return; }
repoctl() { return; }
trizen() { return; }
yay() { return; }
naaman() { return; }
aura() { return; }
pbget() { return; }
yaah() { return; }
aurel-git() { return; }
cower() { return; }
pacaur() { return; }
wrapaur() { return; }
spinach() { return; }
aurget() { return; }
burgaur() { return; }
packer() { return; }
yaourt() { return; }

test=true

source arch.sh