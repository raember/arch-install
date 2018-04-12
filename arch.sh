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
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    1)
        verify_boot_mode
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    2)
        connect_to_internet
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    3)
        update_system_clock
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    4)
        partition_disks
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    5)
        format_partitions
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    6)
        mount_file_systems
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    7)
        print_part "Installation"
        select_mirrors
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    8)
        install_base_packages
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    9)
        print_part "Configure the system"
        fstab
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    10)
        chroot
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    11)
        time_zone
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    12)
        locale
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    13)
        hostname
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    14)
        network_configuration
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    15)
        initramfs
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    16)
        root_password
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    17)
        boot_loader
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    18)
        print_part "Post-Installation"
        post_installation
        ;;
    *)
        print_neg "Resume index ${RESUME} is invalid. Highest index is 18."
        exit 1
        ;;
    esac
}
# 0
set_keyboard_layout() {
    print_section "Set the keyboard layout"
    print_status "Setting keyboard layout"
    if [ $keyboard_layout == "" ] ; then
        print_prompt "Please choose a keyboard layout:" "> "
        keyboard_layout="$answer"
    fi
    print_cmd "loadkeys $keyboard_layout" success
    if [ "$success" = true ] ; then
        print_pos "Set keyboard layout to ${format_variable}${keyboard_layout}"
    else
        print_fail "Couldn't load keyboard layout ${format_variable}${keyboard_layout}"
    fi
    print_end
}

# 1
verify_boot_mode() {
    print_section "Verify the boot mode"
    print_status "Checking if efivars exist"
    print_check_file "/sys/firmware/efi/efivars" success
    if [ "$success" = true ] ; then
        print_status "UEFI is ${format_positive}enabled"
    else
        print_status "UEFI is ${format_negative}disabled"
    fi
    print_end
}

# 2
connect_to_internet() {
    print_section "Connect to the Internet"
    print_status "Checking internet connectivity"
    print_cmd "ping -q -c 1 $ping_address" success
    if [ "$success" = true ] ; then
        print_pos "Internet is up and running"
    else
        print_neg "No active internet connection found"
        print_sub "Please stop the running dhcpcd service with ${format_code}systemctl stop dhcpcd@${format_no_code} and pressing ${format_code}Tab${format_no_code}."
        print_sub "Proceed with ${font_bold}Network configuration${font_no_bold}:"
        print_sub "${font_link}https://wiki.archlinux.org/index.php/Network_configuration#Device_driver${font_no_link}"
        print_sub "for ${font_bold}wired${font_no_bold} devices or ${font_bold}Wireless network configuration${font_no_bold}:"
        print_sub "${font_link}https://wiki.archlinux.org/index.php/Wireless_network_configuration${font_no_link}"
        print_sub "for ${font_bold}wireless${font_no_bold} devices"
        sub_shell
    fi
    print_end
}

# 3
update_system_clock() {
    print_section "Update the system clock"
    print_status "Enabling NTP synchronization"
    print_cmd_invisible "timedatectl set-ntp true" success
    if [ "$success" = true ] ; then
        print_pos "NTP has been enabled"
        if [[ $REGION != "" && $CITY != "" ]] ; then
            print_status "Setting timezone based on locale settings"
            print_cmd_invisible "timedatectl set-timezone $REGION/$CITY" success
            if [ "$success" = true ] ; then
                print_pos "Set the timezone successfully"
            else
                print_fail "Couldn't set the timezone"
            fi
        fi
        print_status "Please check if the time has been set correctly:"
        print_cmd "timedatectl status" success
        if [ "$success" = true ] ; then
            print_prompt_boolean "Is the displayed time correctly set up?" "y" answer
            if [ "$answer" = false ] ; then
                print_status "Please set up the time yourself and then return to the setup"
                print_end
                exit 0;
            fi
        else
            print_fail "Something went horribly wrong"
        fi
    else
        print_neg "Couldn't enable NTP"
    fi
    print_end
}

# 4
partition_disks() {
    print_section "Partition the disks"
    print_status "Listing all block devices..."
    print_cmd "lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG" success
    [ "$success" = false ] && print_fail "Something went horribly wrong"
    print_status "The following partitions are ${font_bold}required${font_no_bold} for a chosen device:"
    print_status " - One partition for the root directory ${format_code}/${format_no_code}"
    print_check_file "/sys/firmware/efi/efivars" success
    if [ "$success" = true ]; then
        print_status " - an ${font_bold}EFI System Partition${font_no_bold}(fat32):"
        print_status "   ${font_link}https://wiki.archlinux.org/index.php/EFI_System_Partition${font_no_link}"
    fi
    print_status ""
    print_status "To modify partition tables, use ${format_code}fdisk /dev/sdX${format_no_code} or ${format_code}parted /dev/sdX${format_no_code}."
    print_status "If desired, setting up LVM, LUKS or RAID, do so now as well"
    sub_shell
    print_end
}

# 5
format_partitions() {
    print_section "Format the partitions"
    print_status "Format the partitions with the desired file systems. Example:"
    print_status "${format_code}mkfs.ext4 /dev/sdXN${format_no_code}"
    print_status "If you prepared a swap partition, enable it:"
    print_status "${format_code}mkswap /dev/sdXN${format_no_code}"
    print_status "${format_code}swapon /dev/sdXN${format_no_code}"
    sub_shell
    print_end
}

# 6
mount_file_systems() {
    print_section "Mount the file systems"
    print_status "Mount the root partition of the new system to ${format_code}/mnt${format_no_code}:"
    print_status "${format_code}mount /dev/sdXN /mnt${format_no_code}"
    print_status "Create mount points for any remaining partitions and mount them accordingly: "
    print_status "${format_code}mkdir /mnt/boot${format_no_code}"
    print_status "${format_code}mount /dev/sdXN /mnt/boot${format_no_code}"
    sub_shell
    print_end
}

# 7
select_mirrors() {
    print_section "Select the mirrors"
    print_status "If desired, mirrors can be manually sorted or enabled/disabled."
    if [ "$edit_mirrorlist" = "" ] ; then
        print_prompt_boolean "Do you want to edit the mirrorlist?" "y" edit_mirrorlist
    fi
    if [ "$edit_mirrorlist" = true ] ; then
        print_cmd_visible_fail "vim /etc/pacman.d/mirrorlist" "Finished editing mirrorlist" "Failed editing mirrorlist"
    fi
    print_end
}

# 8
install_base_packages() {
    print_section "Install the base packages"
    print_status "Installing the ${format_code}base${format_no_code} package group to the the new system."
    packages=$additional_packages
    if [[ $additional_packages == "" ]] ; then
        print_prompt "List additional packages to be installed(like ${format_code}base-devel${format_no_code}, ${format_code}git${format_no_code} etc.)." "> "
        additional_packages=$answer
    fi
    print_cmd "pacstrap /mnt base $additional_packages" success
    if [ "$success" = true ] ; then
        print_pos "Finished installing packages"
    else
        print_fail "Failed installing packages"
    fi
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
                    print_neg "Please write either ${format_code}u/U${format_no_code}${format_negative} or ${format_code}l/L${format_no_code}${format_negative}!";;
            esac
        done
    fi
    print_cmd_visible_fail "genfstab -$method /mnt >> /mnt/etc/fstab" "Finished writing to the fstab file" "Failed writing to the fstab file"
    print_end
}

# 10
chroot() {
    print_section "Chroot"
    print_status "Change root into the new system and resume this script with ${format_code}./$(basename $0) -c${format_no_code}"
    print_sub "${format_code}arch-chroot /mnt${format_no_code}"
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
    print_status "Generating ${format_code}/etc/adjtime${format_no_code}"
    print_cmd_visible_fail "hwclock --systohc" "Finished generating ${format_code}/etc/adjtime${format_no_code}" "Failed generating ${format_code}/etc/adjtime${format_no_code}"
    print_end
}

# 12
locale() {
    print_section "Locale"
    print_status "Uncomment needed localizations"
    print_prompt "Opening ${format_code}/etc/locale.gen${format_no_code} with vim" ""
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
            print_prompt "Please choose to which one the ${format_code}LANG${format_no_code}${format_normal}-variable should be set:" "> "
            locale=$answer
            locale=$(echo $locales | grep $locale)
            if [[ $locale != "" ]] ; then
                break
            fi
            print_neg "Please choose a valid localization"
        done
    fi
    print_status "Setting ${format_code}LANG${format_no_code}-variable"
    print_cmd_visible_fail "echo 'LANG=$locale' > /etc/locale.conf" "Finished setting ${format_code}LANG${format_no_code}${format_positive}-variable" "Failed setting ${format_code}LANG${format_no_code}${format_negative}-variable"
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
            print_prompt_boolean "Should the optional package ${format_code}dialog${format_no_code} for ${format_code}wifi-menu${format_no_code} be installed?" "n" iwsd "Installing ${format_code}dialog${format_no_code}" "Skipping ${format_code}dialog${format_no_code} installation"
            [ "$iwsd" = true ] && print_cmd_visible_fail "pacman -S dialog" "Finished installing ${format_code}dialog${format_no_code}" "Failed installing ${format_code}dialog${format_no_code}"
        fi
        print_status "Please install needed ${format_code}firmware packages${format_no_code}:"
        print_status "${font_link}https://wiki.archlinux.org/index.php/Wireless_network_configuration#Installing_driver.2Ffirmware${font_no_link}"
        sub_shell
    fi
    print_end
}

# 15
initramfs() {
    print_section "Initramfs"
    modinitramfs=$MODIFY_INITRAMFS
    [[ $modinitramfs == "" ]] && print_prompt_boolean "Do you want to edit the ${format_code}mkinitpcio.conf${format_no_code} file?" "y" modinitramfs "Editing the ${format_code}mkinitpcio.conf${format_no_code} file" "Skipping the ${format_code}mkinitpcio.conf${format_no_code} file"
    if [ "$modinitramfs" = true ] ; then
        print_cmd_visible_fail "vim /etc/mkinitpcio.conf" "Finished editing ${format_code}mkinitpcio.conf${format_no_code}" "Failed editing ${format_code}mkinitpcio.conf${format_no_code}"
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
    print_status "- ${format_code}passwd [user]${format_no_code}                           Change password"
    print_status "- ${format_code}useradd <name> -G {group1,...,groupN}${format_no_code}   Add user"
    print_status "Don't forget to make sure the user has a home directory"
    print_status "Also edit the ${format_code}/etc/sudoers${format_no_code} file(with ${format_code}visudo${format_no_code}) to "
    sub_shell
    print_prompt "Edit the ${format_code}/etc/sudoers${format_no_code} file to allow users in the group ${format_code}wheel${format_no_code} to execute ${format_code}sudo${format_no_code}" ""
    print_cmd_visible_fail "visudo" "Edited the ${format_code}/etc/sudoers${format_no_code} file" "Failed to edit the ${format_code}/etc/sudoers${format_no_code} file"
    print_end
}

# 17
boot_loader() {
    print_section "Boot loader"
    print_status "Please choose a boot loader and install it manually according to the Wiki:"
    print_status "${font_link}https://wiki.archlinux.org/index.php/Category:Boot_loaders${font_no_link}"
    sub_shell
    print_status "Checking cpu..."
    if grep "Intel" /proc/cpuinfo &> /dev/null; then
        print_status "Intel CPU detected"
        print_sub "Installing ${format_code}intel-ucode${format_no_code}"
        print_cmd_visible_fail "pacman -S intel-ucode" "Installation succeeded" "Installation failed"
        print_status "Please enable microcode updates manually according to the Wiki:"
        print_status "${font_link}https://wiki.archlinux.org/index.php/Microcode#Enabling_Intel_microcode_updates${font_no_link}"
        sub_shell
    fi
    print_end
}

# 18
post_installation() {
    print_section "Post-Installation"
    print_status "Exit the ${format_code}chroot${format_no_code} and reboot into the new system"
    print_status "See ${font_bold}General recommendations${font_no_bold} for system management directions and post-installation tutorials"
    print_status "(like setting up a graphical user interface, sound or a touchpad)"
    print_status "${font_link}https://wiki.archlinux.org/index.php/General_recommendations${font_no_link}"
    print_status "For a list of applications that may be of interest, see ${font_bold}List of applications${font_no_bold}."
    print_status "${font_link}https://wiki.archlinux.org/index.php/List_of_applications${font_no_link}"
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