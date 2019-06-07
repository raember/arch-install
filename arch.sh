#!/bin/bash

source settings.sh

source bashme/bashme

# Basic settings
loglevel=$LL_INFO
logfilelevel=$LL_TRACE
log2file=1
logbashme=

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
As An ArCh UsEr MySeLf I wanted an easy and fast way to reinstall Arch Linux.
BTW: I uSe ArCh."

# Parse arguments
parse_args "$@"

# Process options
[[ -n "$_help" ]] && print_usage && exit
[[ -n "$_ver" ]] && print_version && exit
[[ -n "$_chroot" ]] && SKIPCHOICE=1
[[ -n "$_post" ]] && SKIPCHOICE=1

# Create a lock file
#lock

# Setup traps
traps+=(EXIT)
sig_err() {
  echo
  if type m_error &> /dev/null; then
    m_error "An error occurred(SIGERR)."
  else
    error "An error occurred(SIGERR)."
  fi
  exit;
}
sig_int() {
  echo
  if type m_error &> /dev/null; then
    m_error "Canceled by user(SIGINT)."
  else
    error "Canceled by user(SIGINT)."
  fi
  exit;
}
sig_exit() {
  if type m_info &> /dev/null; then
    m_info "Ending script(SIGEXIT). Cleaning up."
  else
    m_info "Ending script(SIGEXIT). Cleaning up."
  fi
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
  enter_menu "Arch Linux Installation"
  SUGGESTION=1
  [[ -n "$_chroot" ]] && SUGGESTION=3
  [[ -n "$_post" ]] && SUGGESTION=5
  while : ; do
    draw_menu
    OPTIONS=(
      "Pre-Installation"
      "Installation"
      "Configure the system"
      "Reboot"
      "Post-Installation"
    )
    ! choose_submenu && break
  done
  leave_menu
}

################################################################################
# 1
function pre_installation() {
  enter_menu "Pre-Installation"
  SUGGESTION=1
  while : ; do
    draw_menu
    OPTIONS=(
      "Set the keyboard layout"
      "Verify the boot mode"
      "Connect to the Internet"
      "Update the system clock"
      "Partition the disks"
      "Format the partitions"
      "Mount the file systems"
    )
    ! choose_submenu && break
  done
  leave_menu
}

# 1.1
function set_the_keyboard_layout() {
  enter_menu "Set the keyboard layout"
  draw_menu
  if [[ -z "$keyboard_layout" ]]; then
    SUGGESTION=us
    OPTIONS=($(
      ls /usr/share/kbd/keymaps/**/*.map.gz | \
        grep -oE '[^/]*$' | \
        sed 's/\.map\.gz//g' | \
        sort
      ))
    TAB_COMPLETIONS=(${OPTIONS[@]})
    list_options
    choose keyboard_layout
  fi
  m_info "Setting keyboard layout to '$keyboard_layout'."
  if ! exec_cmd loadkeys $keyboard_layout; then
    m_warn "Couldn't set the keyboard layout."
  fi
  if [[ -z "$console_font" ]]; then
    pause
    while : ; do
      [[ -n "$console_font" ]] && break
      draw_menu
      SUGGESTION='default8x16.psfu.gz'
      OPTIONS=($(
        ls /usr/share/kbd/consolefonts | \
        grep -Ev 'README|ERRORS|partialfonts' #| \
        # sed 's/\(\.cp\|\.psfu\|\.psf\|\.fnt\|\)\.gz$//g'
      ))
      OPTIONS+=('cycle')
      TAB_COMPLETIONS=("${OPTIONS[@]}")
      list_options
      m_info "Write 'cycle' to test each font."
      choose console_font
      if [[ "$console_font" == "cycle" ]]; then
        local -a FONTS=()
        for fnt in "${OPTIONS[@]}"; do
          FONTS+=("$fnt")
        done
        SUGGESTION=''
        OPTIONS=('Next font' 'Previous font' 'Select this font' 'Quit cycling mode')
        TAB_COMPLETIONS=('' 'p' 's' 'q')
        local -i fntindex=0
        while : ; do
          tput clear
          setfont "${FONTS[$fntindex]}"
          tput vpa 2
          m_info "Font: ${FONTS[$fntindex]}"
          showconsolefont | nl -w$OFFSET
          enumerate_options
          choose answer
          case $answer in
            p)
              ((fntindex--))
              continue
              ;;
            s)
              console_font="${FONTS[$fntindex]}"
              ;&
            q)
              break
              ;;
          esac
          ((fntindex++))
        done
        setfont
        continue
      else
        break
      fi
    done
  fi
  echo
  m_info "Setting console font to '$console_font'."
  if ! exec_cmd setfont $console_font; then
    m_warn "Couldn't set the console font."
  fi
  echo
  leave_menu
}

# 1.2
function verify_the_boot_mode() {
  enter_menu "Verifying the boot mode"
  draw_menu
  m_info "Checking if efivars exist."
  if exec_cmd ls /sys/firmware/efi/efivars; then
    echo
    m_info "UEFI is enabled."
  else
    echo
    m_info "UEFI is disabled."
  fi
  echo
  leave_menu
}

# 1.3
function connect_to_the_internet() {
  enter_menu "Connect to the Internet"
  draw_menu
  m_info "Checking internet connectivity."
  [[ -z "$ping_address" ]] && ping_address="8.8.8.8"
  if exec_cmd ping -c 1 $ping_address; then
    echo
    m_info "Internet is up and running"
  else
    echo
    m_warn "No active internet connection found"
  fi
  echo
  leave_menu
}

# 1.4 
function update_the_system_clock() {
  enter_menu "Update the system clock"
  draw_menu
  m_info "Enabling NTP synchronization."
  if ! exec_cmd timedatectl set-ntp true; then
    echo
    m_error "Couldn't enable NTP synchronization."
  fi
  echo
  leave_menu
}

# 1.5
function partition_the_disks() {
  enter_menu "Partition the disks"
  draw_menu
  exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
  echo
  SUGGESTION=y
  OPTIONS=(y n)
  TAB_COMPLETIONS=("${OPTIONS[@]}")
  exec_cmd type partition_disks
  echo
  m_info 'Should partitioning command be run now? [Y/n]'
  local partition_now
  choose partition_now
  echo
  if [[ "$partition_now" == "y" ]]; then
    if ! exec_cmd partition_disks; then
      echo
      m_error "Couldn't run partitioning command."
    else
      echo
      m_info 'Finished partitioning.'
      echo
      m_info 'Updated block devices:'
      exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
    fi
  fi
  echo
  leave_menu
}

# 1.6
function format_the_partitions() {
  enter_menu "Format the partitions"
  draw_menu
  exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
  echo
  SUGGESTION=y
  OPTIONS=(y n)
  TAB_COMPLETIONS=("${OPTIONS[@]}")
  exec_cmd type format_partitions
  echo
  m_info 'Should formatting command be run now? [Y/n]'
  local format_now
  choose format_now
  echo
  if [[ "$format_now" == "y" ]]; then
    m_info "Executing format_partitions:"
    if ! exec_cmd format_partitions; then
      echo
      error 'Something went wrong.'
    else
      echo
      m_info 'Finished formatting.'
    fi
  else
    m_info 'Not running command.'
  fi
  echo
  leave_menu
}

# 1.7
function mount_the_file_systems() {
  enter_menu "Mount the file systems"
  draw_menu
  SUGGESTION=y
  OPTIONS=(y n)
  TAB_COMPLETIONS=("${OPTIONS[@]}")
  exec_cmd type mount_partitions
  echo
  m_info 'Should mounting command be run now? [Y/n]'
  local mount_now
  choose mount_now
  echo
  if [[ "$mount_now" == "y" ]]; then
    m_info "Executing mount_partitions:"
    if ! exec_cmd mount_partitions; then
      echo
      error 'Something went wrong.'
    else
      echo
      m_info 'Updated block devices:'
      exec_cmd lsblk -o NAME,TYPE,FSTYPE,LABEL,SIZE,MOUNTPOINT,HOTPLUG
    fi
  else
    m_info 'Not running command.'
  fi
  echo
  leave_menu
}

################################################################################
# 2
function installation() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "2 Installation"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to Main" \
      "2.1 Select the mirrors" \
      "2.2 Install the base packages"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          select_the_mirrors
          ;;
        2)
          push suggestions 0
          install_the_base_packages
          pause
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestions SUGGESTION
    trace "In Installation. Next SUGGESTION: $SUGGESTION."
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
  SUGGESTION=1
  local -r mirrorlist="/etc/pacman.d/mirrorlist"
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || ([[ $SUGGESTION -eq 1 ]] && [[ $SUGGESTION -ne 0 ]]) && \
      __print_title "2.1 Select the mirrors"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to Installation" \
                "Run reflector command" \
                "Manually edit mirrorlist"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      debug "Current option is: $SUGGESTION"
      case "$answer" in
        0)
          return
          ;;
        1)
          if [[ -n "$run_through" ]]; then
            push suggestions 0
          else
            push suggestions 2
          fi
          run_reflector
          ;;
        2)
          push suggestions 0
          NO_PIPE=1 exec_cmd vim "$mirrorlist"
          break
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Select the mirrors. Next SUGGESTION: $SUGGESTION."
  done
}
function run_reflector() {
  local mirrorlist_bak="$mirrorlist.bak"
  local -i i=2
  while [[ -f "$mirrorlist_bak" ]]; do
    mirrorlist_bak="$mirrorlist.bak$i"
    ((i++))
  done
  __newline
  m_info "Backing up mirrorlist to '$mirrorlist_bak'."
  exec_cmd cp "$mirrorlist" "$mirrorlist_bak"
  __newline
  if ! type foo &>/dev/null; then
    m_info 'Reflector not installed. Installing now.'
    if ! exec_cmd pacman --color=always --noconfirm -Sy reflector; then
      __newline
      m_error "Couldn't install reflector."
      return
    fi
    __newline
  fi
  m_info 'Running reflector now(this may take a while).'
  exec_cmd reflector ${reflector_args[*]} --save "$mirrorlist"
  __newline
  m_info 'Done'
}

# 2.2
function install_the_base_packages() {
  __prepare_pane
  __print_title "2.2 Install the base packages"
  local install_now='y'
  [[ -z "$run_through" ]] && __read_answer "Should the base package installation be run now? [Y/n]: " install_now y
  __newline
  if [[ "$install_now" == "y" ]]; then
    m_info "Installing base packages:"
    if ! exec_cmd pacstrap /mnt base sudo wpa_supplicant --color=always; then
      __newline
      error 'Something went wrong.'
    else
      __newline
      m_info 'Finished installing base packages.'
    fi
  else
    m_info 'Not installing base packages.'
  fi
}

################################################################################
# 3
function configure_the_system() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "3 Configure the system"
    [[ -z "$run_through" ]] && [[ -z "$_chroot" ]] && choose_from_enumeration "Return to Main" \
      "3.1 Fstab" \
      "3.2 Chroot" \
      "3.3 Time zone" \
      "3.4 Locale" \
      "3.5 Network configuration" \
      "3.6 Initramfs" \
      "3.7 Root password" \
      "3.8 Boot loader"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && [[ -z "$_chroot" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      [[ -n "$_chroot" ]] && answer=3
      _chroot=
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          fstab
          ;;
        2)
          push suggestions 3
          chroot_into_mnt
          ;;
        3)
          push suggestions 4
          time_zone
          ;;
        4)
          push suggestions 5
          locale
          ;;
        5)
          push suggestions 6
          network_configuration
          ;;
        6)
          push suggestions 7
          initramfs
          ;;
        7)
          push suggestions 8
          root_password
          ;;
        8)
          push suggestions 0
          boot_loader
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Configure the system. Next SUGGESTION: $SUGGESTION."
  done
}

# 3.1
function fstab() {
  while : ; do
    __prepare_pane
    __print_title "3.1 Fstab"
    if [[ -z $fstab_identifier ]] ; then
      fstab_identifier="u"
      [[ -z "$run_through" ]] && __read_answer "Enter option (us): " fstab_identifier "u"
      __read_answer "Use UUIDs(u/U) or labels(l/L)?" answer "U"
      fstab_identifier=$answer
    fi
    __newline
    case "$fstab_identifier" in
      [uU])
        m_info "Using UUIDs to generate the fstab file..."
        fstab_identifier="U"
        ;;
      [lL])
        m_info "Using labels to generate the fstab file..."
        fstab_identifier="L"
        ;;
      *)
        m_error "Please choose an option from above."
        tput rc
        tput dl 2
        continue
    esac
    break
  done
  local fstab_file="/mnt/etc/fstab"
  [[ -n "$test_script" ]] && fstab_file="/dev/null"
  if ! exec_cmd "genfstab -$fstab_identifier /mnt | tee $fstab_file"; then
    m_error "Couldn't generate fstab-file."
  fi
}

# 3.2
function chroot_into_mnt() {
  _chroot=''
  __prepare_pane
  __print_title "3.2 Chroot"
  __newline
  m_info "Copying the files over to the child system."
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
  exec_cmd "cp $bashrc $oldbashrc"
  exec_cmd "echo \"cd\" | tee -a $bashrc"
  exec_cmd "echo \"~/arch.sh -cl $oldlogfile\" | tee -a $bashrc"
  m_info "Please issue now: arch-chroot /mnt"
  exit
}

# 3.3
function time_zone() {
  __prepare_pane
  __print_title "3.3 Time zone"
  if [[ -z $region ]] ; then
    # timedatectl list-timezones | cut -d'/' -f1 | uniq
    local -a options=($(
      ls -l /usr/share/zoneinfo/ | \
      grep -E '^d.*\ [A-Z][a-z]+$' | \
      sed 's/^d.*:[0-9][0-9]\ //g'
    ))
    list_options
    region="Asia"
    [[ -z "$run_through" ]] && __read_answer "Enter option (Asia): " region "Asia"
  fi
  __newline
  m_info "Time zone region chosen to be '$region'."
  if [[ -z $city ]] ; then
    local -a options=($(ls /usr/share/zoneinfo/$region/))
    list_options
    city="Tokyo"
    [[ -z "$run_through" ]] && __read_answer "Enter option (Tokyo): " city "Tokyo"
  fi
  __newline
  m_info "Time zone city chosen to be '$city'."
  __newline
  if ! exec_cmd ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime; then
    __newline
    m_error "Couldn't set time zone."
    return
  fi
  exec_cmd hwclock --systohc
  __newline
  m_info 'Done.'
}

# 3.4
function locale() {
  __prepare_pane
  __print_title "3.4 Locale"
  __newline
  if [ ${#locales[@]} -eq 0 ]; then
    m_info 'Editing /etc/locale.gen file.'
    pause
    NO_PIPE=1 exec_cmd vim /etc/locale.gen
  else
    m_info 'Uncommenting locales.'
    local locale
    for locale in "${locales[@]}"; do
      if ! exec_cmd sed -i "'s/^#$locale/$locale/g'" /etc/locale.gen; then
        m_error "Couldn't uncomment $locale."
        return
      fi
    done
  fi
  __newline
  m_info 'Running locale generator.'
  if ! exec_cmd locale-gen; then
    m_error "Couldn't run locale generator."
    return
  fi
  __newline
  m_info "Setting LANG-variable."
  local file="/etc/locale.conf"
  [[ -n "$test_script" ]] && file="/dev/null"

  if ! exec_cmd "echo \"LANG=$LANG\" | tee $file"; then
    __newline
    m_error "Couldn't persist LANG variable."
    return
  fi
  if [[ -n "$keyboard_layout" ]]; then
    __newline
    m_info "Setting KEYMAP-variable."
    local file="/etc/vconsole.conf"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo \"KEYMAP=$keyboard_layout\" | tee $file"; then
      __newline
      m_error "Couldn't persist KEYMAP variable."
      return
    fi
  fi
}

# 3.5
function network_configuration() {
  __prepare_pane
  __print_title "3.5 Network Configuration"
  __newline
  [[ -n "$run_through" ]] && [[ -z "$hostname" ]] && hostname="arch"
  [[ -z "$hostname" ]] && __read_answer "Please specify a host name [arch]: " hostname "arch"
  m_info 'Setting host name.'
  local file="/etc/hostname"
  [[ -n "$test_script" ]] && file="/dev/null"
  if ! exec_cmd "echo \"$hostname\" | tee $file"; then
    __newline
    m_error "Couldn't save host name."
    return
  fi
  __newline
  m_info 'Writing hosts file.'
  [[ -z "$perm_ip" ]] && perm_ip="127.0.1.1"
  local value="$(cat << eof
127.0.0.1	localhost
::1		localhost
$perm_ip	$hostname.localdomain	$hostname
eof
  )"
  local file="/etc/hosts"
  [[ -n "$test_script" ]] && file="/dev/null"
  if ! exec_cmd "echo \"$value\" | tee $file"; then
    __newline
    m_error "Couldn't write hosts file."
    return
  fi
}

# 3.6
function initramfs() {
  __prepare_pane
  __print_title "3.5 Initramfs"
  __newline
  if [[ -n "$edit_mkinitcpio" ]]; then
    m_info 'Editing /etc/mkinitcpio.conf.'
    NO_PIPE=1 exec_cmd vim "/etc/mkinitcpio.conf"
    if ! exec_cmd mkinitcpio -p linux; then
      m_error "Couldn't rebuild initramfs image."
      return
    fi
    __newline
    m_info 'Done.'
  else
    m_info 'Nothing to do.'
  fi
}

# 3.7
function root_password() {
  __prepare_pane
  __print_title "3.7 Root password"
  __newline
  m_info 'Please set a root password:'
  if ! NO_PIPE=1 exec_cmd passwd; then
    __newline
    m_error "Couldn't set the root password."
    return
  fi
  __newline
  m_info 'Done.'
}

# 3.8
function boot_loader() {
  __prepare_pane
  __print_title "3.8 Boot loader"
  __newline
  m_info 'Executing install_bootloader method:'
  if ! exec_cmd install_bootloader; then
    __newline
    m_error "Couldn't run command successfully."
    return
  fi
  __newline
  m_info 'Checking for Intel.'
  if ! exec_cmd grep \'Intel\' /proc/cpuinfo; then
    __newline
    m_info 'No Intel CPU found.'
    return
  fi
  __newline
  m_info 'Intel CPU detected.'
  if ! exec_cmd pacman --color=always --noconfirm -S intel-ucode; then
    __newline
    m_error "Couldn't install package."
    return
  fi
  __newline
  m_info 'Executing configure_microcode method:'
  if ! exec_cmd configure_microcode; then
    __newline
    m_error "Couldn't run command successfully."
    return
  else
    __newline
    m_info 'Done.'
  fi
}

# 4
function reboot_system() {
  __prepare_pane
  __print_title "4 Reboot"
  __newline
  m_info 'Cleaning up files.'
  local bashrc="/mnt/root/.bashrc"
  local oldbashrc="${bashrc}.bak"
  if [[ -n "$test_script" ]]; then
    bashrc="/dev/null"
    oldbashrc="/dev/null"
  fi
  local bashrc="/mnt/root/.bashrc"
  local oldbashrc="${bashrc}.bak"
  if [[ -n "$test_script" ]]; then
    bashrc="/dev/null"
    oldbashrc="/dev/null"
  fi
  exec_cmd "cp $oldbashrc $bashrc"
  local run=''
  [[ -n "$run_through" ]] && run='r'
  exec_cmd "echo \"~/arch.sh -${run}p\" | tee -a $bashrc"
  __newline
  m_info 'Please exit the chroot now(Ctrl+D) and reboot the system.'
  exit 0
}

################################################################################
# 5
function post_installation() {
  _post=''
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5 Post-Installation"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to Main" \
                "5.1 General Recommendations" \
                "5.2 Applications"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          general_recommendations
          ;;
        2)
          push suggestions 0
          applications
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestions SUGGESTION
    trace "In Post-Installation. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1
function general_recommendations() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1 General Recommendations"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to Post-Installation" \
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
      "5.1.11 Appearance" \
      "5.1.12 Console Improvements"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          system_administration
          ;;
        2)
          push suggestions 3
          package_management
          ;;
        3)
          push suggestions 4
          booting
          ;;
        4)
          push suggestions 5
          gui
          ;;
        5)
          push suggestions 6
          power_management
          ;;
        6)
          push suggestions 7
          multimedia
          ;;
        7)
          push suggestions 8
          networking
          ;;
        8)
          push suggestions 9
          input_devices
          ;;
        9)
          push suggestions 10
          optimization
          ;;
        10)
          push suggestions 11
          system_service
          ;;
        11)
          push suggestions 12
          appearance
          ;;
        12)
          push suggestions 0
          console_improvements
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestions SUGGESTION
    trace "In General Recommendations. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.1
function system_administration() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.1 System Administration"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.1.1 Users and Groups" \
      "5.1.1.2 Privilege Escalation" \
      "5.1.1.3 Service Management" \
      "5.1.1.4 System Maintenance"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          users_and_groups
          ;;
        2)
          push suggestions 3
          privilege_escalation
          ;;
        3)
          push suggestions 4
          service_management
          ;;
        4)
          push suggestions 0
          system_maintenance
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In System Administration. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.1.1
function users_and_groups() {
  __prepare_pane
  __print_title "5.1.1.1 Users and Groups"
  __newline
  m_info "Executing the add_users_and_groups method:"
  if ! exec_cmd add_users_and_groups; then
    __newline
    m_error "Couldn't run command."
  else
    __newline
    m_info 'Done.'
  fi
}

# 5.1.1.2
function privilege_escalation() {
  __prepare_pane
  __print_title "5.1.1.2 Privilege Escalation"
  __newline
  m_info 'Executing the handle_privilage_escalation method:'
  if ! exec_cmd handle_privilage_escalation; then
    __newline
    m_error "Couldn't run command."
  else
    __newline
    m_info 'Done.'
  fi
}

# 5.1.1.3
function service_management() {
  __prepare_pane
  __print_title "5.1.1.3 Service Management"
  __newline
  m_info 'Nothing to do here.'
}

# 5.1.1.4
function system_maintenance() {
  __prepare_pane
  __print_title "5.1.1.4 System Maintenance"
  __newline
  m_info 'Checking if any services failed.'
  if ! exec_cmd systemctl --failed; then
    __newline
    warn 'Failure'
  fi
  __newline
  m_info 'Checking logs.'
  if ! exec_cmd journalctl -p 3 -xb; then
    __newline
    warn 'Failure'
  fi
  __newline
  if [[ -n "$backup_pacman_db" ]]; then
    m_info 'Backing up pacman database.'
    if ! exec_cmd tar -cjf local.bak.tar.bz2 /var/lib/pacman/local; then
      __newline
      warn 'Failure'
    else
      if ! exec_cmd mv local.bak.tar.bz2 /var/lib/pacman/local.bak.tar.bz2; then
        __newline
        warn 'Failure'
      fi
    fi
    __newline
  fi
  if [[ -n "$change_pw_policy" ]]; then
    m_info 'Setting password policy.'
    local file="/etc/pam.d/passwd"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "setup_pw_policy | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$change_lockout_policy" ]]; then
    m_info 'Setting lock out policy.'
    local file="/etc/pam.d/system-login"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "setup_lockout_policy | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if ((faildelay >= 0)); then
    m_info 'Writing fail delay to /etc/pam.d/system-login.'
    local file="/etc/pam.d/system-login"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo \"auth optional pam_faildelay.so delay=$faildelay\" | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  local file="/etc/pam.d/system-login"
  [[ -n "$test_script" ]] && file="/dev/null"
  m_info 'Commenting out deprecated line.'
  if ! exec_cmd sed -i 's/^auth\ *required\ *pam_tally.so.*$/#\0/g' "$file"; then
    __newline
    warn 'Failure'
  fi
  if [[ -n "$install_hardened_linux" ]]; then
    m_info 'Installing hardened linux kernel.'
    if ! exec_cmd pacman --color=always --noconfirm -S linux-hardened; then
      __newline
      warn 'Failure'
    fi
    __newline
  else
    __newline
    if [[ -n "$restrict_k_log_acc" ]]; then
      m_info 'Restricting kernel log access to root.'
      local file="/etc/sysctl.d/50-dmesg-restrict.conf"
      [[ -n "$test_script" ]] && file="/dev/null"
      if ! exec_cmd "echo \"kernel.dmesg_restrict = 1\" | tee -a $file"; then
        __newline
        warn 'Failure'
      fi
      __newline
    fi
    if [[ -n "$restrict_k_ptr_acc" ]]; then
      m_info 'Restricting kernel pointer access.'
      local file="/etc/sysctl.d/50-kptr-restrict.conf"
      [[ -n "$test_script" ]] && file="/dev/null"
      if ! exec_cmd "echo \"kernel.kptr_restrict = $restrict_k_ptr_acc\" | tee -a $file"; then
        __newline
        warn 'Failure'
      fi
      __newline
    fi
  fi
  if [[ -n "$bpf_jit_enable" ]]; then
    m_info 'Disabling the BPF JIT compiler.'
    local file="/proc/sys/net/core/bpf_jit_enable"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo $bpf_jit_enable | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$sandbox_app" ]]; then
    m_info "Installing sandbox application $sandbox_app."
    #echo "$sandbox_app" | sed 's/,/ /g' | sed 's/lxc/lxc arch-install-scripts/g'
    sandbox_app=${sandbox_app/,/ }
    sandbox_app=${sandbox_app/lxc/lxc arch-install-scripts}
    [[ $sandbox_app =~ .*virtualbox.* ]] && \
      warn 'Please install the virtualbox host modules appropriate for your kernel.'
    if ! exec_cmd pacman --color=always --noconfirm -S $sandbox_app; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  m_info 'Kernel hardening.'
  __newline
  if [[ -n "$tcp_max_syn_backlog" ]]; then
    m_info "Setting TCP SYN max backlog to $tcp_max_syn_backlog."
    local file="/proc/sys/net/ipv4/tcp_max_syn_backlog"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo $tcp_max_syn_backlog | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$tcp_syn_cookie_prot" ]]; then
    m_info 'Enabling TCP SYN cookie protection.'
    local file="/proc/sys/net/ipv4/tcp_syncookies"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 1 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$tcp_rfc1337" ]]; then
    m_info 'Enabling TCP rfc1337.'
    local file="/proc/sys/net/ipv4/tcp_rfc1337"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 1 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$log_martians" ]]; then
    m_info 'Enabling martian packet logging.'
    local file="/proc/sys/net/ipv4/conf/default/log_martians"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 1 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    file="/proc/sys/net/ipv4/conf/all/log_martians"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 1 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$icmp_echo_ignore_broadcasts" ]]; then
    m_info 'Ignore echo broadcast requests.'
    local file="/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 1 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$icmp_ignore_bogus_error_responses" ]]; then
    m_info 'Ignore bogus error responses.'
    local file="/proc/sys/net/ipv4/icmp_ignore_bogus_error_responses"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 1 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$send_redirects" ]]; then
    m_info 'Disable sending redirects.'
    local file="/proc/sys/net/ipv4/conf/default/send_redirects"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 0 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    file="/proc/sys/net/ipv4/conf/all/send_redirects"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 0 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$accept_redirects" ]]; then
    m_info 'Disable accepting redirects.'
    local file="/proc/sys/net/ipv4/conf/default/accept_redirects"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 0 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    file="/proc/sys/net/ipv4/conf/all/accept_redirects"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 0 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    file="/proc/sys/net/ipv6/conf/default/accept_redirects"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 0 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    file="/proc/sys/net/ipv6/conf/all/accept_redirects"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "echo 0 | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  m_info 'SSH hardening.'
  __newline
  if [[ -n "$ssh_require_key" ]] || \
    [[ -n "$ssh_deny_root_login" ]] || \
    [[ -n "$ssh_client" ]]; then
    m_info 'Installing OpenSSH.'
    if ! exec_cmd pacman --color=always --noconfirm -S $ssh_client; then
      __newline
      warn 'Failure'
    else
      __newline
      if [[ -n "$ssh_require_key" ]]; then
        m_info 'Setting SSH keys as requirement.'
        local file="/etc/ssh/sshd_config"
        [[ -n "$test_script" ]] && file="/dev/null"
        if ! exec_cmd sed -i 's/^# *\(PasswordAuthentication\).*$/\1 no/g' "$file"; then
          __newline
          warn 'Failure'
        fi
        __newline
      fi
      if [[ -n "$ssh_deny_root_login" ]]; then
        m_info 'Disabling root login.'
        local file="/etc/ssh/sshd_config"
        [[ -n "$test_script" ]] && file="/dev/null"
        if ! exec_cmd sed -i 's/^# *\(PermitRootLogin\).*$/\1 no/g' "$file"; then
          __newline
          warn 'Failure'
        fi
        __newline
      fi
    fi
  fi
  m_info 'DNS hardening.'
  __newline
  if [[ -n "$install_dnssec" ]]; then
    m_info 'Installing dnssec.'
    if ! exec_cmd pacman --color=always --noconfirm -S ldns; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  if [[ -n "$install_dnscrypt" ]]; then
    m_info 'Installing dnscrypt.'
    if ! exec_cmd pacman --color=always --noconfirm -S dnscrypt-proxy; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  m_info 'Proxy hardening.'
  __newline
  if [[ -n "$install_dnsmasq" ]]; then
    m_info 'Installing dnsmasq.'
    if ! exec_cmd pacman --color=always --noconfirm -S dnsmasq; then
      __newline
      warn 'Failure'
    else
      __newline
      m_info 'Enabling service.'
      if ! exec_cmd systemctl enable dnsmasq.service; then
        __newline
        warn 'Failure'
      fi
    fi
    __newline
  fi
  m_info 'Done.'
}

# 5.1.2
function package_management() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.2 Package Management"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.2.1 Pacman" \
      "5.1.2.2 Repositories" \
      "5.1.2.3 Mirrors" \
      "5.1.2.4 Arch Build System" \
      "5.1.2.5 Arch User Repository"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          pacman_menu
          ;;
        2)
          push suggestions 3
          repositories
          ;;
        3)
          push suggestions 4
          mirrors
          ;;
        4)
          push suggestions 5
          arch_build_system
          ;;
        5)
          push suggestions 0
          arch_user_repository
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Package Management. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.2.1
function pacman_menu() {
  __prepare_pane
  __print_title "5.1.2.1 Pacman"
  __newline
  m_info 'Nothing to do.'
}

# 5.1.2.2
function repositories() {
  __prepare_pane
  __print_title "5.1.2.2 Repositories"
  __newline
  if [[ -n "$enable_multilib" ]]; then
    m_info 'Enabling multilib.'
    local file="/etc/pacman.conf"
    [[ -n "$test_script" ]] && file="/dev/null"
    if ! exec_cmd "cat $file | sed -z 's/#\(\[multilib\]\)\n#\(Include.*mirrorlist\)/\1\n\2/g' | tee $file"; then
      __newline
      warn 'Failure'
    else
      exec_cmd pacman -Sy
    fi
    __newline
  fi
  m_info 'Running setup_unoff_usr_repo method:'
  if ! exec_cmd setup_unoff_usr_repo; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  if [[ -n "$install_pkgstats" ]]; then
    m_info 'Installing pkgstats.'
    if ! exec_cmd pacman --color=always --noconfirm -S pkgstats; then
      __newline
      warn 'Failure'
    fi
    __newline
  fi
  m_info 'Done.'
}

# 5.1.2.3
function mirrors() {
  __prepare_pane
  __print_title "5.1.2.3 Mirrors"
  __newline
  m_info 'Nothing to do.'
}

# 5.1.2.4
function arch_build_system() {
  __prepare_pane
  __print_title "5.1.2.4 Arch Build System"
  __newline
  m_info 'Nothing to do.'
}

# 5.1.2.5
function arch_user_repository() {
  __prepare_pane
  __print_title "5.1.2.5 Arch User Repository"
  __newline
  if [[ -n "$aur_helper" ]]; then
    m_info 'Running install_aur_helper method:'
    install_aur_helper
    if ! check_retval $? ; then
      __newline
      error 'Failed.'
      return
    fi
  else
    m_info 'No AUR helper specified. Please install AUR packages manually.'
  fi
  __newline
  m_info 'Done.'
}

# 5.1.3
function booting() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.3 Booting"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.3.1 Hardware auto-recognition" \
      "5.1.3.2 Microcode" \
      "5.1.3.3 Retaining boot messages" \
      "5.1.3.4 Num Lock activation"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          hardware_auto_recognition
          ;;
        2)
          push suggestions 3
          microcode
          ;;
        3)
          push suggestions 4
          retaining_boot_messages
          ;;
        4)
          push suggestions 0
          num_lock_activation
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Booting. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.3.1
function hardware_auto_recognition() {
  __prepare_pane
  __print_title "5.1.3.1 Hardware auto-recognition"
  __newline
  m_info 'Running setup_hardware_auto_recognition method:'
  setup_hardware_auto_recognition
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.3.2
function microcode() {
  __prepare_pane
  __print_title "5.1.3.2 Microcode"
  __newline
  m_info 'Nothing to do. Done already.'
}

# 5.1.3.3
function retaining_boot_messages() {
  __prepare_pane
  __print_title "5.1.3.3 Retaining boot messages"
  __newline
  if [[ -n "$retain_boot_msgs" ]]; then
    m_info 'Creating service unit edit.'
    local file="/etc/systemd/system/getty@tty1.service.d/noclear.conf"
    if [[ -n "$test_script" ]]; then
      file="/dev/null"
    else
      exec_cmd mkdir -p "$(dirname $file)"
    fi
    if ! exec_cmd "echo \"[Service]
TTYVTDisallocate=no\" | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
    m_info 'Done.'
  else
    m_info 'Nothing to do.'
  fi
}

# 5.1.3.4
function num_lock_activation() {
  __prepare_pane
  __print_title "5.1.3.4 Num Lock activation"
  __newline
  if [[ -n "$activate_numlock_on_boot" ]]; then
    m_info 'Extending getty service.'
    local file="/etc/systemd/system/getty@tty1.service.d/activate-numlock.conf"
    if [[ -n "$test_script" ]]; then
      file="/dev/null"
    else
      exec_cmd mkdir -p "$(dirname $file)"
    fi
    if ! exec_cmd "echo \"[Service]
ExecStartPre=/bin/sh -c 'setleds -D +num < /dev/%I'\" | tee $file"; then
      __newline
      warn 'Failure'
    fi
    __newline
    m_info 'Done.'
  else
    m_info 'Nothing to do.'
  fi
}

# 5.1.4
function gui() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.4 Graphical User Interface"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.4.1 Display server" \
      "5.1.4.2 Display drivers" \
      "5.1.4.3 Desktop environments" \
      "5.1.4.4 Window managers" \
      "5.1.4.5 Display manager"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          display_server
          ;;
        2)
          push suggestions 3
          display_drivers
          ;;
        3)
          push suggestions 4
          desktop_environments
          ;;
        4)
          push suggestions 5
          window_managers
          ;;
        5)
          push suggestions 0
          display_manager
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Graphical User Interface. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.4.1
function display_server() {
  __prepare_pane
  __print_title "5.1.4.1 Display server"
  __newline
  case "$disp_server" in
    xorg)
      m_info 'Installing Xorg:'
      if ! exec_cmd pacman --color=always --noconfirm -S xorg; then
        __newline
        warn 'Failure'
      fi
      ;;
    wayland)
      m_info 'Installing Wayland:'
      if ! exec_cmd pacman --color=always --noconfirm -S weston; then
        __newline
        warn 'Failure'
      fi
      ;;
      *)
      m_info "No instruction found for $disp_server."
  esac
  __newline
  m_info 'Done.'
}

# 5.1.4.2
function display_drivers() {
  __prepare_pane
  __print_title "5.1.4.2 Display drivers"
  __newline
  m_info 'Running install_display_drivers method:'
  install_display_drivers
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.4.3
function desktop_environments() {
  __prepare_pane
  __print_title "5.1.4.3 Desktop environments"
  __newline
  m_info 'Running install_de method:'
  install_de
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.4.4
function window_managers() {
  __prepare_pane
  __print_title "5.1.4.4 Window managers"
  __newline
  m_info 'Running install_wm method:'
  install_wm
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.4.5
function display_manager() {
  __prepare_pane
  __print_title "5.1.4.5 Display manager"
  __newline
  m_info 'Running install_dm method:'
  install_dm
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.5
function power_management() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.5 Power management"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.5.1 ACPI events" \
      "5.1.5.2 CPU frequency scaling" \
      "5.1.5.3 Laptops" \
      "5.1.5.4 Suspend and Hibernate"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          acpi_events
          ;;
        2)
          push suggestions 3
          cpu_frequency_scaling
          ;;
        3)
          push suggestions 4
          laptops
          ;;
        4)
          push suggestions 0
          suspend_and_hibernate
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Power Management. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.5.1
function acpi_events() {
  __prepare_pane
  __print_title "5.1.5.1 ACPI events"
  __newline
  if [[ -n "$install_acpid" ]]; then
    m_info 'Installing acpid.'
    if ! exec_cmd pacman --color=always --noconfirm -S acpid; then
      __newline
      warn 'Failure'
    else
      if ! exec_cmd systemctl enable acpid.service; then
        __newline
        warn 'Failure'
      fi
    fi
    __newline
  fi
  m_info 'Executing the setup_acpi method:'
  if ! exec_cmd setup_acpi; then
    __newline
    m_error "Couldn't run command."
  else
    __newline
    m_info 'Done.'
  fi
}

# 5.1.5.2
function cpu_frequency_scaling() {
  __prepare_pane
  __print_title "5.1.5.2 CPU frequency scaling"
  __newline
  m_info 'Running setup_cpu_freq_scal method:'
  setup_cpu_freq_scal
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.5.3
function laptops() {
  __prepare_pane
  __print_title "5.1.5.3 Laptops"
  __newline
  m_info 'Running setup_laptop method:'
  setup_laptop
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.5.4
function suspend_and_hibernate() {
  __prepare_pane
  __print_title "5.1.5.4 Suspend and Hibernate"
  __newline
  m_info 'Running setup_susp_and_hiber method:'
  setup_susp_and_hiber
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.6
function multimedia() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.6 Multimedia"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.6.1 Sound" \
      "5.1.6.2 Browser plugins" \
      "5.1.6.3 Codecs"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          sound
          ;;
        2)
          push suggestions 3
          browser_plugins
          ;;
        3)
          push suggestions 0
          codecs
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Multimedia. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.6.1
function sound() {
  __prepare_pane
  __print_title "5.1.6.1 Sound"
  __newline
  m_info 'Running setup_sound method:'
  setup_sound
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.6.2
function browser_plugins() {
  __prepare_pane
  __print_title "5.1.6.2 Browser plugins"
  __newline
  m_info 'Running setup_browser_plugins method:'
  setup_browser_plugins
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.6.3
function codecs() {
  __prepare_pane
  __print_title "5.1.6.3 Codecs"
  __newline
  m_info 'Running setup_codecs method:'
  setup_codecs
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.7
function networking() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.7 Networking"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.7.1 Clock synchronization" \
      "5.1.7.2 DNS security" \
      "5.1.7.3 Setting up a firewall" \
      "5.1.7.4 Resource sharing"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          clock_synchronization
          ;;
        2)
          push suggestions 3
          dns_security
          ;;
        3)
          push suggestions 4
          setting_up_a_firewall
          ;;
        4)
          push suggestions 0
          resource_sharing
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Networking. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.7.1
function clock_synchronization() {
  __prepare_pane
  __print_title "5.1.7.1 Clock synchronization"
  __newline
  m_info 'Running setup_clock_sync method:'
  setup_clock_sync
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.7.2
function dns_security() {
  __prepare_pane
  __print_title "5.1.7.2 DNS security"
  __newline
  m_info 'Running setup_dns_sec method:'
  setup_dns_sec
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.7.3
function setting_up_a_firewall() {
  __prepare_pane
  __print_title "5.1.7.3 Setting up a firewall"
  __newline
  m_info 'Running setup_firewall method:'
  setup_firewall
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.7.4
function resource_sharing() {
  __prepare_pane
  __print_title "5.1.7.4 Resource sharing"
  __newline
  m_info 'Nothing to do.'
}


# 5.1.8
function input_devices() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.8 Input devices"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.8.1 Keyboard layouts" \
      "5.1.8.2 Mouse buttons" \
      "5.1.8.3 Laptop touchpads" \
      "5.1.8.4 TrackPoints"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          keyboard_layouts
          ;;
        2)
          push suggestions 3
          mouse_buttons
          ;;
        3)
          push suggestions 4
          laptop_touchpads
          ;;
        4)
          push suggestions 0
          trackpoints
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Input devices. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.8.1
function keyboard_layouts() {
  __prepare_pane
  __print_title "5.1.8.1 Keyboard layouts"
  __newline
  if ! exec_cmd localectl set-x11-keymap \
    "\"$x11_keymap_layout\"" \
    "\"$x11_keymap_model\"" \
    "\"$x11_keymap_variant\"" \
    "\"$x11_keymap_options\"" ; then
    __newline
    m_error "Couldn't set keyboard layouts."
  else
    __newline
    m_info 'Done.'
  fi
}

# 5.1.8.2
function mouse_buttons() {
  __prepare_pane
  __print_title "5.1.8.2 Mouse buttons"
  __newline
  m_info 'Running setup_mouse method:'
  setup_mouse
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.8.3
function laptop_touchpads() {
  __prepare_pane
  __print_title "5.1.8.3 Laptop touchpads"
  __newline
  m_info 'Running setup_touchpad method:'
  setup_touchpad
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.8.4
function trackpoints() {
  __prepare_pane
  __print_title "5.1.8.4 TrackPoints"
  __newline
  m_info 'Running setup_trackpoints method:'
  setup_trackpoints
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.9
function optimization() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.9 Optimization"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.9.1 Benchmarking" \
      "5.1.9.2 Improving performance" \
      "5.1.9.3 Solid state drives"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          benchmarking
          ;;
        2)
          push suggestions 3
          improving_performance
          ;;
        3)
          push suggestions 0
          solid_state_drives
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Optimization. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.9.1
function benchmarking() {
  __prepare_pane
  __print_title "5.1.9.1 Benchmarking"
  __newline
  m_info 'Running setup_benchmarking method:'
  setup_benchmarking
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.9.2
function improving_performance() {
  __prepare_pane
  __print_title "5.1.9.2 Improving performance"
  __newline
  m_info 'Running setup_benchmarking method:'
  setup_benchmarking
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.9.3
function solid_state_drives() {
  __prepare_pane
  __print_title "5.1.9.3 Solid state drives"
  __newline
  m_info 'Running setup_ssd method:'
  setup_ssd
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.10
function system_service() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.10 System service"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.10.1 File index and search" \
      "5.1.10.2 Local mail delivery" \
      "5.1.10.3 Printing"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          file_index_and_search
          ;;
        2)
          push suggestions 3
          local_mail_delivery
          ;;
        3)
          push suggestions 0
          printing
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In System service. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.10.1
function file_index_and_search() {
  __prepare_pane
  __print_title "5.1.10.1 File index and search"
  __newline
  m_info 'Running setup_file_index_and_search method:'
  setup_file_index_and_search
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.10.2
function local_mail_delivery() {
  __prepare_pane
  __print_title "5.1.10.2 Local mail delivery"
  __newline
  m_info 'Running setup_mail method:'
  setup_mail
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.10.3
function printing() {
  __prepare_pane
  __print_title "5.1.10.3 Printing"
  __newline
  m_info 'Running setup_printing method:'
  setup_printing
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.11
function appearance() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.11 Appearance"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.11.1 Fonts" \
      "5.1.11.2 GTK+ and Qt themes"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          fonts
          ;;
        2)
          push suggestions 0
          gtkp_and_qt_themes
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Appearance. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.11.1
function fonts() {
  __prepare_pane
  __print_title "5.1.11.1 Fonts"
  __newline
  m_info 'Running setup_fonts method:'
  setup_fonts
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.11.2
function gtkp_and_qt_themes() {
  __prepare_pane
  __print_title "5.1.11.2 GTK+ and Qt themes"
  m_info 'Running setup_gtk_qt method:'
  setup_gtk_qt
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.1.12
function console_improvements() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.1.12 Console improvements"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to General Recommendations" \
      "5.1.12.1 Tab-completion enhancements" \
      "5.1.12.2 Aliases" \
      "5.1.12.3 Alternative shells" \
      "5.1.12.4 Bash additions" \
      "5.1.12.5 Colored output" \
      "5.1.12.6 Compressed files" \
      "5.1.12.7 Console prompt" \
      "5.1.12.8 Emacs shell" \
      "5.1.12.9 Mouse support" \
      "5.1.12.10 Scrollback buffer" \
      "5.1.12.11 Session management"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          tab_completion_enhancements
          ;;
        2)
          push suggestions 3
          aliases
          ;;
        3)
          push suggestions 4
          alternative_shells
          ;;
        4)
          push suggestions 5
          bash_additions
          ;;
        5)
          push suggestions 6
          colored_output
          ;;
        6)
          push suggestions 7
          compressed_files
          ;;
        7)
          push suggestions 8
          console_prompt
          ;;
        8)
          push suggestions 9
          emacs_shell
          ;;
        9)
          push suggestions 10
          mouse_support
          ;;
        10)
          push suggestions 11
          scrollback_buffer
          ;;
        11)
          push suggestions 0
          session_management
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      pause
      break
    done
    pop suggestions SUGGESTION
    trace "In Console improvements. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.1.12.1
function tab_completion_enhancements() {
  __prepare_pane
  __print_title "5.1.12.1 Tab-completion enhancements"
  __newline
  m_info 'Running setup_tab_completion method:'
  setup_tab_completion
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.2
function aliases() {
  __prepare_pane
  __print_title "5.1.12.2 Aliases"
  __newline
  m_info 'Running setup_aliases method:'
  setup_aliases
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.3
function alternative_shells() {
  __prepare_pane
  __print_title "5.1.12.3 Alternative shells"
  m_info 'Running setup_alt_shell method:'
  setup_alt_shell
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.4
function bash_additions() {
  __prepare_pane
  __print_title "5.1.12.4 Bash additions"
  __newline
  m_info 'Running setup_bash_additions method:'
  setup_bash_additions
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.5
function colored_output() {
  __prepare_pane
  __print_title "5.1.12.5 Colored output"
  __newline
  m_info 'Running setup_colored_output method:'
  setup_colored_output
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.6
function compressed_files() {
  __prepare_pane
  __print_title "5.1.12.6 Compressed files"
  __newline
  m_info 'Running setup_compressed_files method:'
  setup_compressed_files
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.7
function console_prompt() {
  __prepare_pane
  __print_title "5.1.12.7 Console prompt"
  __newline
  m_info 'Running setup_console_prompt method:'
  setup_console_prompt
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.8
function emacs_shell() {
  __prepare_pane
  __print_title "5.1.12.8 Emacs shell"
  __newline
  m_info 'Running setup_emacs_shell method:'
  setup_emacs_shell
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.9
function mouse_support() {
  __prepare_pane
  __print_title "5.1.12.9 Mouse support"
  __newline
  m_info 'Running setup_mouse_support method:'
  setup_mouse_support
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.10
function scrollback_buffer() {
  __prepare_pane
  __print_title "5.1.12.10 Scrollback buffer"
  __newline
  m_info 'Running setup_scrollback_buffer method:'
  setup_scrollback_buffer
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

# 5.1.12.11
function session_management() {
  __prepare_pane
  __print_title "5.1.12.11 Session management"
  __newline
  m_info 'Running setup_session_management method:'
  setup_session_management
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}


# 5.2
function applications() {
  install_packages
  return
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.2 Applications"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to Post-Installation" \
      "5.2.1 Internet" \
      "5.2.2 Multimedia" \
      "5.2.3 Utilities" \
      "5.2.4 Documents and texts" \
      "5.2.5 Security" \
      "5.2.6 Science" \
      "5.2.7 Others"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          internet
          ;;
        2)
          push suggestions 3
          multimedia_applications
          ;;
        3)
          push suggestions 4
          utilities
          ;;
        4)
          push suggestions 5
          documents_and_texts
          ;;
        5)
          push suggestions 6
          security
          ;;
        6)
          push suggestions 7
          science
          ;;
        7)
          push suggestions 0
          others
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestions SUGGESTION
    trace "In Applications. Next SUGGESTION: $SUGGESTION."
  done
}

# 5.2.1
function internet() {
  SUGGESTION=1
  while : ; do
    __prepare_pane
    [[ -z "$run_through" ]] || [[ $SUGGESTION -eq 1 ]] && __print_title "5.2.1 Internet"
    [[ -z "$run_through" ]] && choose_from_enumeration "Return to Post-Installation" \
      "5.2.1.1 Network connection" \
      "5.2.1.2 Web browsers" \
      "5.2.1.3 Web servers" \
      "5.2.1.4 ACME clients" \
      "5.2.1.5 File sharing" \
      "5.2.1.6 Communication" \
      "5.2.1.7 News, RSS, and blogs" \
      "5.2.1.8 Remote desktop"
    while : ; do
      answer=$SUGGESTION
      [[ -z "$run_through" ]] && __read_answer "Enter option [$SUGGESTION]: " answer $SUGGESTION
      case "$answer" in
        0)
          return
          ;;
        1)
          push suggestions 2
          network_connection
          ;;
        2)
          push suggestions 3
          web_browsers
          ;;
        3)
          push suggestions 4
          web_servers
          ;;
        4)
          push suggestions 5
          acme_clients
          ;;
        5)
          push suggestions 6
          file_sharing
          ;;
        6)
          push suggestions 7
          communication
          ;;
        7)
          push suggestions 8
          news_rss_and_blogs
          ;;
        8)
          push suggestions 0
          remote_desktop
          ;;
        *)
          __newline
          m_error "Please choose an option from above."
          tput rc
          tput dl 2
          continue
          ;;
      esac
      break
    done
    pop suggestions SUGGESTION
    trace "In Internet. Next SUGGESTION: $SUGGESTION."
  done
}


# 5.2.X
install_packages() {
  __prepare_pane
  __print_title "5.2.X Applications (not yet completed)"
  __newline
  m_info 'Installing packages:'
  if ! exec_cmd pacman --color=always -S ${packages[*]}; then
    __newline
    m_error "Couldn't install packages."
  else
    __newline
    m_info 'Done.'
  fi
  m_info 'Installing AUR packages:'
  if ! exec_cmd $aur_helper --color=always -S ${aur_packages[*]}; then
    __newline
    m_error "Couldn't install packages."
  else
    __newline
    m_info 'Done.'
  fi
  __newline
  m_info 'Running aftermath method:'
  aftermath
  if ! check_retval $? ; then
    __newline
    error 'Failed.'
    return
  fi
  __newline
  m_info 'Done.'
}

#################################################
# Helpers

function pause() {
    [[ -n "$post_prompt" ]] && tput cuf $OFFSET && read
}
function __newline() {
    echo
    tput cuf $left
}
function __print_title() {
  local title="$1"
  [[ -z "$run_through" ]] && __newline
  __newline
  local IFS='.'
  printf '%s' "${FG_WHITE}${UNDERLINE}${BOLD}$1${RESET}"
  IFS=' '
  trace "Printed title: '$1'"
  __newline
}
function __read_answer() {
  trace "Reading answer."
  tput sc
  __newline
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
  debug "$*"
  tput cuf $OFFSET
  echo " ${CODE}${FG_LBLUE}${BOLD}\$ ${CODE}$*${RESET}"
  if [[ -n "$NO_PIPE" ]]; then
    OFFSET=$OFFSET_NORMAL eval "$*"
  else
    OFFSET=$OFFSET_NORMAL eval "$*" 2>&1 | nl -w $OFFSET -b a -s' ' | sed "s/^..\{$OFFSET\}/${BG_GRAY}${FG_BLACK}\0${RESET}/g"
  fi
  local retval=$(check_retval ${PIPESTATUS[0]})
  return $retval
}
function __prepare_pane() {
  if [[ -n "$run_through" ]]; then
    left=$(((${#FUNCNAME[@]}-3)*2))
    [[ -n "$test_script" ]] && ((left--))
  else
    tput clear
  fi
}
function enter_menu() { # title_of_menu
  # Update suggestion
  [[ -n "$SUGGESTION" ]] && push suggestions "$SUGGESTION"
  # Update title
  [[ -n "$TITLE" ]] && push titles "$TITLE"
  TITLE="$1"
  # Update level
  [[ -n "$NEXTLEVEL" ]] && push levels "$NEXTLEVEL"
  LEVEL=$NEXTLEVEL
  NEXTLEVEL=
  # Update menu string
  [[ -n "$MENU_STRING" ]] && push menu_strings "$MENU_STRING"
  MENU_STRING="$TITLE"
  local level_string=$(_get_level_string)
  [[ -n "$level_string" ]] && MENU_STRING="$level_string $MENU_STRING"
  # Update indentation level
  _update_indentation 0

  # Reset variables
  OPTIONS=()
  TAB_COMPLETIONS=()
  SUGGESTION=1
  MENU_DRAWN=

  trace "Entered menu '$MENU_STRING'. TITLE='$TITLE', LEVEL='$LEVEL', MENU_STRING='$MENU_STRING'"
}
function _get_level_string() {
  local -i i
  local level_string
  for ((i=0;i<${#levels[@]};i++)); do
    level_string="$level_string.${levels[$i]}"
  done
  echo "${level_string#?}"
}
function _update_indentation() { # subtract(When we leave => OFFSET)
  if [[ -n "$run_through" ]]; then
    local -i nesting=$(((${#FUNCNAME[@]}-1)/3-1-$1))
    #[[ -n "$test_script" ]] && ((nesting--))
    OFFSET=$((nesting*2+OFFSET_RUNTHROUGH_MIN))
  else
    OFFSET=$OFFSET_NORMAL
  fi
}
function draw_menu() {
  if [[ -z "$run_through" ]]; then
    tput clear
    tput cup 2 $OFFSET
  else
    #echo # tput cud's don't work when at the bottom of the terminal
    tput cuf $OFFSET
  fi
  if [[ -z "$MENU_DRAWN" ]] || [[ -z "$run_through" ]]; then
    printf '%s' "${FG_LBLUE}${UNDERLINE}${BOLD}$MENU_STRING${RESET}"
    trace "Drawn menu: '$MENU_STRING'"
    echo
    echo
  fi
  MENU_DRAWN=1
}
function leave_menu() {
  # Update suggestion
  pop suggestions SUGGESTION
  # Update title
  pop titles TITLE
  # Update level
  pop levels LEVEL
  NEXTLEVEL=
  # Update menu string
  pop menu_strings MENU_STRING
  
  # Tell the user
  m_info "${FG_CYAN}Returning to ${FG_LCYAN}$TITLE${FG_CYAN}.${RESET}"
  pause

  # Update indentation level
  _update_indentation 1
}
function choose_submenu() {
  TAB_COMPLETIONS=()
  local -i index
  for ((index=1;index<=${#OPTIONS[@]};index++)); do
    if [[ "$SUGGESTION" == "${OPTIONS[$((index-1))]}" ]]; then
      SUGGESTION=$index
    fi
    TAB_COMPLETIONS+=($index)
  done
  if _has_parent_menu; then
    TAB_COMPLETIONS+=('r')
    OPTIONS+=("${FG_CYAN}Return to ${FG_LCYAN}$(_get_parent_menu)${RESET}")
  fi
  TAB_COMPLETIONS+=('q')
  OPTIONS+=("${FG_LRED}Quit${RESET}")
  if [[ -n "$run_through" ]]; then
    evaluate_submenu_choice $SUGGESTION
    return $?
  fi
  enumerate_options
  echo
  local choice
  choose choice
  evaluate_submenu_choice $choice
}
function choose_from_enumeration() { # choice(out)
  local choice_pntr="$1"
  local choice_val
  if [[ -z "$SKIPCHOICE" ]] || [[ -z "$run_through" ]]; then
    local first=1
    while ! _validate_choice $choice_val; do
      tput vpa 4 # Beware: Fragile
      tput cuf $OFFSET
      _print_enumerated_options
      if [[ -z "$first" ]]; then
        tput cuf $OFFSET
        m_error "Error: '$choice_val' is not an option. Please choose one of the options."
        tput cuu1
      fi
      echo
      tput dl 3 # in case the user writes a ", we need to delete the error msg.
      _read_choice choice_val
      first=
    done
  else # Assume run_through
    choice_val="$SUGGESTION"
  fi
  eval "$choice_pntr='$choice_val'"
}
function print_is_suggestion_prefix() { # current_option
  [[ -z "$1" ]] || [[ "$SUGGESTION" == "$1" ]] && printf "${FG_YELLOW}"
}
function list_options() {
  local -i maxwidth=$(($(tput cols)-OFFSET))
  local -i width=0
  local first=1
  local option
  tput cuf $OFFSET
  for option in "${OPTIONS[@]}"; do
    width=$((width+${#option}))
    if [[ -n "$first" ]]; then
      first=
    else
      ((width < maxwidth)) && printf ' '
      ((width++))
    fi
    #echo "$(tput cuf 2)Width: $width/$maxwidth"
    if ((width > maxwidth)); then
      echo
      tput cuf $OFFSET
      width=$((${#option}+1))
    fi
    printf "$(print_is_suggestion_prefix "$option")$option${RESET}"
  done
  echo
}
function enumerate_options() {
  local -i char_maxwidth=0
  local tab_comp
  for tab_comp in "${TAB_COMPLETIONS[@]}"; do
    ((char_maxwidth<${#tab_comp})) && char_maxwidth=${#tab_comp}
  done
  local -i _index=1
  for ((_index=0;_index<${#OPTIONS[@]};_index++)); do
    local option_char="${TAB_COMPLETIONS[$_index]}"
    local option="${OPTIONS[$_index]}"
    print_enumerated_option "$option_char" $char_maxwidth "$option"
  done
}
function print_enumerated_option() { # key, keymaxwidth, option
  local key="$1"
  local -i keymaxwidth=$2
  local option="$3"
  tput cuf $OFFSET
  printf "${FG_GRAY}[${FG_LBLUE}"
  print_is_suggestion_prefix "$key"
  printf "$key"
  if ((${#key}<keymaxwidth)); then
    printf "%*.${keymaxwidth}s" $((${#key}-keymaxwidth)) ' '
  fi
  printf "${FG_GRAY}] ${FG_LBLUE}"
  print_is_suggestion_prefix "$key"
  printf "$3${RESET}\n"
}
function choose() { # choice(out)
  local choice_pntr="$1"
  local choice_val
  if [[ -z "$SKIPCHOICE" ]] || [[ -z "$run_through" ]]; then
    local first=1
    tput cuf $OFFSET
    tput sc
    while : ; do
      tput rc
      tput dl 3 # in case the user writes a ", we need to delete the error msg.
      if [[ -z "$first" ]]; then
        echo
        m_error "Error: '$choice_val' is not an option. Please choose one of the options."
        tput cuu 2
      fi
      _read_choice choice_val
      [[ -z "$choice_val" ]] && choice_val="$SUGGESTION"

      first=
      _validate_choice $choice_val && break
    done
  else # Assume run_through
    choice_val="$SUGGESTION"
  fi
  eval "$choice_pntr='$choice_val'"
}
function _validate_choice() { # choice
  local choice="$1"
  for option in "${TAB_COMPLETIONS[@]}"; do
    [[ "$option" == "$choice" ]] && return $EX_OK
  done
  return $EX_ERR
}
function _read_choice() { # choice(out)
  local _choice_pntr="$1"
  local _choice_val
  enable_tab_completion
  read -erp "$(tput hpa $OFFSET)${FG_WHITE}Enter choice ${FG_GRAY}[$(print_is_suggestion_prefix $SUGGESTION)$SUGGESTION${RESET}${FG_GRAY}]${RESET}: " _choice_val
  clean_tab_suggestions
  disable_tab_completion
  [[ -z "$_choice_val" ]] && _choice_val="$SUGGESTION"
  eval "$_choice_pntr='$_choice_val'"
}
function evaluate_submenu_choice() { # choice
  local _choice_val="$1"
  case "$_choice_val" in
    r)
      return $EX_ERR
      ;;
    q)
      exit $EX_OK
      ;;
    *)
      NEXTLEVEL=$_choice_val
      local next_menu="${OPTIONS[$(($NEXTLEVEL-1))]}"
      local next_method="$(printf "$next_menu" | tr '[:upper:]' '[:lower:]' | sed -e 's/-\|\s/_/g')"
      SUGGESTION=$(_get_next_suggestion $_choice_val)
      trace "Chose $NEXTLEVEL: '$next_menu'. Executing: $next_method. Next suggestion: $SUGGESTION"
      $next_method
      ;;
  esac
}
function tab_prefix() { tput cuf $OFFSET; printf "${FG_WHITE}"; }
function _get_next_suggestion() { # old_suggestion
  case $1 in
    r|g)
      if _has_parent_menu; then
        echo "r"
      else
        echo "q"
      fi
      ;;
    *)
      local candidate=$(($1+1))
      local -i _index
      for ((_index=1;_index<=${#TAB_COMPLETIONS[@]};_index++)); do
        if [[ "$candidate" == "${TAB_COMPLETIONS[$((_index-1))]}" ]]; then
          echo "$candidate"
          return
        fi
      done
      if _has_parent_menu; then
        echo "r"
      else
        echo "q"
      fi
      ;;
  esac
}
function _has_parent_menu() {
  return $((1-(menu_strings_i>0)))
}
function _get_parent_menu() {
  local menu_string
  peek menu_strings menu_string
  printf "$menu_string"
}

# Format logs
function m_info() {
  tput cuf $OFFSET
  info "$@"
}
function m_warn() {
  tput cuf $OFFSET
  warn "$@"
}
function m_error() {
  tput cuf $OFFSET
  error "$@"
}
function m_fatal() {
  tput cuf $OFFSET
  fatal "$@"
}
# Variables
declare SUGGESTION
declare_stack suggestions
declare -a OPTIONS=()
declare TITLE
declare_stack titles
declare -i LEVEL
declare -i NEXTLEVEL
declare_stack levels
declare MENU_STRING
declare_stack menu_strings
declare -i OFFSET
declare -ir OFFSET_RUNTHROUGH_MIN=2
declare -ir OFFSET_NORMAL=4
declare MENU_DRAWN
declare SKIPCHOICE
declare -r CODE="${BG_GRAY}${FG_LGRAY}${BOLD}"

if [[ -z "$unittest" ]]; then
  main
else
  run_unittests
fi
