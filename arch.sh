#!/bin/bash

source settings.sh

source format.sh

script_files=("arch.sh" "arch_hist" "format.sh" "settings.sh")

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
        print_part "Package-Installation & Constomization"
        prepare
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    19)
        aur_helper
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    20)
        num_lock_activation
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    21)
        install_packages
        ((INDEX++))
        [ "$post_prompt" = true ] && read
        ;&
    22)
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
    print_cmd_invisible "loadkeys $keyboard_layout" success
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
    make_sure_internet_is_connected
    print_end
}
make_sure_internet_is_connected() {
    print_status "Checking internet connectivity"
    while : ; do
        print_cmd "ping -q -c 1 $ping_address" success
        if [ "$success" = true ] ; then
            print_pos "Internet is up and running"
            break;
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
    done
}

# 3
update_system_clock() {
    print_section "Update the system clock"
    print_status "Enabling NTP synchronization"
    print_cmd_invisible "timedatectl set-ntp true" success
    if [ "$success" = true ] ; then
        print_pos "NTP has been enabled"
        if [[ $region != "" && $city != "" ]] ; then
            print_status "Setting timezone based on locale settings"
            print_cmd_invisible "timedatectl set-timezone $region/$city" success
            if [ "$success" = true ] ; then
                print_pos "Set the timezone successfully"
            else
                print_fail "Couldn't set the timezone"
            fi
        fi
        print_status "Waiting for the changes to take effect..."
        sleep 2s
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
    if [ "$partitioning_scripted" = true ] ; then
        print_check_file "/sys/firmware/efi/efivars" UEFI
        print_cmd partition_the_disks success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
        print_status "Waiting for the changes to take effect..."
        sleep 2s
    else
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
    fi
    print_end
}

# 5
format_partitions() {
    print_section "Format the partitions"
    if [ "$formatting_scripted" = true ] ; then
        print_check_file "/sys/firmware/efi/efivars" UEFI
        print_cmd format_the_partitions success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
        print_status "Waiting for the changes to take effect..."
        sleep 2s
    else
        print_status "Listing all block devices..."
        print_cmd "lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG" success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
        print_status "Format the partitions with the desired file systems. Example:"
        print_status "${format_code}mkfs.ext4 /dev/sdXN${format_no_code}"
        print_status "If you prepared a swap partition, enable it:"
        print_status "${format_code}mkswap /dev/sdXN${format_no_code}"
        print_status "${format_code}swapon /dev/sdXN${format_no_code}"
        sub_shell
    fi
    print_end
}

# 6
mount_file_systems() {
    print_section "Mount the file systems"
    if [ "$mounting_scripted" = true ] ; then
        print_cmd mount_the_partitions success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
        print_status "Waiting for the changes to take effect..."
        sleep 2s
    else
        print_status "Listing all block devices..."
        print_cmd "lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG" success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
        print_status "Mount the root partition of the new system to ${format_code}/mnt${format_no_code}:"
        print_status "${format_code}mount /dev/sdXN /mnt${format_no_code}"
        print_status "Create mount points for any remaining partitions and mount them accordingly: "
        print_status "${format_code}mkdir /mnt/boot${format_no_code}"
        print_status "${format_code}mount /dev/sdXN /mnt/boot${format_no_code}"
        sub_shell
    fi
    print_end
}

# 7
select_mirrors() {
    print_section "Select the mirrors"
    if  [ "$rank_by_speed" = true ] ; then
        print_cmd_invisible "cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup" success
        [ "$success" != true ] && print_fail "Failed"
        print_cmd_invisible "sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup" success
        [ "$success" != true ] && print_fail "Failed"
        print_cmd_invisible "rankmirrors /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist" success
        [ "$success" != true ] && print_fail "Failed"
    fi
    if [ "$edit_mirrorlist" = "" ] ; then
        print_prompt_boolean "Do you want to edit the mirrorlist?" "y" edit_mirrorlist
    fi
    if [ "$edit_mirrorlist" = true ] ; then
        print_cmd "vim /etc/pacman.d/mirrorlist" success
        if [ "$success" = true ] ; then
            print_pos  "Finished editing mirrorlist"
        else
            print_fail "Failed editing mirrorlist"
        fi
    fi
    print_end
}

# 8
install_base_packages() {
    print_section "Install the base packages"
    print_status "Installing the ${format_code}base${format_no_code} package group to the the new system."
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
    while : ; do
        if [ $fstab_identifier == "" ] ; then
            print_prompt "Do you want to use UUIDs(u/U) or labels(l/L)?" "[U/l] "
            fstab_identifier=$answer
        fi
        [[ $fstab_identifier == "" ]] && fstab_identifier="u"
        case $fstab_identifier in
            [uU])
                print_status "Using UUIDs to generate the fstab file..."
                fstab_identifier="U"
                break;;
            [lL])
                print_status "Using labels to generate the fstab file..."
                fstab_identifier="L"
                break;;
            *)
                print_neg "Please write either ${format_code}u/U${format_no_code}${format_negative} or ${format_code}l/L${format_no_code}${format_negative}!";;
        esac
    done
    [ "$fstab_file" = "" ] && fstab_file="/mnt/etc/fstab"
    print_cmd_invisible "genfstab -$fstab_identifier /mnt >> '$fstab_file'" success
    if [ "$success" = true ] ; then
        print_pos "Finished writing to the fstab file"
    else
        print_fail "Failed writing to the fstab file"
    fi
    print_end
}

# 10
chroot() {
    print_section "Chroot"
    print_status "Change root into the new system, cd into ${format_code}/root${format_no_code} and resume this script with ${format_code}./$(basename $0) -c${format_no_code}"
    [ "$copy_scripts_to_new_system" = "" ] && copy_scripts_to_new_system=true
    if [ "$copy_scripts_to_new_system" = true ] ; then
        for file in "${script_files[@]}"; do
            print_cmd_invisible "cp './$file' '/mnt/root/$file'" success
            [ "$success" != true ] && print_fail "Couldn't copy file $file"
        done
    fi
    print_status "    -> ${format_code}arch-chroot /mnt"
    print_status "    -> ${format_code}cd root; ./$(basename $0) -c${format_no_code}"
    print_end
    exit 0
}

# 11
time_zone() {
    print_section "Time zone"
    if [[ $region == "" ]] ; then
        print_status "Choose from the following regions:"
        print_cmd "ls /usr/share/zoneinfo/ -lA | grep ^d | cut -d' ' -f12" success
        [ "$success" != true ] && print_fail "Something went horribly wrong"
        while : ; do
            print_prompt "Please choose a region" "> "
            region=$answer
            print_check_file "/usr/share/zoneinfo/$region" success
            [ "$success" = true ] && break
            print_neg "Please choose a region"
        done
    fi
    if [[ $city == "" ]] ; then
        print_status "Choose from the following cities:"
        print_cmd "ls /usr/share/zoneinfo/$region/ -mA" success
        [ "$success" != true ] && print_fail "Something went horribly wrong"
        while : ; do
            print_prompt "Please choose a city" "> "
            city=$answer
            print_check_file "/usr/share/zoneinfo/$region/$city" success
            [ "$success" = true ] && break
            print_neg "Please choose a city"
        done
    fi
    print_status "Setting up the symbolic link"
    print_cmd_invisible "ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime" success
    if [ "$success" = true ] ; then
        print_pos "Finished setting up the symbolic link"
    else
        print_fail "Failed setting up the symbolic link"
    fi
    print_status "Generating ${format_code}/etc/adjtime${format_no_code}"
    print_cmd "hwclock --systohc" success
    if [ "$success" = true ] ; then
        print_pos "Finished generating ${format_code}/etc/adjtime${format_no_code}"
    else
        print_fail "Failed generating ${format_code}/etc/adjtime${format_no_code}"
    fi
    print_end
}

# 12
locale() {
    print_section "Locale"
    if [ "$locales" = "" ] ; then
        print_status "Uncomment needed localizations"
        print_prompt "Opening ${format_code}/etc/locale.gen${format_no_code} with vim" ""
        print_cmd "vim /etc/locale.gen" success
        if [ "$success" = true ] ; then
            print_pos "Finished editing locale.gen"
        else
            print_fail "Failed editing locale.gen"
        fi
    else
        file="/etc/locale.gen"
        [ "$test" = true ] && file="/dev/null"
        locales_list=$(printf "\n%s" "${locales[@]}")
        print_cmd_invisible "echo '$locales_list'" success
        if [ "$success" = true ] ; then
            print_pos "Written the locales to ${format_code}/etc/locale.gen${format_no_code}"
        else
            print_fail "Failed writing the locales"
        fi
    fi
    print_status "Generating localizations"
    print_cmd "locale-gen" success
    if [ "$success" = true ] ; then
        print_pos "Finished generating localizations"
    else
        print_fail "Failed generating localizations"
    fi
    print_status "Setting ${format_code}LANG${format_no_code}-variable to ${format_variable}$lang"
    file="/etc/locale.conf"
    [ "$test" = true ] && file="/dev/null"
    print_cmd_invisible "echo 'LANG=$lang' > $file" success
    if [ "$success" = true ] ; then
        print_pos "Finished setting ${format_code}LANG${format_no_code}${format_positive}-variable"
    else
        print_fail "Failed setting ${format_code}LANG${format_no_code}${format_negative}-variable"
    fi
    print_status "Setting keyboard layout for the new system"
    if [ "$keyboard_layout" = "" ] ; then
        print_prompt "Please set the desired keyboard layout:" "> "
        keyboard_layout=$answer
    fi
    file="/etc/vconsole.conf"
    [ "$test" = true ] && file="/dev/null"
    print_cmd_invisible "echo 'KEYMAP=$keyboard_layout' > $file" success
    if [ "$success" = true ] ; then
        print_pos "Finished setting keyboard layout for the new system"
    else
        print_fail "Failed setting keyboard layout for the new system"
    fi
    print_end
}

# 13
hostname() {
    print_section "Hostname"
    if [ $hostname = "" ] ; then
        print_prompt "Set the desired hostname for the new system" "> "
        hostname=$answer
    fi
    file="/etc/hostname"
    [ "$test" = true ] && file="/dev/null"
    print_cmd_invisible "echo '$hostname' > $file" success
    if [ "$success" = true ] ; then
        print_pos "Finished setting the hostname"
    else
        print_fail "Failed setting the hostname"
    fi
    print_status "Setting up hosts file"
    file="/etc/hosts"
    [ "$test" = true ] && file="/dev/null"
    print_cmd_invisible "echo -e '127.0.0.1	localhost\n::1		localhost\n127.0.1.1	$hostname.localdomain	$hostname' >> $file" success
    if [ "$success" = true ] ; then
        print_pos "Finished setting up hosts file"
    else
        print_fail "Failed setting up hosts file"
    fi
    print_end
}

# 14
network_configuration() {
    print_section "Network Configuration"
    [ "$prompt_to_manage_manually" = "" ] && prompt_to_manage_manually=true
    if [ "$prompt_to_manage_manually" = true ] ; then
        print_status "Listing network interfaces..."
        print_cmd "ip link" success
        [ "$success" = false ] && print_fail "Failed listing network interfaces"
        print_status "Please setup the network configuration by yourself"
        sub_shell
    fi
    if [ "$platform" = "laptop" ] ; then
        [[ $wireless_support == "" ]] && print_prompt_boolean "Should packages for wireless support be installed?" "n" wireless_support
        if [ "$wireless_support" = true ] ; then
            print_cmd "pacman -S --color=always iw wpa_supplicant" success
            if [ "$success" = true ] ; then
                print_pos "Finished installing wireless support packages"
            else
                print_fail "Failed installing wireless support packages"
            fi
            [ "$dialog" = "" ] && print_prompt_boolean "Should the optional package ${format_code}dialog${format_no_code} for ${format_code}wifi-menu${format_no_code} be installed?" "n" dialog
            if [ "$dialog" = true ] ; then
                print_cmd "pacman -S --color=always dialog" success
                if [ "$success" = true ] ; then
                    print_pos "Finished installing ${format_code}dialog${format_no_code}"
                else
                    print_fail "Failed installing ${format_code}dialog${format_no_code}"
                fi
            fi
            print_status "Please install needed ${format_code}firmware packages${format_no_code}:"
            print_status "${font_link}https://wiki.archlinux.org/index.php/Wireless_network_configuration#Installing_driver.2Ffirmware${font_no_link}"
            sub_shell
        fi
    fi
    print_end
}

# 15
initramfs() {
    print_section "Initramfs"
    [ "$modify_initramfs" = "" ] && print_prompt_boolean "Do you want to edit the ${format_code}mkinitpcio.conf${format_no_code} file?" "y" modify_initramfs
    if [ "$modify_initramfs" = true ] ; then
        print_status "Editing the ${format_code}mkinitpcio.conf${format_no_code} file"
        file="/etc/mkinitpcio.conf"
        [ "$test" = true ] && file="/dev/null"
        print_cmd "vim /etc/mkinitpcio.conf" success
        if [ "$success" = true ] ; then
            print_pos "Finished editing ${format_code}mkinitpcio.conf${format_no_code}"
        else
            print_fail "Failed editing ${format_code}mkinitpcio.conf${format_no_code}"
        fi
        print_prompt_boolean "Do you want to rebuild the initramfs?" "y" rebuildinitramfs
        if [ "$rebuildinitramfs" = true ] ; then
            print_status "Rebuilding initramfs"
            print_cmd "mkinitcpio -p linux" success
            if [ "$success" = true ] ; then
                print_pos "Finished rebuilding initramfs"
            else
                print_fail "Failed rebuilding initramfs"
            fi
        else
            print_status "Skipping the rebuilding of initramfs"
        fi
    else
        print_status "Skipping the ${format_code}mkinitpcio.conf${format_no_code} file"
    fi
    print_end
}

# 16
root_password() {
    print_section "Root password"
    if [ "$username" != "" ] ; then
        print_status "Adding user $username"
        groups_list=$(printf ",%s" "${groups[@]}" | cut -c2-)
        print_cmd_invisible "mkdir -p '$home'" success
        [ "$success" != true ] && print_fail "Failed"
        print_cmd_invisible "chown $user:$user '$home' -R" success
        [ "$success" != true ] && print_fail "Failed"
        [ "$shell" = "" ] && shell="bash"
        if [ "$shell" != "bash" ] ; then
            print_status "Installing $shell"
            print_cmd "pacman -S --color=always $shell" success
            [ "$success" = false ] && print_fail "Failed"
        fi
        print_cmd_invisible "useradd $username -G $groups_list -d '$home' -s /bin/$shell" success
        [ "$success" != true ] && print_fail "Failed"
        print_pos "User $username added"
    fi
    print_status "It's time to set the root password and add users and groups."
    sub_shell
    print_prompt "Edit the ${format_code}/etc/sudoers${format_no_code} file to allow users in the group ${format_code}wheel${format_no_code} to execute ${format_code}sudo${format_no_code}"
    print_cmd "visudo" success
    if [ "$success" = true ] ; then
        print_pos "Edited the ${format_code}/etc/sudoers${format_no_code} file"
    else
        print_fail "Failed to edit the ${format_code}/etc/sudoers${format_no_code} file"
    fi
    print_end
}

# 17
boot_loader() {
    print_section "Boot loader"
    print_status "Please choose a boot loader and install it manually according to the Wiki:"
    print_status "${font_link}https://wiki.archlinux.org/index.php/Category:Boot_loaders${font_no_link}"
    sub_shell
    print_status "Checking cpu..."
    print_cmd_invisible "grep 'Intel' /proc/cpuinfo &> /dev/null" success
    if [ "$success" = true ] ; then
        print_status "Intel CPU detected"
        print_status "Installing ${format_code}intel-ucode${format_no_code}"
        print_cmd "pacman -S --color=always intel-ucode" success
        if [ "$success" = true ] ; then
            print_pos "Installation succeeded"
        else
            print_fail "Installation failed"
        fi
        print_status "Please enable microcode updates manually according to the Wiki:"
        print_status "${font_link}https://wiki.archlinux.org/index.php/Microcode#Enabling_Intel_microcode_updates${font_no_link}"
        sub_shell
    fi
    print_end
}


# 18
prepare() {
    print_section "Preparation"
    if [ $PWD != $home ] ; then
        print_status "Copying script files to new location"
        for file in "${script_files[@]}"; do
            print_cmd_invisible "cp './$file' '$home/$file'" success
            [ "$success" != true ] && print_fail "Couldn't copy file $file"
        done
        print_cmd_invisible "chwon $username:$username '$home' -R" success
        [ "$success" != true ] && print_fail "Failed"
        print_status "Changing directory to new location"
        print_cmd_invisible "cd $home" success
        print_status "Substitue root to new user: ${format_code}su $username${format_no_code} and then ${format_code}cd${format_no_code}"
        print_status "Then start this script again as new user, using ${format_code}./$(basename $0) -r 18${format_no_code}"
        print_end
        exit 0;
    fi
    print_status "Making sure all the necessary directories are present"
    for dir in "${directories[@]}"; do
        print_cmd_invisible "mkdir -p $dir" success
        [ "$success" = false ] && print_fail "Failed creating $dir"
    done
    print_status "Making sure all the necessary programs are installed"
    programs=("git" "vim")
    for program in "${programs[@]}"; do
        print_cmd_invisible "$program --version" success
        if [ "$success" = false ] ; then
            print_status "${format_code}$program${format_no_code} was missing. Installing now..."
            print_cmd "sudo pacman -S --color=always $program" success
            [ "$success" = false ] && print_fail "Couldn't install $program"
        fi
    done
    print_status "Checking internet connectivity"
    make_sure_internet_is_connected
    print_prompt_boolean "Do you want to enable ${format_code}multilib${format_no_code}?" "y" multilib
    if [ "$multilib" = true ] ; then
        print_cmd "sudo vim /etc/pacman.conf" success
        [ "$success" = false ] && print_fail "Failed"
    fi
    print_cmd "sudo pacman -Syu --color=always" success
    [ "$success" = false ] && print_fail "Failed"
    print_end
}

# 19
aur_helper() {
    print_section "AUR-Helper"
    print_cmd_invisible "cd $git_dir" success
    print_status "Installing ${format_code}$aur_helper${format_no_code}"
    for package in "${aur_helper_packages[@]}"; do
        print_status "Cloning ${format_code}${package}${format_no_code}"
        print_cmd "git clone https://aur.archlinux.org/${package}.git" success
        [ "$success" = false ] && print_fail "Failed"
        print_cmd_invisible "cd $package" success
        print_status "Building ${format_code}${package}${format_no_code}"
        print_cmd "makepkg -fsri" success
        [ "$success" = false ] && print_fail "Failed"
        print_cmd_invisible "cd .." success
    done
    print_cmd_invisible "cd $home" success
    print_end
}

# 20
num_lock_activation() {
    print_section "Num Lock activation"
    [ "$numlock" = "" ] && print_prompt_boolean "Do you want to have NumLock activated on boot?" "y" numlock
    if [ "$numlock" = true ] ; then
        package="systemd-numlockontty"
        print_status "Adding package ${format_code}$package${format_no_code}"
        aur_packages+=("systemd-numlockontty")
    fi
    print_end
}

# 21
install_packages() {
    print_section "Installation"
    print_status "Install predefined packages"
    packagelist=$(printf " %s" "${packages[@]}")
    print_cmd "sudo pacman --color=always -S $packagelist" success
    [ "$success" = false ] && print_neg "Failed - proceed with setup"
    if [ "$aur_helper" != "" ] ; then
        print_status "Install predefined AUR packages"
        packagelist=$(printf " %s" "${aur_packages[@]}")
        print_cmd "$aur_helper --color=always -S $packagelist" success
        [ "$success" = false ] && print_neg "Failed - proceed with setup"
        if [ "$numlock" = true ] ; then
            print_status "Enabling numlock activation service"
            print_cmd "sudo systemctl enable numLockOnTty" success
            [ "$success" = false ] && print_fail "Failed"
            print_status "Enabling succeeded"
        fi
    fi
    print_end
}

# 22
post_installation() {
    print_section "Post-Installation"
    print_cmd_invisible "cd $home" success
    [ "$success" = false ] && print_fail "Failed"
    if [ "$dotfiles_git" != "" ] ; then
        print_status "Cloning dotfiles repo"
        print_cmd "git clone '$dotfiles_git' '$dotfiles_dir'" success
        [ "$success" = false ] && print_fail "Failed"
        print_cmd_invisible "cd '$dotfiles_dir'" success
        [ "$success" = false ] && print_fail "Failed"
        if [ "$dotfiles_install" != "" ] ; then
            print_cmd "'$dotfiles_install'" success
            [ "$success" = false ] && print_fail "Failed"
        fi
    fi
    print_status "Running the aftermath script"
    print_cmd "aftermath" success
    [ "$success" = false ] && print_fail "Failed"
    print_status "Exit the ${format_code}chroot${format_no_code} and reboot into the new system"
    print_status "See ${font_bold}General recommendations${font_no_bold} for system management directions and post-installation tutorials"
    print_status "(like setting up a graphical user interface, sound or a touchpad)"
    print_status "${font_link}https://wiki.archlinux.org/index.php/General_recommendations${font_no_link}"
    print_status "For a list of applications that may be of interest, see ${font_bold}List of applications${font_no_bold}."
    print_status "${font_link}https://wiki.archlinux.org/index.php/List_of_applications${font_no_link}"
    print_status ""
    print_status "Thank you for using this installer script"
    print_status "                                  - Raphael Emberger"
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