#!/bin/bash

source settings.sh

source bashme/bashme

# Basic settings
loglevel=$LL_INFO
logfilelevel=$LL_DEBUG
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
define_opt '_help'       '-h' '--help'         ''     'Display this help text.'
define_opt '_ver'        '-v' '--version'      ''     'Display the VERSION.'
define_opt 'logfile'     '-l' '--logfile'      'file' "Change logfile to ${ITALIC}file${RESET}."
define_opt '_chroot'     '-c' '--chroot'       ''     "Continue script from after ${ITALIC}chroot${RESET}."
define_opt '_post'       '-p' '--post-install' ''     "Continue script from the ${ITALIC}post-installation${RESET}."
define_opt 'run_through' '-r' '--run-through'  ''     "Don't let user navigate."
DESCRIPTION="This script simplifies the installation of Arch Linux. It can be run in as a interactive script or purely rely on the settings defined in the settings.sh script.
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

declare -i left=4
[[ -n "$run_through" ]] && left=0
################################################################################
# MAIN
function main() {
  declare_stack suggestion
  local -i number=1
  while : ; do
    prepare_pane
    declare -i top
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "Arch Linux Installation"
    [[ -z "$run_through" ]] && [[ -z "$_chroot" ]] && [[ -z "$_post" ]] && enumerate_options "Quit" \
                "1 Pre-Installation" \
                "2 Installation" \
                "3 Configure the system" \
                "4 Reboot" \
                "5 Post-Installation"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && [[ -z "$_chroot" ]] && read_answer "Enter option [$number]: " answer $number
      [[ -n "$_chroot" ]] && answer=3
      [[ -n "$_post" ]] && answer=5
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          pre_installation
          ;;
        2)
          push suggestion 3
          installation
          ;;
        3)
          push suggestion 4
          configure_the_system
          ;;
        4)
          push suggestion 5
          reboot_system
          ;;
        5)
          push suggestion 0
          post_installation
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestion number
  done
}

################################################################################
# 1
function pre_installation() {
  local -i number=1
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "1 Pre-Installation"
    [[ -z "$run_through" ]] && enumerate_options "Return to Main" \
                "1.1 Set the keyboard layout" \
                "1.2 Verify the boot mode" \
                "1.3 Connect to the Internet" \
                "1.4 Update the system clock" \
                "1.5 Partition the disks" \
                "1.6 Format the partitions" \
                "1.7 Mount the file systems"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && read_answer "Enter option [$number]: " answer $number
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          set_keyboard_layout
          ;;
        2)
          push suggestion 3
          verify_boot_mode
          ;;
        3)
          push suggestion 4
          connect_to_the_internet
          ;;
        4)
          push suggestion 5
          update_the_system_clock
          ;;
        5)
          push suggestion 6
          partition_the_disks
          ;;
        6)
          push suggestion 7
          format_the_partitions
          ;;
        7)
          push suggestion 0
          mount_the_file_systems
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestion number
  done
}

# 1.1
function set_keyboard_layout() {
  while : ; do
    prepare_pane
    print_title "1.1 Set the keyboard layout"
    if [[ -z "$keyboard_layout" ]]; then
      local -a options=(
        $(ls /usr/share/kbd/keymaps/**/*.map.gz | \
          grep -oE '[^/]*$' | \
          sed 's/\.map\.gz//g' | \
          sort)
        )
      list_options
      keyboard_layout=us
      [[ -z "$run_through" ]] && read_answer "Enter option (us): " keyboard_layout us
    fi
    newline
    info "Setting keyboard layout to '$keyboard_layout'."
    exec_cmd loadkeys $keyboard_layout && break
    warn "Couldn't set the keyboard layout."
    keyboard_layout=
  done
  pause
  while : ; do
    if [[ -z "$console_font" ]]; then
      local -a options=($(ls /usr/share/kbd/consolefonts))
      list_options
      info "Write 'cycle' to test each font."
      console_font='default8x16'
      [[ -z "$run_through" ]] && read_answer "Enter option (default8x16): " console_font default8x16
      if [[ "$console_font" == "cycle" ]]; then
        for consfnt in "${options[@]}"; do
          tput clear
          setfont $consfnt
          print_title "Font: $consfnt"
          newline
          tput hpa 0
          showconsolefont
          echo 'Lorem ipsum dolor sit amet.'
          read
        done
        setfont
        continue
      fi
    fi
    newline
    info "Setting console font to '$console_font'."
    exec_cmd setfont $console_font && break
    warn "Couldn't set the console font."
    console_font=
  done
}

# 1.2
function verify_boot_mode() {
  prepare_pane
  print_title "1.2 Verifying the boot mode"
  newline
  debug "Checking if efivars exist."
  if [ -f /sys/firmware/efi/efivars ] ; then
    info "UEFI is enabled."
  else
    info "UEFI is disabled."
  fi
}

# 1.3
function connect_to_the_internet() {
  prepare_pane
  print_title "1.3 Connect to the Internet"
  newline
  make_sure_internet_is_connected
}
function make_sure_internet_is_connected() {
  info "Checking internet connectivity."
  [[ -z "$ping_address" ]] && ping_address="8.8.8.8"
  while : ; do
    debug "Pinging $ping_address."
    if exec_cmd ping -c 1 $ping_address; then
      newline
      info "Internet is up and running"
      break;
    else
      newline
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

# 1.4 
function update_the_system_clock() {
  prepare_pane
  print_title "1.4 Update the system clock"
  newline
  info "Enabling NTP synchronization."
  if ! exec_cmd timedatectl set-ntp true; then
    newline
    error "Couldn't enable NTP synchronization."
    # if [[ $region != "" && $city != "" ]] ; then
    #   tput hpa $left
    #   info "Setting timezone based on locale settings"
    #   timedatectl set-timezone $region/$city | (printf '    ' && cat) | sed -z 's/\n/\n    /gm'
    #   if check_retval $?; then
    #     tput hpa $left
    #     info "Set the timezone successfully"
    #   else
    #     tput hpa $left
    #     info "Couldn't set the timezone"
    #   fi
    # fi
    # tput hpa $left
    # trace "Waiting for the changes to take effect..."
    # sleep 1s
    # tput hpa $left
    # info "Please check if the time has been set correctly:"
    # timedatectl status | (printf '    ' && cat) | sed -z 's/\n/\n    /gm'
    # if check_retval $?; then
    #   tput hpa $left
    #   info "If the displayed time is incorrect, please set it up yourself."
    # else
    #   tput hpa $left
    #   fatal "Something went horribly wrong"
    #   exit $EX_ERR
    # fi
  fi
}

# 1.5
function partition_the_disks() {
  prepare_pane
  print_title "1.5 Partition the disks"
  newline
  exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
  newline
  local partition_now='y'
  [[ -z "$run_through" ]] && read_answer "Should partitioning command be run now? [Y/n]: " partition_now y
  newline
  if [[ "$partition_now" == "y" ]]; then
    info "Executing command:"
    if ! exec_cmd partition_disks; then
      newline
      error "Couldn't run partitioning command."
    else
      newline
      info 'Finished partitioning.'
      newline
      info 'Updated block devices:'
      exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
    fi
  else
    info 'Not running command.'
  fi
}

# 1.6
function format_the_partitions() {
  prepare_pane
  print_title "1.6 Format the partitions"
  newline
  exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
  local format_now='y'
  [[ -z "$run_through" ]] && read_answer "Should the formatting command be run now? [Y/n]: " format_now y
  newline
  if [[ "$format_now" == "y" ]]; then
    info "Executing ${BOLD}format_partitions${RESET}:"
    if ! exec_cmd format_partitions; then
      newline
      error 'Something went wrong.'
    else
      newline
      info 'Finished formatting.'
    fi
  else
    info 'Not running command.'
  fi
}

# 1.7
function mount_the_file_systems() {
  prepare_pane
  print_title "1.7 Mount the file systems"
  local mount_now='y'
  [[ -z "$run_through" ]] && read_answer "Should the mounting command be run now? [Y/n]: " mount_now y
  newline
  if [[ "$mount_now" == "y" ]]; then
    info "Executing ${BOLD}mount_partitions${RESET}:"
    if ! exec_cmd mount_partitions; then
      newline
      error 'Something went wrong.'
    else
      newline
      info 'Updated block devices:'
      exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
    fi
  else
    info 'Not running command.'
  fi
}

################################################################################
# 2
function installation() {
  local -i number=1
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "2 Installation"
    [[ -z "$run_through" ]] && enumerate_options "Return to Main" \
                "2.1 Select the mirrors" \
                "2.2 Install the base packages"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && read_answer "Enter option [$number]: " answer $number
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          select_the_mirrors
          ;;
        2)
          push suggestion 0
          install_the_base_packages
          pause
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestion number
  done
}

declare -rA method_dict=(
  [download]=1
  [filter_countries]=2
  [rank_speed]=3
  [edit]=4
)
declare -rA country_dict=([AU]='Australia' [AT]='Austria' [BD]='Bangladesh'
  [BY]='Belarus' [BE]='Belgium' [BA]='Bosnia and Herzegovina' [BR]='Brazil'
  [BG]='Bulgaria' [CA]='Canada' [CL]='Chile' [CN]='China' [CO]='Colombia'
  [HR]='Croatia' [CZ]='Czechia' [DK]='Denmark' [EC]='Ecuador' [FI]='Finland'
  [FR]='France' [DE]='Germany' [GR]='Greece' [HK]='Hong Kong' [HU]='Hungary'
  [IS]='Iceland' [IN]='India' [ID]='Indonesia' [IE]='Ireland' [IL]='Israel'
  [IT]='Italy' [JP]='Japan' [KZ]='Kazakhstan' [LT]='Lithuania'
  [LU]='Luxembourg' [MK]='Macedonia' [MX]='Mexico' [NL]='Netherlands'
  [NC]='New Caledonia' [NZ]='New Zealand' [NO]='Norway' [PH]='Philippines'
  [PL]='Poland' [PT]='Portugal' [QA]='Qatar' [RO]='Romania' [RU]='Russia'
  [RS]='Serbia' [SG]='Singapore' [SK]='Slovakia' [SI]='Slovenia'
  [ZA]='South Africa' [KR]='South Korea' [ES]='Spain' [SE]='Sweden'
  [CH]='Switzerland' [TW]='Taiwan' [TH]='Thailand' [TR]='Turkey'
  [UA]='Ukraine' [GB]='United Kingdom' [US]='United States' [VN]='Vietnam'
)
# 2.1
function select_the_mirrors() {
  local -i number=1
  local -r mirrorlist="/etc/pacman.d/mirrorlist"
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || ([[ $number -eq 1 ]] && [[ $number -ne 0 ]]) && \
      print_title "2.1 Select the mirrors"
    [[ -z "$run_through" ]] && enumerate_options "Return to Installation" \
                "Run reflector command" \
                "Manually edit mirrorlist"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && read_answer "Enter option [$number]: " answer $number
      debug "Current option is: $number"
      case "$answer" in
        0)
          return
          ;;
        1)
          if [[ -n "$run_through" ]]; then
            push suggestion 0
          else
            push suggestion 2
          fi
          run_reflector
          ;;
        2)
          push suggestion 0
          vim "$mirrorlist"
          break
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestion number
  done
}
function run_reflector() {
  local mirrorlist_bak="$mirrorlist.bak"
  local -i i=2
  while [[ -f "$mirrorlist_bak" ]]; do
    mirrorlist_bak="$mirrorlist.bak$i"
    ((i++))
  done
  newline
  info "Backing up mirrorlist to '$mirrorlist_bak'."
  exec_cmd cp "$mirrorlist" "$mirrorlist_bak"
  newline
  if ! type foo &>/dev/null; then
    info 'Reflector not installed. Installing now.'
    if ! exec_cmd pacman -Sy reflector --color=always --noconfirm; then
      newline
      error "Couldn't install reflector."
      return
    fi
    newline
  fi
  info 'Running reflector now(this may take a while).'
  exec_cmd reflector ${reflector_args[*]} --save "$mirrorlist"
  newline
  info 'Done'
}

# 2.2
function install_the_base_packages() {
  prepare_pane
  print_title "2.2 Install the base packages"
  local install_now='y'
  [[ -z "$run_through" ]] && read_answer "Should the base package installation be run now? [Y/n]: " install_now y
  newline
  if [[ "$install_now" == "y" ]]; then
    info "Executing ${BOLD}format_partitions${RESET}:"
    if ! exec_cmd pacstrap /mnt base --color=always; then
      newline
      error 'Something went wrong.'
    else
      newline
      info 'Finished installing base packages.'
    fi
  else
    info 'Not installing base packages.'
  fi
}

################################################################################
# 3
function configure_the_system() {
  local -i number=1
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "3 Configure the system"
    [[ -z "$run_through" ]] && [[ -z "$_chroot" ]] && enumerate_options "Return to Main" \
                "3.1 Fstab" \
                "3.2 Chroot" \
                "3.3 Time zone" \
                "3.4 Locale" \
                "3.5 Network configuration" \
                "3.6 Initramfs" \
                "3.7 Root password" \
                "3.8 Boot loader"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && [[ -z "$_chroot" ]] && read_answer "Enter option [$number]: " answer $number
      [[ -n "$_chroot" ]] && answer=3
      _chroot=
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          fstab
          ;;
        2)
          push suggestion 3
          chroot
          ;;
        3)
          push suggestion 4
          time_zone
          ;;
        4)
          push suggestion 5
          locale
          ;;
        5)
          push suggestion 6
          network_configuration
          ;;
        6)
          push suggestion 7
          initramfs
          ;;
        7)
          push suggestion 8
          root_password
          ;;
        8)
          push suggestion 0
          boot_loader
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestion number
  done
}

# 3.1
function fstab() {
  while : ; do
    prepare_pane
    print_title "3.1 Fstab"
    if [[ -z $fstab_identifier ]] ; then
      fstab_identifier="u"
      [[ -z "$run_through" ]] && read_answer "Enter option (us): " fstab_identifier "u"
      read_answer "Use UUIDs(u/U) or labels(l/L)?" answer "U"
      fstab_identifier=$answer
    fi
    newline
    case "$fstab_identifier" in
      [uU])
        info "Using UUIDs to generate the fstab file..."
        fstab_identifier="U"
        ;;
      [lL])
        info "Using labels to generate the fstab file..."
        fstab_identifier="L"
        ;;
      *)
        error "Please choose an option from above."
        tput rc
        tput dl 2
        continue
    esac
    break
  done
  if ! exec_cmd "genfstab -$fstab_identifier /mnt | tee /mnt/etc/fstab"; then
    error "Couldn't generate fstab-file."
  fi
}

# 3.2
function chroot() {
  prepare_pane
  print_title "3.2 Chroot"
  newline
  info "Copying the files over to the child system."
  exec_cmd mkdir -p /mnt/root/bashme
  exec_cmd cp "./bashme/bashme" "/mnt/root/bashme/"
  exec_cmd cp "./{arch.sh,$(basename $logfile),settings.sh}" "/mnt/root/"
  local oldlogfile="$(basename $logfile)"
  [[ -z "$test_script" ]] && logfile="/mnt/root/$logfile"
  local bashrc="/mnt/root/.bashrc"
  local oldbashrc="${bashrc}.bak"
  if [[ -n "$test_script" ]]; then
    bashrc="/dev/null"
    oldbashrc="/dev/null"
  fi
  exec_cmd "cp \"$bashrc\" \"$oldbashrc\""
  exec_cmd "echo \"cd\" >> \"$bashrc\""
  exec_cmd "echo \"~/arch.sh -cl $oldlogfile\" >> \"$bashrc\""
  exec_cmd "arch-chroot /mnt"
  newline
  info "Exited chroot. Rebooting."
  pause
  exec_cmd reboot
}

# 3.3
function time_zone() {
  prepare_pane
  print_title "3.3 Time zone"
  if [[ -z $region ]] ; then
    # timedatectl list-timezones | cut -d'/' -f1 | uniq
    local -a options=($(
      ls -l /usr/share/zoneinfo/ | \
      grep -E '^d.*\ [A-Z][a-z]+$' | \
      sed 's/^d.*:[0-9][0-9]\ //g'
    ))
    list_options
    region="Asia"
    [[ -z "$run_through" ]] && read_answer "Enter option (Asia): " region "Asia"
  fi
  newline
  info "Time zone region chosen to be '$region'."
  if [[ -z $city ]] ; then
    local -a options=($(ls /usr/share/zoneinfo/$region/))
    list_options
    city="Tokyo"
    [[ -z "$run_through" ]] && read_answer "Enter option (Tokyo): " city "Tokyo"
  fi
  newline
  info "Time zone city chosen to be '$city'."
  newline
  if ! exec_cmd timedatectl set-timezone $region/$city; then
    newline
    error "Couldn't set time zone."
    return
  fi
  exec_cmd hwclock --systohc
  newline
  info 'Done.'
}

# 3.4
function locale() {
  prepare_pane
  print_title "3.4 Locale"
  newline
  if [ ${#locales[@]} -eq 0 ]; then
    info 'Editing /etc/locale.gen file.'
    pause
    vim /etc/locale.gen
  else
    info 'Uncommenting locales.'
    local locale
    for locale in "${locales[@]}"; do
      if ! exec_cmd sed -i "'s/^#$locale/$locale/g'" /etc/locale.gen; then
        error "Couldn't uncomment $locale."
        return
      fi
    done
  fi
  newline
  info 'Running locale generator.'
  if ! exec_cmd locale-gen; then
    error "Couldn't run locale generator."
    return
  fi
  newline
  info "Setting ${ITALICS}LANG${RESET}-variable."
  local file="/etc/locale.conf"
  [[ -n "$test_script" ]] && file="/dev/null"
  if ! exec_cmd "echo \"LANG=$LANG\" > $file"; then
    newline
    error "Couldn't persist ${ITALICS}LANG${RESET} variable."
    return
  fi
  if [[ -n "$keyboard_layout" ]]; then
    newline
    info "Setting ${ITALICS}KEYMAP${RESET}-variable."
    local file="/etc/vconsole.conf"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo \"KEYMAP=$keyboard_layout\" > $file"; then
      newline
      error "Couldn't persist ${ITALICS}KEYMAP${RESET} variable."
      return
    fi
  fi
}

# 3.5
function network_configuration() {
  prepare_pane
  print_title "3.5 Network Configuration"
  newline
  [[ -n "$run_through" ]] && [[ -z "$hostname" ]] && hostname="arch"
  [[ -z "$hostname" ]] && read_answer "Please specify a host name [arch]: " hostname "arch"
  info 'Setting host name.'
  local file="/etc/hostname"
  [[ -n "$test_script" ]] && file="/dev/null"
  if ! exec_cmd "echo \"$hostname\" > $file"; then
    newline
    error "Couldn't save host name."
    return
  fi
  newline
  info 'Writing hosts file.'
  [[ -z "$perm_ip" ]] && perm_ip="127.0.1.1"
  local value="$(cat << eof
127.0.0.1	localhost
::1		localhost
$perm_ip	$hostname.localdomain	$hostname
eof
)"
  local file="/etc/hosts"
  [[ -n "$test_script" ]] && file="/dev/null"
  if ! exec_cmd "echo \"$value\" > $file"; then
    newline
    error "Couldn't write hosts file."
    return
  fi
}

# 3.6
function initramfs() {
  prepare_pane
  print_title "3.5 Initramfs"
  newline
  if [[ -n "$edit_mkinitcpio" ]]; then
    info 'Editing /etc/mkinitcpio.conf.'
    vim "/etc/mkinitcpio.conf"
    if ! exec_cmd mkinitcpio -p linux; then
      error "Couldn't rebuild initramfs image."
      return
    fi
    newline
    info 'Done.'
  else
    info 'Nothing to do.'
  fi
}

# 3.7
function root_password() {
  prepare_pane
  print_title "3.7 Root password"
  newline
  info 'Please set a root password:'
  if ! passwd; then
    newline
    error "Couldn't set the root password."
    return
  fi
  newline
  info 'Done.'
}

# 3.8
function boot_loader() {
  prepare_pane
  print_title "3.8 Boot loader"
  newline
  info 'Executing install_bootloader routine:'
  if ! exec_cmd install_bootloader; then
    newline
    error "Couldn't run command successfully."
    return
  else
    newline
    info 'Done.'
  fi
  newline
  info 'Checking for Intel.'
  if ! exec_cmd grep \'Intel\' /proc/cpuinfo; then
    newline
    info 'No Intel CPU found.'
    newline
    info 'Done.'
    return
  fi
  newline
  info 'Intel CPU detected.'
  if ! exec_cmd pacman -S intel-ucode --color=always --noconfirm; then
    newline
    error "Couldn't install package."
    return
  fi
  newline
  info 'Executing configure_microcode routine:'
  if ! exec_cmd configure_microcode; then
    newline
    error "Couldn't run command successfully."
    return
  else
    newline
    info 'Done.'
  fi
}

# 4
function reboot_system() {
  prepare_pane
  print_title "4 Reboot"
  newline
  info 'Cleaning up files.'
  local bashrc="/mnt/root/.bashrc"
  local oldbashrc="${bashrc}.bak"
  if [[ -n "$test_script" ]]; then
    bashrc="/dev/null"
    oldbashrc="/dev/null"
  fi
  exec_cmd "cp \"$oldbashrc\" \"$bashrc\""
  exec_cmd "echo \"~/arch.sh -pl $oldlogfile\" >> \"$bashrc\""
  newline
  info 'Please exit the chroot now(Ctrl+D).'
  exit 0
}

################################################################################
# 5
function post_installation() {
  local -i number=1
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "5 Post-Installation"
    [[ -z "$run_through" ]] && enumerate_options "Return to Main" \
                "5.1 General Recommendations" \
                "5.2 Applications"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && read_answer "Enter option [$number]: " answer $number
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          general_recommendations
          ;;
        2)
          push suggestion 0
          applications
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestion number
  done
}

# 5.1
function general_recommendations() {
  local -i number=1
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "5.1 General Recommendations"
    [[ -z "$run_through" ]] && enumerate_options "Return to Post-Installation" \
                "5.1.1  System Administration" \
                "5.1.2  Package management" \
                "5.1.3  Booting" \
                "5.1.4  Graphical User Interface" \
                "5.1.5  Power Management" \
                "5.1.6  Multimedia" \
                "5.1.7  Networking" \
                "5.1.8  Input Devices" \
                "5.1.9  Optimization" \
                "5.1.10 System Service" \
                "5.1.11 Console Improvements"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && read_answer "Enter option [$number]: " answer $number
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          NYI
          system_administration
          ;;
        2)
          push suggestion 3
          NYI
          package_management
          ;;
        3)
          push suggestion 4
          NYI
          booting
          ;;
        4)
          push suggestion 5
          NYI
          gui
          ;;
        5)
          push suggestion 6
          NYI
          power_management
          ;;
        6)
          push suggestion 7
          NYI
          multimedia
          ;;
        7)
          push suggestion 8
          NYI
          networking
          ;;
        8)
          push suggestion 9
          NYI
          input_devices
          ;;
        9)
          push suggestion 10
          NYI
          optimization
          ;;
        10)
          push suggestion 11
          NYI
          system_service
          ;;
        11)
          push suggestion 0
          NYI
          console_improvements
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestion number
  done
}

# 5.1.1
function system_administration() {
  local -i number=1
  while : ; do
    prepare_pane
    [[ -z "$run_through" ]] || [[ $number -eq 1 ]] && print_title "5.1.1 System Administration"
    [[ -z "$run_through" ]] && enumerate_options "Return to General Recommendations" \
                "5.1.1.1 Users and Groups" \
                "5.1.1.2 Privilege Escalation" \
                "5.1.1.3 Service Management" \
                "5.1.1.4 System Maintenance"
    while : ; do
      answer=$number
      [[ -z "$run_through" ]] && read_answer "Enter option [$number]: " answer $number
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestion 2
          users_and_groups
          ;;
        2)
          push suggestion 3
          privilege_escalation
          ;;
        3)
          push suggestion 4
          NYI
          service_management
          ;;
        4)
          push suggestion 0
          NYI
          system_maintenance
          ;;
        *)
          newline
          error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestion number
  done
}

# 5.1.1.1
function users_and_groups() {
  prepare_pane
  print_title "5.1.1.1 Users and Groups"
  newline
  info "Executing the add_users_and_groups routine:"
  if ! exec_cmd add_users_and_groups; then
    newline
    error "Couldn't run command."
  else
    newline
    info 'Done.'
  fi
}

# 5.1.1.2
function privilege_escalation() {
  prepare_pane
  print_title "5.1.1.2 Privilege Escalation"
  newline
  info 'Executing the handle_privilage_escalation routine:'
  if ! exec_cmd handle_privilage_escalation; then
    newline
    error "Couldn't run command."
  else
    newline
    info 'Done.'
  fi
}

# 5.1.1.3
function service_management() {
  prepare_pane
  print_title "5.1.1.3 Service Management"
  newline
  info 'Nothing to do here.'
}

# 5.1.1.4
function system_maintenance() {
  prepare_pane
  print_title "5.1.1.4 System Maintenance"
  newline
  info 'Checking if any services failed.'
  exec_cmd systemctl --failed
  info 'Checking logs.'
  exec_cmd journalctl -p 3 -xb
  newline
  if [[ -n "$backup_pacman_db" ]]; then
    info 'Backing up pacman database.'
    exec_cmd tar -cjf /var/lib/pacman/local.bak.tar.bz2 /var/lib/pacman/local
    newline
  fi
  if [[ -n "$change_pw_policy" ]]; then
    info 'Setting password policy.'
    local file="/etc/pam.d/passwd"
    [[ -n "$test_script" ]] && file="/dev/null"
    exec_cmd "setup_pw_policy > $file"
    newline
  fi
  if [[ -n "$change_lockout_policy" ]]; then
    info 'Setting lock out policy.'
    local file="/etc/pam.d/system-login"
    [[ -n "$test_script" ]] && file="/dev/null"
    exec_cmd "setup_lockout_policy > $file"
    newline
  fi
  if ((faildelay >= 0)); then
    info 'Writing fail delay to /etc/pam.d/system-login.'
    local file="/etc/pam.d/system-login"
    [[ -n "$test_script" ]] && file="/dev/null"
    exec_cmd "echo \"auth optional pam_faildelay.so delay=$faildelay\" > $file"
    newline
  fi
  local file="/etc/pam.d/system-login"
  [[ -n "$test_script" ]] && file="/dev/null"
  info 'Commenting out deprecated line.'
  exec_cmd sed -i 's/^auth\ *required\ *pam_tally.so.*$/#\0/g' "$file"
  newline
  info 'Done.'
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
post_installation_old() {
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

#################################################
# Helpers

function pause() {
    [[ -n "$post_prompt" ]] && read
}
function newline() {
    tput cud1
    tput hpa $left
}
declare -a levels=()
function print_title() {
  local title="$1"
  [[ -z "$run_through" ]] && newline
  newline
  local IFS='.'
  printf '%s' "${FG_WHITE}${UNDERLINE}${BOLD}$1${RESET}"
  IFS=' '
  trace "Printed title: '$1'"
  newline
}
function enumerate_options() {
  local -i i=0
  local option
  for option in "$@"; do
    newline
    printf '%s' "$i) $option"
    trace "Printed option number $i: '$option'"
    ((i++))
  done
}
function list_options() {
  local -i maxwidth=$(($(tput cols)-left-2))
  local -i width=0
  local first=1
  local option
  trace "Printing ${#options[@]} options."
  newline
  for option in "${options[@]}"; do
    width=$((width+${#option}+2))
    if [[ -n "$first" ]]; then
      first=""
    else
      printf '%s' ', '
    fi
    if ((width >= maxwidth)); then
      newline
      width=${#option}
    fi
    printf '%s' "$option"
  done
  newline
}
function read_answer() {
  trace "Reading answer."
  tput sc
  newline
  printf "$1"
  local _answer
  read _answer
  if [[ -n "$3" ]] && [[ -z "$_answer" ]]; then
    _answer="$3"
  fi
  eval "$2='$_answer'"
  debug "Read answer: $2='$(eval "echo "\$$2"")'"
}
function exec_cmd() {
  debug "Executing: $*"
  tput hpa $left
  echo " ${BOLD}${FG_RED}\$ ${RESET}${BOLD}$*${RESET}"
  eval "$*" 2>&1 | {
    local -i l=1
    while read line; do
      printf "${BG_LGRAY}${FG_BLACK}%4d:${RESET}" $l
      tput hpa 5
      echo "$line"
      debug "           $line"
      ((l++))
    done
  }
  local retval=$(check_retval ${PIPESTATUS[0]})
  return $retval
}
function prepare_pane() {
  if [[ -n "$run_through" ]]; then
    left=$(((${#FUNCNAME[@]}-3)*2))
    [[ -n "$test_script" ]] && ((left--))
  fi
  [[ -z "$run_through" ]] && tput clear
}

# Start script
#tput smcup # Not supported in liveISO
main