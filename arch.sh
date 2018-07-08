#!/bin/bash

source settings.sh

source bashme/bashme

# Basic settings
loglevel=$LL_INFO
log2file=1

# Setup:
PROGRAM_NAME="${BOLD}Arch Install Script${RESET}"
VERSION="${FG_GREEN}v0.2${RESET}"
YEAR=2018
FULL_NAME="Raphael Emberger"
LICENCE=$(cat LICENSE)
EXPLANATION='Installer script for Arch Linux.
BTW: I uSe ArCh.'
USAGE=(
  '[OPTION]...    Execute script with arguments.'
  '               Show this help page.'
)
define_opt '_help'  '-h' '--help'      ''  'Display this help text.'
define_opt '_ver'   '-v' '--version'   ''  'Display the VERSION.'
define_opt 'resume' '-r' '--resume-at' 'n' "Resume script at entry point ${ITALIC}n${RESET}."
DESCRIPTION="This script simplifies the installation of Arch Linux. it can be run in as a interactive script or purely rely on the settings defined in the settings.sh script.
As an Arch user myself I wanted an easy and fast way to reinstall Arch Linux.
BTW: I uSe ArCh."

# Parse arguments
declare -i resume=0
parse_args "$@"

# Process options
[[ -n "$_help" ]] && print_usage && exit
[[ -n "$_ver" ]] && print_version && exit

# Create a lock file
#lock

# Setup traps
traps+=(EXIT)
sig_err() {
  error "An error occurred(SIGERR)."
  exit;
}
sig_int() {
  error "Canceled by user(SIGINT)."
  exit;
}
sig_exit() {
  read
  tput rmcup
  info "Ending script(SIGEXIT). Cleaning up."
  unlock
}
trap_signals

script_files=(
  "arch.sh"
  "arch.sh.log"
  "arch_hist"
  "format.sh"
  "settings.sh"
)

main() {
  while : ; do
    tput clear
    declare -i left
    declare -i top
    draw_border $BG_LBLUE
    print_title "Arch Linux Installation"
    enumerate_options "Pre-Installation" \
                "Installation" \
                "Configure the system" \
                "Reboot" \
                "Post-Installation"
    while : ; do
      read_answer "Enter option (1): " answer 1
      case "$answer" in
        1)
          pre_installation
          break
          ;;
        2)
          installation
          break
          ;;
        3)
          configure_the_system
          break
          ;;
        4)
          reboot
          break
          ;;
        5)
          post_installation
          break
          ;;
        *)
          ((top--))
          tput cup $((top+1)) $left
          error "Please choose an option from above."
          tput cup $top $left
          ;;
      esac
    done
  done
}
function pause() {
    [[ -n "$post_prompt" ]] && read
}
function draw_border() {
  return
  trace "Drawing border."
  tput cup 0 0
  printf '%s' "$1"
  printf "%$(($(tput cols)-1))s" " "
  printf '%s' "$RESET"
  for ((i=0;i<=$(tput lines);i++)); do
    printf '%s' "${1}  ${RESET}"
    tput cup $i 0
  done
}
function print_title() {
  left=4
  top=2
  local title="$1"
  tput cup $top $left
  echo "${FG_WHITE}${UNDERLINE}$1${RESET}"
  trace "Printed title: '$1' at ($top, $left)"
  top=$((top + 2))
  tput cup $top $left
}
function enumerate_options() {
  local -i i
  local option
  for option in "$@"; do
    ((i++))
    tput cup $top $left
    echo "$i) $option"
    trace "Printed option number $i: '$option' at ($top, $left)"
    ((top++))
  done
  ((top++))
}
function list_options() {
  local -i maxwidth=$(($(tput cols)-left-2))
  local -i width=0
  local first=1
  local option
  trace "Printing ${#options[@]} options."
  for option in "${options[@]}"; do
    width=$((width+${#option}+2))
    if [[ -n "$first" ]]; then
      first=""
    else
      printf '%s' ', '
    fi
    if ((width >= maxwidth)); then
      ((top++))
      tput cup $top $left
      width=${#option}
    fi
    printf '%s' "$option"
  done
  ((top++))
  ((top++))
}
function read_answer() {
  debug "Reading answer."
  tput cup $top $left
  local _answer
  tput dch $(($(tput cols)-left))
  printf "$1"
  read _answer
  if [[ -n "$3" ]] && [[ -z "$_answer" ]]; then
    _answer="$3"
  fi
  eval "$2='$_answer'"
  debug "Read answer: $2='$(eval "echo "\$$2"")'"
  ((top++))
}


function pre_installation() {
  while : ; do
    tput clear
    draw_border $BG_LBLUE
    print_title "Pre-Installation"
    enumerate_options "Set the keyboard layout" \
                "Verify the boot mode" \
                "Connect to the Internet" \
                "Update the system clock" \
                "Partition the disks" \
                "Format the partitions" \
                "Mount the file systems" \
                "Return to Main"
    while : ; do
      read_answer "Enter option (1): " answer 1
      case "$answer" in
        1)
          set_keyboard_layout
          break
          ;;
        2)
          verify_boot_mode
          break
          ;;
        3)
          connect_to_internet
          break
          ;;
        4)
          update_system_clock
          break
          ;;
        5)
          partition_the_disks
          break
          ;;
        6)
          format_the_partitions
          break
          ;;
        7)
          mount_file_systems
          break
          ;;
        8)
          return
          ;;
        *)
          ((top--))
          tput cup $((top+1)) $left
          error "Please choose an option from above."
          tput cup $top $left
          ;;
      esac
    done
  done
}

# 0
set_keyboard_layout() {
  while : ; do
    tput clear
    draw_border $BG_LBLUE
    print_title "Set the keyboard layout"
    if [[ -z "$keyboard_layout" ]]; then
      local -a options=($(ls /usr/share/kbd/keymaps/**/*.map.gz | grep -oE '[^/]*$' | sed 's/\.map\.gz//g'))
      list_options
      read_answer "Enter option (us): " keyboard_layout us
    fi
    info "Setting keyboard layout to '$keyboard_layout'."
    loadkeys $keyboard_layout
    if check_retval $?; then
      break;
    fi
    warn "Couldn't set the keyboard layout."
  done
  pause
  while : ; do
    tput clear
    draw_border $BG_LBLUE
    print_title "Set the keyboard layout(Console font)"
    if [[ -z "$console_font" ]]; then
      local -a options=($(ls /usr/share/kbd/consolefonts | sed 's/\(\.fnt|\.psfu|\.psf|\)\.gz//g'))
      list_options
      echo "Write 'cycle' to test each font."
      read_answer "Enter option (default8x16): " console_font default8x16
      if [[ "$console_font" == "cycle" ]]; then
        for consfnt in "${options[@]}"; do
          tput clear
          print_title "Font: $consfnt"
          local -a lines=($(showconsolefont))
          for line in "${lines[@]}"; do
            tput cup $top $left
            printf '%s' "$line"
            ((top++))
          done
          tput cup $top $left
          echo "Lorem ipsum dolor sit amet."
          draw_border $BG_LBLUE
          read
        done
        continue
      fi
    fi
    info "Setting console font to '$console_font'."
    setfont $console_font
    if check_retval $?; then
      break;
    fi
    warn "Couldn't set the console font."
  done
}

# 1
verify_boot_mode() {
  info "[$INDEX]: Verifying the boot mode."
  debug "Checking if efivars exist."
  if [ -f /sys/firmware/efi/efivars ] ; then
    info "UEFI is enabled."
  else
    info "UEFI is disabled."
  fi
}

# 2
connect_to_internet() {
  info "[$INDEX]: Connect to the Internet"
  make_sure_internet_is_connected
}
make_sure_internet_is_connected() {
  info "Checking internet connectivity."
  while : ; do
    debug "Pinging $ping_address."
    ping -q -c 1 $ping_address &2> /dev/null
    if check_retval $?; then
      info "Internet is up and running"
      break;
    else
      info "No active internet connection found"
      info "Please stop the running dhcpcd service with ${ITALIC}systemctl stop dhcpcd@${RESET} and pressing ${format_code}Tab${format_no_code}.
Proceed with ${BOLD}Network configuration${RESET}:
${ITALIC}${UNDERLINE}https://wiki.archlinux.org/index.php/Network_configuration#Device_driver${RESET}
for ${BOLD}wired${RESET} devices or ${font_bold}Wireless network configuration${RESET}:
${ITALIC}${UNDERLINE}https://wiki.archlinux.org/index.php/Wireless_network_configuration${RESET}
for ${BOLD}wireless${RESET} devices.
Then resume this script with ${ITALIC}-r $INDEX${RESET}."
      exit $EX_OK
    fi
  done
}

# 3
update_system_clock() {
  info "[$INDEX]: Update the system clock"
  info "Enabling NTP synchronization"
  timedatectl set-ntp true &2> /dev/null
  if check_retval $?; then
    info "NTP has been enabled"
    if [[ $region != "" && $city != "" ]] ; then
      info "Setting timezone based on locale settings"
      timedatectl set-timezone $region/$city &2> /dev/null
      if check_retval $?; then
        info "Set the timezone successfully"
      else
        info "Couldn't set the timezone"
      fi
    fi
    info "Waiting for the changes to take effect..."
    sleep 1s
    info "Please check if the time has been set correctly:"
    timedatectl status
    if check_retval $?; then
      info "If the displayed time is incorrect, please set it up yourself."
    else
      fatal "Something went horribly wrong"
      exit $EX_ERR
    fi
  else
    fatal "Couldn't enable NTP"
    exit $EX_ERR
  fi
}

# 4
partition_disks() {
    info "[$INDEX]: Partition the disks"
    if [[ -n "$partitioning_scripted" ]] ; then
        [ -f /sys/firmware/efi/efivars ] && UEFI=1
        partition_the_disks
        [ "$success" = false ] && print_fail "Something went horribly wrong"
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
        print_cmd "format_the_partitions" success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
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
        print_check_file "/sys/firmware/efi/efivars" UEFI
        print_cmd_invisible "mount_the_partitions" success
        [ "$success" = false ] && print_fail "Something went horribly wrong"
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
    mirrorlist="/etc/pacman.d/mirrorlist"
    if  [ "$rank_by_speed" = true ] ; then
        print_cmd_invisible "cp $mirrorlist $mirrorlist.backup" success
        [ "$success" != true ] && print_fail "Failed"
        print_cmd_invisible "sed -i 's/^#Server/Server/' $mirrorlist.backup" success
        [ "$success" != true ] && print_fail "Failed"
        print_status "Please edit the mirrorlist and sort it yourself using the following command:"
        print_status "    $ ${format_code}cd /etc/pacman.d${format_no_code}"
        print_status "    $ ${format_code}vim mirrorlist.backup${format_no_code}"
        print_status "    $ ${format_code}rankmirrors -v mirrorlist.backup > mirrorlist${format_no_code}"
        print_status "You can add the ${format_code}-n N${format_no_code} flag to specify the number of mirrors to output"
        sub_shell
    fi
    if [ "$edit_mirrorlist" = "" ] ; then
        print_prompt_boolean "Do you want to edit the mirrorlist?" "y" edit_mirrorlist
    fi
    if [ "$edit_mirrorlist" = true ] ; then
        print_cmd "vim $mirrorlist" success
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
            [ -f $file ] && continue
            print_cmd_invisible "cp './$file' '/mnt/root/$file'" success
            [ "$success" != true ] && print_fail "Couldn't copy file $file"
        done
        print_status "Copying mirrorlist to new location"
        print_cmd_invisible "cp '/etc/pacman.d/mirrorlist' '/mnt/etc/pacman.d/mirrorlist'" success
    fi
    print_status "    -> ${format_code}arch-chroot /mnt"
    print_status "    -> ${format_code}cd${format_no_code}"
    print_status "    -> ${format_code}./$(basename $0) -c${format_no_code}"
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
    print_cmd_invisible "hwclock --systohc" success
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
        for new_locale in "${locales[@]}"; do
            echo "$new_locale" >> $file
        done
        print_pos "Written the locales to ${format_code}/etc/locale.gen${format_no_code}"
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
    if [ "$hosts_redirects" != "" ] ; then
        [ "$test" = true ] && file="/dev/null"
        for redirect in "${hosts_redirects[@]}"; do
            echo "$redirect" >> $file
        done
        [ "$success" = true ] && print_pos "Finished setting up hosts file"
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
        [ "$success" != true ] && print_fail "Couldn't copy mirrorlist"
        print_cmd_invisible "chown $username:$username '$home' -R" success
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
        print_cmd "$aur_helper --color=always -S systemd-numlockontty" success
        [ "$success" = false ] && print_neg "Failed"
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

while getopts "r:c" arg; do
	case $arg in
		r) # Resume setup
			resume=$OPTARG;;
        c) # Resume from inside chroot
            resume=11;;
		h) # Help
			help
			exit 0;;
		?) # Invalid option
			help
			exit 1;;
	esac
done
INDEX=$resume

# Start script
tput smcup
main