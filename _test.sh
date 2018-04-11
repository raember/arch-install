#!/bin/bash

loadkeys() {
    return;
}

timedatectl() {
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

ls() {
    return
}

source arch.sh