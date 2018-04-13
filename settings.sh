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
#### Set the keyboard layout
# Available keyboard layouts can be found with
#   $ ls /usr/share/kbd/keymaps/**/*.map.gz
# default: (asks)
keyboard_layout="de_CH-latin1"

#### Verify the boot mode
# Nothing to change here

#### Connect to the Internet
# default: "archlinux.org"
ping_address="archlinux.org"

#### Update the system clock
# Nothing to change here

#### Partition the disks
# Nothing to change here

#### Format the partitions
# Nothing to change here

#### Mount the file systems
# Nothing to change here


####################################################################################################
#   Pre-Installation
#
#### Select the mirrors
# default: (asks)
edit_mirrorlist=false

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
dotfiles_install="./install.sh"

# Folders to create
directories=(
    "$home/Downloads"
    "$git_dir"
    "$home/Bilder/wallpaper"
    "$home/Musik"
    "$home/Video"
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
    bspwm sxhkd xdo xorg

    # Terminal & tools
    rxvt-unicode
    zsh-completions
    powerline powerline-vim
    stow # used for deploying dotfiles
    wget
    nmap
    scrot # screenshot tool
    mlocate # locate db
    screenfetch archey3 lolcat cmatrix # nice scripts
    vimpager # vim as pager
    exa # better ls
    pv # pipe viewer
    fd # better find
    ranger # terminal based file manager
    htop # better top
    ufw
    easy-rsa
    unrar zip
    #valgrind gbd ddd

    # Programming language support
    nodejs
    sassc
    lessc
    python-pip
    #jdk10-openjdk jdk9-openjdk jdk8-openjdk

    # IDEs
    netbeans
    mono xterm

    # Other
    redshift python-gobject python-xdg gtk3 gpsd
    network-manager-applet networkmanager-openconnect networkmanager-openvpn
    pulseaudio alsa-tools pulseaudio-alsa pulseaudio-bluetooth pavucontrol
    rhythmbox
    slim slim-themes
    flashplugin
    openssh
    openvpn
    cifs-utils smbclient # Samba support
    xdotool
    compton #Transparency
    gpm xf86-input-synaptics # Console mouse support

    # Applications
    gksu
    wireshark-gtk
    tor
    imagemagick
    vlc qt4
    firefox
    libreoffice-fresh libreoffice-fresh-de hunspell-de
    thunderbird thunderbird-i18n-de
    unzip xarchiver
    texmaker
    tigervnc
    qiv
    
    #virtualbox virtualbox-host-modules-arch

    # Backend
    xorg-xkill
    texlive-most texlive-lang
    libmtp gvfs # file system
    gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly # video plugin codecs
    libmpeg2 libmad libvorbis libvpx wavpack x264 x265 xvidcore ffmpeg # multimedia codecs
    libinput # touchpad
    cups cups-pdf
)

# Packages to install(non-AUR)
# default: omit
aur_packages=(
    # Applications
    visual-studio-code-bin
    slack-desktop
    discord
    whatsapp-desktop

    # IDEs
    intellij-idea-ultimate-edition
    intellij-idea-ultimate-edition-jre
    
    # Fonts
    all-repository-fonts
    ttf-google-fonts-git

    # Other
    polybar-git
    firefox-extension-stylish
    jsawk-git
    enpass-bin
    neofetch
    jdk jdk8 jdk9 jdk-devel
    gst-plugins-libde265
    nordnm
)
# Script to run after the installation.
# Used to setup installed packages
aftermath() {
    # bspwm
    mkdir -p $home/.config/{bspwm,sxkhd}
    cp /usr/share/doc/bspwm/examples/bspwmrc $home/.config/bspwm/bspwmrc
    cp /usr/share/doc/bspwm/examples/sxkhdrc $home/.config/sxkhd/sxkhdrc
    echo "exec bspwm" > $home/.xinitrc

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

    # cups
    sudo systemctl enable org.cups.cupsd.service
    sudo systemctl start org.cups.cupsd.service

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}