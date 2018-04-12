#!/bin/bash
#
####################################################################################################
#   SETTINGS
#
# Comment out settings which are to be determined when
# the script runs(more interactive)

####################################################################################################
#   Script Settings
#
# Platform desktop/laptop
# Determines whether packages for wlan will be asked to be installed or not_____
platform="laptop"

# Fancy styling(default: true)
fancy=true

# Prompt after every part(default: false)
post_prompt=true

####################################################################################################
#   Pre-Installation
#
# Set the keyboard layout
#   Available keyboard layouts can be found with
#   $ ls /usr/share/kbd/keymaps/**/*.map.gz
#   default: (asks)
keyboard_layout="de_CH-latin1"

# Verify the boot mode
#   Nothing to change here

# Connect to the Internet
#   default: "archlinux.org"
ping_address="archlinux.org"

# Update the system clock
#   Nothing to change here

# Partition the disks
#   Nothing to change here

# Format the partitions
#   Nothing to change here

# Mount the file systems
#   Nothing to change here


####################################################################################################
#   Pre-Installation
#
# Select the mirrors
#   default: (asks)
edit_mirrorlist=false

# Install the base packages
#   Additional packages to install
#   default: (asks)
additional_packages="base-devel git vim"

# Locale
# default: en_US
locale="de_CH"

fstab_indentifier="U"
REGION="Europe"
CITY="Zurich"
NEW_HOSTNAME="turing"
INSTALL_WIRELESS_SUPPORT=true
INSTALL_WIRELESS_SUPPORT_DIALOG=true
MODIFY_INITRAMFS=false