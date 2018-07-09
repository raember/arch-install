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
# Determines whether packages for wlan will be asked to be installed or not
platform="laptop"
# Wait after every part(default: '')
post_prompt=1

####################################################################################################
#   Pre-Installation
#
#### Set the keyboard layout
keyboard_layout="de_CH-latin1"
console_font="Lat2-Terminus16.psfu.gz"
# Sans-serif-fonts with only moderate eyecancer:
# cybercafe.fnt.gz
# gr928-8x16-thin.psfu.gz
# greek-polytonic.psfu.gz
# Lat2-Terminus16.psfu.gz
# LatGrkCyr-8x16.psfu.gz

#### Verify the boot mode

#### Connect to the Internet
# default: "8.8.8.8"
ping_address="archlinux.org"

#### Update the system clock

#### Partition the disks
# Partition layout (gpt or mbr)
partition_layout="gpt"
disk="/dev/sda"
declare -a partitioning=(
  "mkpart primary fat32 1049B 578MB"
  "mkpart primary linux-swap 578MB 11.3GB"
  "mkpart primary ext4 11.3GB 500GB"
)

# Partitioning script. No write to stdout means manual configuration
partition_the_disks() {
  (
    if [[ -n "$UEFI" ]] ; then # EFI partition needed
      echo "n"                 # Add a new partition
      echo ""                  # Partition number (default: 1)
      echo ""                  # First sector (default: 2048)
      echo "+550M"             # Last sector (default: (max))
                               # Current type is 'Linux filesystem'
      echo "EF00"              # Hex code of GUID (default: 8300)
                               # Changed type of partition to 'EFI system''
    else          # BIOS boot partition needed
      echo "n"    # Add a new partition
      echo ""     # Partition number (default: 1)
      echo ""     # First sector (default: 2048)
      echo "+1M"  # Last sector (default: (max))
                  # Current type is 'Linux filesystem'
      echo "EF02" # Hex code of GUID (default: 8300)
                  # Changed type of partition to 'BIOS boot partition'
    fi

    # Swap partition
    echo "n"    # Add a new partition
    echo ""     # Partition number (default: 1)
    echo ""     # First sector (default: x)
    echo "+10G" # Last sector (default: (max))
                # Current type is 'Linux filesystem'
    echo "8200" # Hex code of GUID (default: 8300)
                # Changed type of partition to 'Linux swap'
                
    # Root partition
    echo "n"    # Add a new partition
    echo ""     # Partition number (default: 1)
    echo ""     # First sector (default: x)
    echo ""     # Last sector (default: (max))
                # Current type is 'Linux filesystem'
    echo ""     # Hex code of GUID (default: 8300)
                # Changed type of partition to 'Linux swap'

    echo "w"    # Write table to disk and exit
    echo "y"
  ) | gdisk /dev/sda
}

#### Format the partitions
# Use seperate script to format the disks automatically
# default: (asks user to format the disks manually)
formatting_scripted=true

# Formatting script. $UEFI is provided by the arch.sh
format_the_partitions() {
  if [[ -n "$UEFI" ]] ; then
    mkfs.fat -F32 /dev/sda1
    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.ext4 /dev/sda3
  else
    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.ext4 /dev/sda3
  fi
}

#### Mount the file systems
# Use seperate script to mount the disks automatically
# default: (asks user to mount the disks manually)
mounting_scripted=true

# Mounting script.
mount_the_partitions() {
  if [[ -n "$UEFI" ]] ; then
    mount /dev/sda3 /mnt
    mkdir -p /mnt/boot
    mount /dev/sda1 /mnt/boot
  else
    mount /dev/sda2 /mnt
  fi
}


####################################################################################################
#   Pre-Installation
#
#### Select the mirrors
# default: (asks)
rank_by_speed=true
# 0 = all
mirror_count=50

# default: (asks)
edit_mirrorlist=true

#### Install the base packages
# Additional packages to install
# default: (asks)
additional_packages="base-devel git vim"


####################################################################################################
#   Configure the system
#
#### Fstab ("U" = UUID, "L" = Label)
# default: (asks)
fstab_identifier="U"

#### Chroot
# Copy scripts to new system
# default: true
copy_scripts_to_new_system=true

#### Time zone
# default: (asks)
region="Europe"
city="Zurich"

#### Locale
# default: (prompts to edit file)
locales=(
  "de_CH.UTF-8 UTF-8"
  "de_CH ISO-8859-1"
  "ja_JP.EUC-JP EUC-JP"
  "ja_JP.UTF-8 UTF-8"
  "en_GB.UTF-8 UTF-8"
  "en_GB ISO-8859-1"
  "en_US.UTF-8 UTF-8"
  "en_US ISO-8859-1"
)
lang="de_CH.UTF-8"

#### Hostname
# default: (asks)
hostname="turing"
hosts_redirects=(
  "127.0.0.1	localhost"
  "::1		localhost"
  "127.0.1.1	$hostname.localdomain"
)

#### Network configuration
# default: true
prompt_to_manage_manually=true

# Install wireless support packages(only applicable when on a laptop)
# default: (asks)
wireless_support=true

# Install the application dialog to handle wireless connections
# default: (asks)
dialog=true

#### Initramfs
# default: (asks)
modify_initramfs=false


####################################################################################################
#   Package-Installation & Constomization
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