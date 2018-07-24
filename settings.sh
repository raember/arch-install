#!/bin/bash
#
################################################################################
#   Script Settings
run_through= # Don't let user navigate(default: '')
post_prompt=1 # Wait after every part(default: '')

################################################################################
# 1 Pre-Installation
#
#### 1.1 Set the keyboard layout
keyboard_layout="de_CH-latin1"
console_font="Lat2-Terminus16.psfu.gz"
  # Sans-serif-fonts with only moderate eyecancer(I don't like serif fonts):
  # cybercafe.fnt.gz
  # gr928-8x16-thin.psfu.gz
  # greek-polytonic.psfu.gz
  # Lat2-Terminus16.psfu.gz
  # LatGrkCyr-8x16.psfu.gz
#### 1.2 Verify the boot mode
#### 1.3 Connect to the Internet
ping_address="archlinux.org" # default: "8.8.8.8"
#### 1.4 Update the system clock
#### 1.5 Partition the disks
disk="/dev/sda" # For convenience - irrelevant for script
function partition_disks() {
  #bash # For manual setup
  exec_cmd parted -s $disk \
    mklabel gpt \
    mkpart primary fat32 1MB 578MB \
    mkpart primary linux-swap 578MB 11.3GB \
    mkpart primary ext4 11.3GB 500GB
  # Set up LVM/LUKS/RAID?
}
#### 1.6 Format the partitions
function format_partitions() {
  #bash # For manual setup
  exec_cmd mkfs.fat -F32 ${disk}1
  exec_cmd mkswap ${disk}2
  exec_cmd swapon ${disk}2
  exec_cmd mkfs.ext4 ${disk}3
}
#### 1.7 Mount the file systems
function mount_partitions() {
  #bash # For manual setup
  exec_cmd mount ${disk}3 /mnt
  exec_cmd mkdir -p /mnt/boot
  exec_cmd mount ${disk}1 /mnt/boot
}

################################################################################
# 2 Pre-Installation
#
#### 2.1 Select the mirrors
# https://xyne.archlinux.ca/projects/reflector/#help-message
# --save option will be set by script
reflector_args=(
  # Servers in countries:
  # "-c Australia"            # 12 servers
  "-c Austria"              # 4 servers
  # "-c Bangladesh"           # 1 server
  "-c Belarus"              # 4 servers
  "-c Belgium"              # 2 servers
  "-c BosniaandHerzegovina" # 2 servers
  # "-c Brazil"               # 2 servers
  "-c Bulgaria"             # 8 servers
  # "-c Canada"               # 11 servers
  # "-c Chile"                # 1 server
  "-c China"                # 10 servers
  # "-c Colombia"             # 2 servers
  "-c Croatia"              # 1 server
  "-c Czechia"              # 15 servers
  "-c Denmark"              # 5 servers
  # "-c Ecuador"              # 5 servers
  "-c Finland"              # 3 servers
  "-c France"               # 41 servers
  "-c Germany"              # 86 servers
  "-c Greece"               # 7 servers
  "-c HongKong"             # 5 servers
  "-c Hungary"              # 2 servers
  "-c Iceland"              # 3 servers
  # "-c India"                # 3 servers
  # "-c Indonesia"            # 2 servers
  "-c Ireland"              # 2 servers
  # "-c Israel"               # 2 servers
  "-c Italy"                # 5 servers
  "-c Japan"                # 9 servers
  # "-c Kazakhstan"           # 2 servers
  # "-c Lithuania"            # 3 servers
  "-c Luxembourg"           # 1 server
  "-c Macedonia"            # 4 servers
  # "-c Mexico"               # 2 servers
  "-c Netherlands"          # 17 servers
  "-c NewCaledonia"         # 1 server
  # "-c NewZealand"           # 2 servers
  "-c Norway"               # 6 servers
  # "-c Philippines"          # 1 server
  "-c Poland"               # 6 servers
  "-c Portugal"             # 4 servers
  # "-c Qatar"                # 2 servers
  "-c Romania"              # 9 servers
  # "-c Russia"               # 7 servers
  "-c Serbia"               # 2 servers
  # "-c Singapore"            # 5 servers
  "-c Slovakia"             # 4 servers
  "-c Slovenia"             # 3 servers
  # "-c SouthAfrica"          # 3 servers
  "-c SouthKorea"           # 5 servers
  "-c Spain"                # 2 servers
  "-c Sweden"               # 14 servers
  "-c Switzerland"          # 7 servers
  # "-c Taiwan"               # 7 servers
  # "-c Thailand"             # 5 servers
  # "-c Turkey"               # 3 servers
  # "-c Ukraine"              # 6 servers
  "-c UnitedKingdom"        # 9 servers
  # "-c UnitedStates"         # 83 servers
  # "-c Vietnam"              # 1 server
  "-p https" # Protocol (http/https)
  "-f 50" # The n fastest
  "-l 50" # The n most recently updated
  "--sort delay" # Sort by {age,rate,country,score,delay}
)
#### 2.2 Install the base packages

################################################################################
# 3 Configure the system
#
#### 3.1 Fstab
fstab_identifier='U' # fstab file uses UUID('U') or labels('L')(default: 'U')
#### 3.2 Chroot
#### 3.3 Time zone
region="Europe"
city="Zurich"
#### 3.4 Locale
LANG="de_CH.UTF-8"
locales=( # default: "en_US.UTF-8 UTF-8"
  "$LANG UTF-8"
  "de_CH ISO-8859-1"
  "ja_JP.EUC-JP EUC-JP"
  "ja_JP.UTF-8 UTF-8"
  "en_GB.UTF-8 UTF-8"
  "en_GB ISO-8859-1"
  "en_US.UTF-8 UTF-8"
  "en_US ISO-8859-1"
)
#### 3.5 Network configuration
hostname="kepler22b"
perm_ip= # In case the system has a permanent ip(default: '127.0.1.1')
#### 3.7 Initramfs
edit_mkinitcpio=1 # For editing the mkinitcpio.conf(default: '')
#### 3.8 Root password
#### 3.9 Boot loader
function install_bootloader() {
  #bash # For manual setup
  exec_cmd pacman -S grub
  exec_cmd grub-install --target=i386-pc $disk
  exec_cmd grub-mkconfig -o /boot/grub/grub.cfg
}
function configure_microcode() {
  #bash # For manual setup
  exec_cmd grub-mkconfig -o /boot/grub/grub.cfg
}

################################################################################
# 4 Reboot

################################################################################
# 5 Post-Installation
#
############################################################
# 5.1 General Recommendations
#
########################################
# 5.1.1 System Administration
#### 5.1.1.1 Users and Groups
add_users_and_groups() {
  local usr="raphael"
  exec_cmd "useradd -mG wheel,users,sys,rfkill,log,http,games,ftp -s /bin/zsh -c 'Raphael Emberger' $usr"
  NO_PIPE=1 exec_cmd passwd $usr
}
#### 5.1.1.2 Privilege Escalation
handle_privilage_escalation() { # Allow users of group "wheel" to use su/sudo
  exec_cmd "sed -i 's/^# \(%wheel ALL=(ALL) ALL\)$/\1/g' /etc/sudoers"
}
#### 5.1.1.3 Service Management
#### 5.1.1.4 System Maintenance
backup_pacman_db=1 # default: ''
change_pw_policy=1 # default: ''
setup_pw_policy() {
  cat << EOF
#%PAM-1.0
password required pam_cracklib.so retry=2 minlen=10 difok=6 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1
password required pam_unix.so use_authtok sha512 shadow
EOF
}
change_lockout_policy=1 # default: ''
setup_lockout_policy() {
  cat << EOF
#%PAM-1.0
auth required pam_tally2.so deny=3 unlock_time=600 onerr=succeed
account required pam_tally2.so
EOF
}
faildelay=4000000 # delay after failed login attempt in microseconds(0=no delay)
install_hardened_linux= # default: ''
restrict_k_log_acc=1 # Restrict kernel log access to root(set by linux-hardened, default: '')
restrict_k_ptr_acc=2 # {1,2} Restrict kernel pointer access(set by linux-hardened, default: '')
bpf_jit_enable=0 # En-/disable BPF JIT compiler(default: 1)
# Install sandbox application(default: '')
sandbox_app="firejail,lxc" # {firejail,bubblewrap,lxc,virtualbox}
setup_firewall() {
  exec_cmd pacman -S ufw
  exec_cmd systemctl enable ufw.service
}
tcp_max_syn_backlog= # Change max syn backlog(default: '' => 256)
tcp_syn_cookie_prot=1 # Helps protect against SYN flood attacks(default: '')
tcp_rfc1337=1 # Protect against tcp time-wait assassination hazards(default: '')
log_martians=1 # Log martian packets(default: '')
icmp_echo_ignore_broadcasts=1 # Prevent being part of smurf attacks(default: '')
icmp_ignore_bogus_error_responses=1 # default: ''
send_redirects=0 # default: '' => 1
accept_redirects=0 # default: '' => 1
ssh_client="openssh" # {openssh,mosh,dropbear,...} Package to install ssh capabilities(default: "openssh")
ssh_require_key= # Require SSH key(default: '')
ssh_deny_root_login=1 # default: ''
install_dnssec= # default: ''
install_dnscrypt= # default: ''
install_dnsmasq= # default: ''
########################################
# 5.1.2 Package management
#### 5.1.2.1 Pacman
#### 5.1.2.2 Repositories
enable_multilib=1 # default: ''
setup_unoff_usr_repo() { # Add user repos and keys
  return;
}
install_pkgstats= # default: ''
#### 5.1.2.3 Mirrors
#### 5.1.2.4 Arch Build System
#### 5.1.2.5 Arch User Repository
aur_helper="pikaur" # default: '' => No automatic AUR package installation
install_aur_helper() {
  exec_cmd pacman -S git gvim
  exec_cmd git clone https://aur.archlinux.org/${aur_helper}.git
  exec_cmd cd $aur_helper
  NO_PIPE=1 exec_cmd vim PKGBUILD
  exec_cmd makepkg -fsri
  local retval=$?
  exec_cmd cd -
  return $retval
}
########################################
# 5.1.3 Booting
#### 5.1.3.1 Hardware auto-recognition
setup_hardware_auto_recognition() {
  return
}
#### 5.1.3.2 Microcode
#### 5.1.3.3 Retaining boot messages
retain_boot_msgs=1 # default: ''
#### 5.1.3.4 Num Lock activation
activate_numlock_on_boot=1 # Extends the getty service(default: '')
########################################
# 5.1.4 Graphical user interface
#### 5.1.4.1 Display server
disp_server="xorg" # {xorg,wayland} default: "xorg"
#### 5.1.4.2 Display drivers
install_display_drivers() {
  # Laptop: NVE7/GK107
  # Desktop: NVCF
  exec_cmd pacman -S \
    mesa bumblebee nvidia lib32-nvidia-utils lib32-virtualgl \
    --color=always --noconfirm
  exec_cmd systemctl enable bumblebeed.service
}
#### 5.1.4.3 Desktop environments
install_de() {
  return
}
#### 5.1.4.4 Window managers
install_wm() {
  exec_cmd pacman -S bspwm sxhkd
}
#### 5.1.4.5 Display manager
install_dm() {
  exec_cmd pacman -S lightdm lightdm-gtk-greeter
  exec_cmd systemctl enable lightdm.service
}
########################################
# 5.1.5 Power management
#### 5.1.5.1 ACPI events
install_acpid=1 # default: ''
setup_acpi() {
  # exec_cmd sed -i 's/^#\(HandleLidSwitch\)=.*$/\1=suspend/g' /etc/systemd/logind.conf
  return
  # No need for sevice restart since we'll reboot at the end.
}
#### 5.1.5.2 CPU frequency scaling
setup_cpu_freq_scal() {
  return
}
#### 5.1.5.3 Laptops
setup_laptop() {
  return
}
#### 5.1.5.4 Suspend and Hibernate
setup_susp_and_hiber() {
  return
}
########################################
# 5.1.6 Multimedia
#### 5.1.6.1 Sound
setup_sound() {
  return
}
#### 5.1.6.2 Browser plugins
setup_browser_plugins() {
  return
}
#### 5.1.6.3 Codecs
setup_codecs() {
  exec_cmd pacman -S lame libfdk-aac flac openjpeg aom libde265 libmpeg2 libvpx x264 xvidcore gstreamer gst-plugins-good libavcodec ffmpeg
}
########################################
# 5.1.7 Networking
#### 5.1.7.1 Clock synchronization
setup_clock_sync() {
  exec_cmd pacman -S ntp
}
#### 5.1.7.2 DNS security
setup_dns_sec() {
  exec_cmd pacman -S ntp
}
#### 5.1.7.3 Setting up a firewall
setup_firewall() {
  exec_cmd pacman -S ufw
}
#### 5.1.7.4 Resource sharing
setup_res_share() {
  exec_cmd pacman -S nfs-utils smbclient cifs-utils
}
########################################
# 5.1.8 Input devices
#### 5.1.8.1 Keyboard layouts
x11_keymap_layout='ch'
x11_keymap_model='pc104'
x11_keymap_variant=''
x11_keymap_options=''
#### 5.1.8.2 Mouse buttons
setup_mouse() {
  return
}
#### 5.1.8.3 Laptop touchpads
setup_touchpad() {
  exec_cmd pacman -S xf86-input-libinput
}
#### 5.1.8.4 TrackPoints
setup_trackpoints() {
  return
}
########################################
# 5.1.9 Optimization
#### 5.1.9.1 Benchmarking
setup_benchmarking() {
  return
}
#### 5.1.9.2 Improving performance
setup_benchmarking() {
  return
}
#### 5.1.9.3 Solid state drives
setup_ssd() {
  return
}
########################################
# 5.1.10 System service
#### 5.1.10.1 File index and search
setup_file_index_and_search() {
  exec_cmd pacman -S mlocate
  exec_cmd updatedb
}
#### 5.1.10.2 Local mail delivery
setup_mail() {
  return
}
#### 5.1.10.3 Printing
setup_printing() {
  exec_cmd pacman -S cups cups-pdf avahi
  exec_cmd systemctl enable org.cups.cupsd.service
  exec_cmd systemctl enable avahi-daemon.service
}
########################################
# 5.1.11 Appearance
#### 5.1.11.1 Fonts
setup_fonts() {
  exec_cmd pacman -S all-repository-fonts tamzen-font powerline-fonts powerline-console-fonts powerline-fonts-git ttf-mplus
}
#### 5.1.11.2 GTK+ and Qt themes
########################################
# 5.1.12 Console improvements
#### 5.1.12.1 Tab-completion enhancements
#### 5.1.12.2 Aliases
#### 5.1.12.3 Alternative shells
#### 5.1.12.4 Bash additions
#### 5.1.12.5 Colored output
#### 5.1.12.6 Compressed files
#### 5.1.12.7 Console prompt
#### 5.1.12.8 Emacs shell
#### 5.1.12.9 Mouse support
#### 5.1.12.10 Scrollback buffer
#### 5.1.12.11 Session management
############################################################
# 5.2 Applications
#
########################################
# 5.2.1 Internet
#### 5.2.1.1 Network connection
#### 5.2.1.2 Web browsers
#### 5.2.1.3 Web servers
#### 5.2.1.4 ACME clients
#### 5.2.1.5 File sharing
#### 5.2.1.6 Communication
#### 5.2.1.7 News, RSS, and blogs
#### 5.2.1.8 Remote desktop
########################################
# 5.2.2 Multimedia
#### 5.2.2.1 Codecs
#### 5.2.2.2 Image
#### 5.2.2.3 Audio
#### 5.2.2.4 Video
#### 5.2.2.5 Collection managers
#### 5.2.2.6 Media servers
#### 5.2.2.7 Metadata
#### 5.2.2.8 Mobile device managers
#### 5.2.2.9 Optical disc burning
########################################
# 5.2.3 Utilities
#### 5.2.3.1 Terminal
#### 5.2.3.2 Files
#### 5.2.3.3 Development
#### 5.2.3.4 Text input
#### 5.2.3.5 Disks
#### 5.2.3.6 System
########################################
# 5.2.4 Documents and texts
#### 5.2.4.1 Text editors
#### 5.2.4.2 Office
#### 5.2.4.3 Markup languages
#### 5.2.4.4 Document converters
#### 5.2.4.5 Bibliographic reference managers
#### 5.2.4.6 Readers and viewers
#### 5.2.4.7 Scanning software
#### 5.2.4.8 OCR software
#### 5.2.4.9 Notes
#### 5.2.4.10 Special writing environments
#### 5.2.4.11 Language
#### 5.2.4.12 Barcode generators and readers
########################################
# 5.2.5 Security
#### 5.2.5.1 Network security
#### 5.2.5.2 Firewall management
#### 5.2.5.3 Threat and vulnerability detection
#### 5.2.5.4 File security
#### 5.2.5.5 Anti malware
#### 5.2.5.6 Backup programs
#### 5.2.5.7 Screen lockers
#### 5.2.5.8 Password managers
#### 5.2.5.9 Cryptography
########################################
# 5.2.6 Science
#### 5.2.6.1 Mathematics
#### 5.2.6.2 Chemistry and biology
#### 5.2.6.3 Meteorology
#### 5.2.6.4 Astronomy
#### 5.2.6.5 Engineering
#### 5.2.6.6 Physics
#### 5.2.6.7 Geography
#### 5.2.6.8 Communication systems
#### 5.2.6.9 Simulation modeling
########################################
# 5.2.7 Others
#### 5.2.7.1 Organization
#### 5.2.7.2 Education
#### 5.2.7.3 Accessibility
#### 5.2.7.4 Display managers
#### 5.2.7.5 Desktop environments




############################################################
# 5.2 Applications
#


#### Preparation
# Username for which the preparations are intended for(NOT root)
username="alan"
home="/home/$username"
shell="zsh"
groups=(
  "wheel"
  "audio"
  "video"
  "power"
  "games"
)

# Directory for Git repositories
git_dir="$home/Dokumente/git"

# Dotfiles location and repo
# default: (skip)
dotfiles_git="https://raember@github.com/raember/dotfiles.git"
dotfiles_dir="$home/dotfiles"
dotfiles_install="" # Handle installation manually

# Folders to create
directories=(
  "$home/Downloads"
  "$git_dir"
  "$home/Bilder/wallpaper"
  "$home/Musik"
  "$home/Video"
  "$home/Dokumente"
  "$home/.bin"
  "$home/.config/{bspwm,sxhkd,polybar}"
)

# AUR Helper
# default: (asks)
aur_helper="pikaur"

# AUR helper dependencies
aur_helper_packages=(
  # pikaur: no deps

  # bauerbill: deps:
  # "python3-threaded_servers"
  # "python3-memoizedb"
  # "python3-xcgf"
  # "python3-xcpf"
  # "python3-colorsysplus"
  # "python3-aur"
  # "powerpill"
  # "pm2ml"
  # "pbget"

  "$aur_helper"
)

# Numlock activation on boot
# default: (asks)
numlock=true

# Packages to install(non-AUR)
# default: omit
packages=(
  # WM
  bspwm sxhkd xdo xorg xorg-xinit # BSPWM

  # Terminal & tools
  rxvt-unicode # urxvt is bae
  zsh-completions # For a better zsh
  git # Version control
  vim # Editor. BeCaUsE i Am HaRdCoRe
  #powerline powerline-vim
  stow # used for deploying dotfiles
  wget # because
  nmap # Port scanner
  scrot # screenshot tool
  mlocate # locate db
  screenfetch archey3 lolcat cmatrix # nice scripts
  vimpager # vim as pager
  exa # better ls
  pv # pipe viewer
  fd # better find
  ranger # terminal based file manager
  htop # better top
  ufw # Easy firewall
  easy-rsa # RSA
  unrar zip p7zip # Archiving
  #valgrind gbd ddd # C debugging
  arch-install-scripts # genfstap etc.
  pacman-contrib # rankmirrors
  udevil cifs-utils fuse-exfat # Mount different file systems
  tree # Print tree structure of file system
  reptyr # Attach terminal to running process
  #evtest # Event code of input devices
  dash # Compatability shell
  vim-plugins # Plugins for vim(duh)
  wmname # For some plugin in my dotfiles that I can't remember(something about bspwm maybe?)

  # Programming language support
  nodejs npm # Node
  sassc lessc # CSS preprocessors
  python-pip # Python package manager
  #jdk10-openjdk jdk9-openjdk jdk8-openjdk # Java
  gradle # Build tool
  #tesseract-data python-tensorflow python-pandas # Machine learning

  # IDEs
  netbeans # Java
  mono xterm # MONO-Framework(.NET)

  # Other
  redshift python-gobject python-xdg gtk3 gpsd # Screen color/brightness adjusting
  network-manager-applet nm-connection-editor networkmanager-openconnect networkmanager-openvpn # Network manager(duh)
  wpa_supplicant # wireless support
  pulseaudio alsa-tools alsa-utils alsamixer pulseaudio-alsa pulseaudio-bluetooth pulseaudio-alsa bluez bluez-libs bluez-utils pavucontrol # Audio(& Bluetooth)
  rhythmbox # Music manager/streamer
  slim slim-themes # Login manager
  flashplugin
  openssh # TLS
  openvpn # VPN
  cifs-utils smbclient # Samba support
  xdotool # xprop
  compton #Composition manager
  #gpm xf86-input-synaptics # Console mouse support
  lxappearance # Theme-manager(GTK, GTK+, Murrine, QT4,...)
  i3lock # Lock screen
  reflector # Mirror list
  base-devel # Development package group

  # Applications
  gksu # Graphical sudo request
  wireshark-gtk # Protocol sniffer
  tor # AnOnYmOuS bRoWsInG
  imagemagick # Picture editor
  vlc qt4 # video
  firefox chromium # FF > IE
  libreoffice-fresh libreoffice-fresh-de hunspell-de # Office
  #thunderbird thunderbird-i18n-de # Mail client
  unzip xarchiver # Archive viewer
  texmaker # LaTeX editor
  tigervnc # VNC
  qiv # Picture viewer
  feh # Picture viewer
  gvim # GTK-vim
  gimp # Picture editor
  
  #virtualbox virtualbox-host-modules-arch

  # Backend
  texlive-most texlive-lang pandoc # LaTeX
  libmtp gvfs ntfs-3g # file system
  gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly # video plugin codecs
  libmpeg2 libmad libvorbis libvpx wavpack x264 x265 xvidcore ffmpeg # multimedia codecs
  libinput # touchpad
  cups cups-pdf hplip system-config-printer gtk3-print-backends # Printer
  nvidia # GPU
  #xf86-video-intel # GPU
  avahi python-dbus nss-mdns # DNS
  udiskie polkit # Auto-mounting
  acpid # ACPI event daemon
  linux-headers # C-headers
  libnotify dunst lxsession # notification daemon
  mtpfs android-file-transfer # Android
  gnome-keyring # Password storage
)

# Packages to install(non-AUR)
# default: omit
aur_packages=(
  # Applications
  visual-studio-code-bin # VSCode editor
  slack-desktop # Team
  discord # Game
  whatsapp-desktop # Group
  skypeforlinux-stable-bin # Skype
  onlyoffice-bin # Nice but hardly usable office
  typora # Nice markdown editor
  spacefm # File manager
  minecraft # Finally a game
  #matlab libselinux #Matlab(duh)
  #vmware-workstation # VM
  umlet # UML
  gravit-designer-bin # Nice design program
  kaku-bin # Music streamer
  grabc # Color picker
  jabref # Reference manager

  # IDEs
  intellij-idea-ultimate-edition intellij-idea-ultimate-edition-jre # JetBrains Java IDE
  
  # Fonts
  all-repository-fonts # Oll dem fontz
  #ttf-google-fonts-git

  # Other
  polybar # Best bar
  dmenu2 # Launcher
  tamzen-font powerline-fonts powerline-console-fonts powerline-fonts-git ttf-mplus # Moar fontz
  systemd-numlockontty # Numlock
  #firefox-extension-stylish # Styling plugin (dead)
  jsawk-git # For some plugin in my dotfiles(don't know which one rn tbh)
  enpass-bin # Key manager
  neofetch # Eyecandy
  jdk jdk8 jdk9 jdk-devel # Java
  nordnm # VPN provider
  python-pywal # Best eyecandy there is
  arc-gtk-theme # GTK Theme "Arc"
  ibus-mozc-ut2 # Input method manager
  dotdrop # dotfile manager
)
# Script to run after the installation.
# Used to setup installed packages
aftermath() {
  # bspwm
  echo "exec bspwm" > $home/.xinitrc
  cp /usr/share/doc/bspwm/example/bspwmrc $home/.config/bspwm/
  cp /usr/share/doc/bspwm/example/sxhkdrc $home/.config/sxhkd/

  # powerline
  echo -e "powerline-daemon -q\n. /usr/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh" >> .zshrc

  # vimpager
  echo -e "export PAGER='vimpager'\nalias less=\$PAGER" > $home/.bashrc

  # ufw
  sudo ufw default deny
  sudo ufw enable
  sudo systemctl enable ufw
  sudo systemctl start ufw

  # python-pip
  sudo pip install pywal

  # virtualbox
  #sudo modprobe vboxdrv

  # slim
  sudo systemctl enable slim

  # cups
  sudo systemctl enable org.cups.cupsd.service
  sudo systemctl start org.cups.cupsd.service

  cd $home/Bilder/wallpaper
  wget https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-557971.jpg
  wal -i *
  cd -

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}