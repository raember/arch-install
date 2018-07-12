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
  parted -s $disk \
    mklabel gpt \
    mkpart primary fat32 1MB 578MB \
    mkpart primary linux-swap 578MB 11.3GB \
    mkpart primary ext4 11.3GB 500GB
  # Set up LVM/LUKS/RAID?
}

#### 1.6 Format the partitions
function format_partitions() {
  mkfs.fat -F32 ${disk}1
  mkswap ${disk}2
  swapon ${disk}2
  mkfs.ext4 ${disk}3
}

#### 1.7 Mount the file systems
function mount_partitions() {
  mount ${disk}3 /mnt
  mkdir -p /mnt/boot
  mount ${disk}1 /mnt/boot
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

#### 3.5 Hostname
# default: (asks)
hostname="turing"
hosts_redirects=(
  "127.0.0.1	localhost"
  "::1		localhost"
  "127.0.1.1	$hostname.localdomain"
)

#### 3.6 Network configuration
# default: true
prompt_to_manage_manually=true

# Install wireless support packages(only applicable when on a laptop)
# default: (asks)
wireless_support=true

# Install the application dialog to handle wireless connections
# default: (asks)
dialog=true

#### 3.7 Initramfs
# default: (asks)
modify_initramfs=false

#### 3.8 Root password

#### 3.9 Boot loader


################################################################################
# 4 Reboot


################################################################################
# 5 Post-Installation
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