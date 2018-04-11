#!/bin/bash

# Settings:

KEYBOARD_LAYOUT="de_CH-latin1"
ADDITIONAL_PACKAGES="base-devel git vim"
FSTAB_METHOD="U"
REGION="Europe"
CITY="Zurich"
LOCALE="de_CH"
NEW_HOSTNAME="turing"
INSTALL_WIRELESS_SUPPORT=true
INSTALL_WIRELESS_SUPPORT_DIALOG=true
MODIFY_INITRAMFS=false

source settings.sh

main() {
    case $RESUME in
    0)
        print_part "Pre-installation"
        set_keyboard_layout
        ((INDEX++));&
    1)
        verify_boot_mode
        ((INDEX++));&
    2)
        connect_to_internet
        ((INDEX++));&
    3)
        update_system_clock
        ((INDEX++));&
    4)
        partition_disks
        ((INDEX++));&
    5)
        format_partitions
        ((INDEX++));&
    6)
        mount_file_systems
        ((INDEX++));&
    7)
        print_part "Installation"
        select_mirrors
        ((INDEX++));&
    8)
        install_base_packages
        ((INDEX++));&
    9)
        print_part "Configure the system"
        fstab
        ((INDEX++));&
    10)
        chroot
        ((INDEX++));&
    11)
        time_zone
        ((INDEX++));&
    12)
        locale
        ((INDEX++));&
    13)
        hostname
        ((INDEX++));&
    14)
        network_configuration
        ((INDEX++));&
    15)
        initramfs
        ((INDEX++));&
    16)
        root_password
        ((INDEX++));&
    17)
        boot_loader
        ((INDEX++));&
    18)
        print_part "Post-Installation"
        post_installation
        ;;
    *)
        echo -e "${FRED}Resume index ${RESUME} is invalid. Highest index is 18."
        exit 1
        ;;
    esac
}
# 0
set_keyboard_layout() {
    print_section "Set the keyboard layout"
    print_status "Setting keyboard layout"
    kbl=$KEYBOARD_LAYOUT
    if [[ $kbl == "" ]] ; then
        print_prompt "Please choose a keyboard layout:" "> "
        kbl=$answer
    fi
    print_cmd "loadkeys $kbl" "Set keyboard layout to ${VAR}${kbl}" "Couldn't load keyboard layout ${VAR}${kbl}" "kbl='kbl.tmp'"
    print_end
}

# 1
verify_boot_mode() {
    print_section "Verify the boot mode"
    print_status "Checking if efivars exist"
    if [ -d /sys/firmware/efi/efivars ] ; then
        print_status "UEFI is ${POS}enabled"
    else
        print_status "UEFI is ${NEG}disabled"
    fi
    print_end
}

# 2
connect_to_internet() {
    print_section "Connect to the Internet"
    print_status "Checking internet connectivity"
    if ping -q -c 1 -W 1 8.8.8.8 &> /dev/null; then
        print_pos "Internet is up and running"
    else
        print_neg "No active internet connection found"
        print_sub "Please stop the running dhcpcd service with ${CODE}systemctl stop dhcpcd@${NOCODE} and pressing ${CODE}Tab${NOCODE}."
        print_sub "Proceed with ${BOLD}Network configuration${NOBOLD}:"
        print_sub "${LINK}https://wiki.archlinux.org/index.php/Network_configuration#Device_driver${NOLINK}"
        print_sub "for ${BOLD}wired${NOBOLD} devices or ${BOLD}Wireless network configuration${NOBOLD}:"
        print_sub "${LINK}https://wiki.archlinux.org/index.php/Wireless_network_configuration${NOLINK}"
        print_sub "for ${BOLD}wireless${NOBOLD} devices"
        sub_shell
    fi
    print_end
}

# 3
update_system_clock() {
    print_section "Update the system clock"
    print_status "Enabling NTP synchronization"
    print_status "Executing ${CODE}timedatectl set-ntp true${NOCODE}"
    if timedatectl set-ntp true &>/dev/null; then
        print_pos "NTP has been enabled"
        if [[ $REGION != "" && $CITY != "" ]] ; then
            print_status "Setting timezone based on locale settings"
            timedatectl set-timezone $REGION/$CITY
        fi
        print_status "Please check if the time has been set correctly:"
        print_end
        timedatectl status
    else
        print_neg "Couldn't enable NTP"
        print_end
    fi
}

# 4
partition_disks() {
    print_section "Partition the disks"
    print_status "Listing all block devices..."
    print_cmd_visible_fail "lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG" "" "Failed"
    print_status "The following partitions are ${BOLD}required${NOBOLD} for a chosen device:"
    print_status " - One partition for the root directory ${CODE}/${NOCODE}"
    if ls /sys/firmware/efi/efivars &> /dev/null; then
        print_status " - an ${BOLD}EFI System Partition${NOBOLD}(fat32):"
        print_status "   ${LINK}https://wiki.archlinux.org/index.php/EFI_System_Partition${NOLINK}"
    fi
    print_status ""
    print_status "To modify partition tables, use ${CODE}fdisk /dev/sdX${NOCODE} or ${CODE}parted /dev/sdX${NOCODE}."
    print_status "If desired, setting up LVM, LUKS or RAID, do so now as well"
    sub_shell
    print_end
}

# 5
format_partitions() {
    print_section "Format the partitions"
    print_status "Format the partitions with the desired file systems. Example:"
    print_status "${CODE}mkfs.ext4 /dev/sdXN${NOCODE}"
    print_status "If you prepared a swap partition, enable it:"
    print_status "${CODE}mkswap /dev/sdXN${NOCODE}"
    print_status "${CODE}swapon /dev/sdXN${NOCODE}"
    sub_shell
    print_end
}

# 6
mount_file_systems() {
    print_section "Mount the file systems"
    print_status "Mount the root partition of the new system to ${CODE}/mnt${NOCODE}:"
    print_status "${CODE}mount /dev/sdXN /mnt${NOCODE}"
    print_status "Create mount points for any remaining partitions and mount them accordingly: "
    print_status "${CODE}mkdir /mnt/boot${NOCODE}"
    print_status "${CODE}mount /dev/sdXN /mnt/boot${NOCODE}"
    sub_shell
    print_end
}

# 7
select_mirrors() {
    print_section "Select the mirrors"
    print_status "If desired, mirrors can be manually sorted or enabled/disabled."
    print_prompt_boolean "Do you want to edit the mirrorlist?" "y" edit
    if [ "$edit" = true ] ; then
        print_cmd_visible_fail "vim /etc/pacman.d/mirrorlist" "Finished editing mirrorlist" "Failed editing mirrorlist"
    fi
    print_end
}

# 8
install_base_packages() {
    print_section "Install the base packages"
    print_status "Installing the ${CODE}base${NOCODE} package group to the the new system."
    packages=$ADDITIONAL_PACKAGES
    if [[ $packages == "" ]] ; then
        print_prompt "List additional packages to be installed(like ${CODE}base-devel${NOCODE}, ${CODE}git${NOCODE} etc.)." "> "
        packages=$answer
    fi
    print_cmd_visible_fail "pacstrap /mnt base $packages" "Finished installing base package group" "Failed installing base package group"
    print_end
}

# 9
fstab() {
    print_section "Fstab"
    print_status "Generating fstab file for the new system."
    method=$FSTAB_METHOD
    if [[ $method == "" ]] ; then
        while : ; do
            print_prompt "Do you want to use UUIDs(u/U) or labels(l/L)?" "[U/l] "
            method=$answer
            [[ $method == "" ]] && method="u"
            case $method in
                [uU])
                    print_status "Using UUIDs to generate the fstab file..."
                    method="U"
                    break;;
                [lL])
                    print_status "Using labels to generate the fstab file..."
                    method="L"
                    break;;
                *)
                    print_neg "Please write either ${CODE}u/U${NOCODE}${NEG} or ${CODE}l/L${NOCODE}${NEG}!";;
            esac
        done
    fi
    print_cmd_visible_fail "genfstab -$method /mnt >> /mnt/etc/fstab" "Finished writing to the fstab file" "Failed writing to the fstab file"
    print_end
}

# 10
chroot() {
    print_section "Chroot"
    print_status "Change root into the new system and resume this script with ${CODE}./$(basename $0) -c${NOCODE}"
    print_sub "${CODE}arch-chroot /mnt${NOCODE}"
    print_end
    exit 0
}

# 11
time_zone() {
    print_section "Time zone"
    region=$REGION
    if [[ $region == "" ]] ; then
        print_status "Choose from the following regions:"
        print_status_start
        ls /usr/share/zoneinfo/ -lA | grep ^d | cut -d" " -f12
        print_status_end
        while : ; do
            print_prompt "Please choose a region" "> "
            region=$answer
            [ -d /usr/share/zoneinfo/$region ] && break
            print_neg "Please choose a region"
        done
    fi
    city=$CITY
    if [[ $city == "" ]] ; then
        print_status "Choose from the following cities:"
        print_status_start
        ls /usr/share/zoneinfo/$region/ -mA
        print_status_end
        while : ; do
            print_prompt "Please choose a city" "> "
            city=$answer
            ls /usr/share/zoneinfo/$region/$city &> /dev/null && break
            print_neg "Please choose a city"
        done
    fi
    print_status "Setting up the symbolic link"
    print_cmd_visible_fail "ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime" "Finished setting up the symbolic link" "Failed setting up the symbolic link"
    print_status "Generating ${CODE}/etc/adjtime${NOCODE}"
    print_cmd_visible_fail "hwclock --systohc" "Finished generating ${CODE}/etc/adjtime${NOCODE}" "Failed generating ${CODE}/etc/adjtime${NOCODE}"
    print_end
}

# 12
locale() {
    print_section "Locale"
    print_status "Uncomment needed localizations"
    print_prompt "Opening ${CODE}/etc/locale.gen${NOCODE} with vim" ""
    print_cmd_visible_fail "vim /etc/locale.gen" "Finished editing locale.gen" "Failed editing locale.gen"
    print_status "Generating localizations"
    print_cmd_visible_fail "locale-gen" "Finished generating localizations" "Failed generating localizations"
    locale=$LOCALE
    if [[ $locale == "" ]] ; then
        print_status "The following localizations are available:"
        locales=$(grep "^[^#]" /etc/locale.gen)
        print_status_start
        echo $locales
        print_status_end
        while : ; do
            print_prompt "Please choose to which one the ${CODE}LANG${NOCODE}${NORM}-variable should be set:" "> "
            locale=$answer
            locale=$(echo $locales | grep $locale)
            if [[ $locale != "" ]] ; then
                break
            fi
            print_neg "Please choose a valid localization"
        done
    fi
    print_status "Setting ${CODE}LANG${NOCODE}-variable"
    print_cmd_visible_fail "echo 'LANG=$locale' > /etc/locale.conf" "Finished setting ${CODE}LANG${NOCODE}${POS}-variable" "Failed setting ${CODE}LANG${NOCODE}${NEG}-variable"
    print_status "Setting keyboard layout for the new system"
    kbl=$KEYBOARD_LAYOUT
    [[ $kbl == "" ]] && kbl=$(cat "$(basename $0).kbl_tmp" 2> /dev/null)
    if [[ $kbl == "" ]] ; then
        print_neg "Couldn't recover previously set keyboard layout"
        print_prompt "Please set the desired keyboard layout:" "> "
        kbl=$answer
    fi
    print_cmd_visible_fail "echo 'KEYMAP=$kbl' > /etc/vconsole.conf" "Finished setting keyboard layout for the new system" "Failed setting keyboard layout for the new system"
    print_end
}

# 13
hostname() {
    print_section "Hostname"
    hostname=$NEW_HOSTNAME
    if [[ $hostname == "" ]] ; then
        print_prompt "Set the desired hostname for the new system" "> "
        hostname=$answer
    fi
    print_cmd_visible_fail "echo '$hostname' > /etc/hostname" "Finished setting the hostname" "Failed setting the hostname"
    print_status "Setting up hosts file"
    print_cmd_visible_fail "echo -e '127.0.0.1	localhost\n::1		localhost\n127.0.1.1	$hostname.localdomain	$hostname' >> /etc/hosts" "Finished setting up hosts file" "Failed setting up hosts file"
    print_end
}

# 14
network_configuration() {
    print_section "Network Configuration"
    iws=$INSTALL_WIRELESS_SUPPORT
    [[ $iws == "" ]] && print_prompt_boolean "Should packages for wireless support be installed?" "n" iws "Installing wireless support packages" "Skipping wireless support packages"
    if [ "$iws" = true ] ; then
        print_cmd_visible_fail "pacman -S iw wpa_supplicant" "Finished installing wireless support packages" "Failed installing wireless support packages"
        iwsd=$INSTALL_WIRELESS_SUPPORT_DIALOG
        if [[ $iwsd == "" ]] ; then
            print_prompt_boolean "Should the optional package ${CODE}dialog${NOCODE} for ${CODE}wifi-menu${NOCODE} be installed?" "n" iwsd "Installing ${CODE}dialog${NOCODE}" "Skipping ${CODE}dialog${NOCODE} installation"
            [ "$iwsd" = true ] && print_cmd_visible_fail "pacman -S dialog" "Finished installing ${CODE}dialog${NOCODE}" "Failed installing ${CODE}dialog${NOCODE}"
        fi
        print_status "Please install needed ${CODE}firmware packages${NOCODE}:"
        print_status "${LINK}https://wiki.archlinux.org/index.php/Wireless_network_configuration#Installing_driver.2Ffirmware${NOLINK}"
        sub_shell
    fi
    print_end
}

# 15
initramfs() {
    print_section "Initramfs"
    modinitramfs=$MODIFY_INITRAMFS
    [[ $modinitramfs == "" ]] && print_prompt_boolean "Do you want to edit the ${CODE}mkinitpcio.conf${NOCODE} file?" "y" modinitramfs "Editing the ${CODE}mkinitpcio.conf${NOCODE} file" "Skipping the ${CODE}mkinitpcio.conf${NOCODE} file"
    if [ "$modinitramfs" = true ] ; then
        print_cmd_visible_fail "vim /etc/mkinitpcio.conf" "Finished editing ${CODE}mkinitpcio.conf${NOCODE}" "Failed editing ${CODE}mkinitpcio.conf${NOCODE}"
        print_prompt_boolean "Do you want to rebuild the initramfs?" "y" rebuildinitramfs "Rebuilding initramfs" "Skipping the rebuilding of initramfs"
        [ "$rebuildinitramfs" = true ] && print_cmd_visible_fail "mkinitcpio -p linux" "Finished rebuilding initramfs" "Failed rebuilding initramfs"
    else
        print_status "Nothing to do"
    fi
    print_end
}

# 16
root_password() {
    print_section "Root password"
    print_status "It's time to set the root password and add users and groups. Commands:"
    print_status "- ${CODE}passwd [user]${NOCODE}                           Change password"
    print_status "- ${CODE}useradd <name> -G {group1,...,groupN}${NOCODE}   Add user"
    print_status "Don't forget to make sure the user has a home directory"
    print_status "Also edit the ${CODE}/etc/sudoers${NOCODE} file(with ${CODE}visudo${NOCODE}) to "
    sub_shell
    print_prompt "Edit the ${CODE}/etc/sudoers${NOCODE} file to allow users in the group ${CODE}wheel${NOCODE} to execute ${CODE}sudo${NOCODE}" ""
    print_cmd_visible_fail "visudo" "Edited the ${CODE}/etc/sudoers${NOCODE} file" "Failed to edit the ${CODE}/etc/sudoers${NOCODE} file"
    print_end
}

# 17
boot_loader() {
    print_section "Boot loader"
    print_status "Please choose a boot loader and install it manually according to the Wiki:"
    print_status "${LINK}https://wiki.archlinux.org/index.php/Category:Boot_loaders${NOLINK}"
    sub_shell
    print_status "Checking cpu..."
    if grep "Intel" /proc/cpuinfo &> /dev/null; then
        print_status "Intel CPU detected"
        print_sub "Installing ${CODE}intel-ucode${NOCODE}"
        print_cmd_visible_fail "pacman -S intel-ucode" "Installation succeeded" "Installation failed"
        print_status "Please enable microcode updates manually according to the Wiki:"
        print_status "${LINK}https://wiki.archlinux.org/index.php/Microcode#Enabling_Intel_microcode_updates${NOLINK}"
        sub_shell
    fi
    print_end
}

# 18
post_installation() {
    print_section "Post-Installation"
    print_status "Exit the ${CODE}chroot${NOCODE} and reboot into the new system"
    print_status "See ${BOLD}General recommendations${NOBOLD} for system management directions and post-installation tutorials"
    print_status "(like setting up a graphical user interface, sound or a touchpad)"
    print_status "${LINK}https://wiki.archlinux.org/index.php/General_recommendations${NOLINK}"
    print_status "For a list of applications that may be of interest, see ${BOLD}List of applications${NOBOLD}."
    print_status "${LINK}https://wiki.archlinux.org/index.php/List_of_applications${NOLINK}"
    print_end
}

# Parse arguments
help() {
	echo -e "Usage:"
	echo -e "\$ $(basename $0) [-r number|-c]\tStart setup"
	echo -e " -r number\tResume script from specific point according to ArchWiki"
	echo -e " -c\t\tResume script from inside chroot - equals '-r 11'"
	echo -e " -h\t\tShow this help text"
}

source _format.sh

RESUME=0
while getopts "r:c" arg; do
	case $arg in
		r) # Resume setup
			RESUME=$OPTARG;;
        c) # Resume from inside chroot
            RESUME=11;;
		h) # Help
			help
			exit 0;;
		?) # Invalid option
			help
			exit 1;;
	esac
done
INDEX=$RESUME

# Start script
main