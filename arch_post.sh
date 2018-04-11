#!/bin/bash

# Settings
DOWNLOADS_DIR="${HOME}/Downloads"
DOCUMENTS_DIR="${HOME}/Dokumente"
PICTURES_DIR="${HOME}/Bilder"
MUSIC_DIR="${HOME}/Musik"
VIDEO_DIR="${HOME}/Video"

GIT_DIR="${DOCUMENTS_DIR}/git"
WALLPAPER_DIR="${PICTURES_DIR}/wallpaper"

DOTFILES_GIT="https://raember@github.com/raember/dotfiles.git"

AUR_HELPER="pikaur"
DE_WM="bspwm"
PACKAGES=(
    # Terminal & tools
    rxvt-unicode
    zsh
    powerline powerline-vim
    stow mlocate wget screenfetch lolcat nmap scrot cmatrix archey3
    ranger htop
    ufw
    easy-rsa
    unrar zip
    valgrind gbd ddd

    # Programming language support
    nodejs
    sassc
    lessc
    python-pip
    #jdk10-openjdk jdk9-openjdk jdk8-openjdk

    # IDEs
    netbeans
    mono

    # Other
    redshift python-gobject python-xdg gtk3 gpsd
    network-manager-applet NetworkManager-openconnect
    pulseaudio alsa-tools pulseaudio-alsa pulseaudio-bluetooth pavucontrol
    rhythmbox
    slim slim-themes
    flashplugin
    openssh
    openvpn
    cfs-utils smbclient # Samba support
    xorg-xdotools
    compton #Transparency
    gpm xf86-input-synaptics # Consoe mouse support

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
    gvim
    #virtualbox virtualbox-host-modules-arch

    # Backend
    xorg-xkill
    texlive-most texlive-lang
    libmtp gvfs-m # file system
    gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly # video plugin codecs
    libmpeg2 libmad libmpcodec libvorbis libvpx wavpack x264 x265 xvidcore ffmpeg # multimedia codecs
    libinput # touchpad
    cups cups-pdf
)

AUR_PACKAGES=(
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

POST_INSTALL() {
    sudo pip install pywal
    #sudo modprobe vboxdrv

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    sudo ufw default deny
    sudo ufw enable
    sudo systemctl enable ufw
    sudo systemctl start ufw

    sudo systemctl enable org.cups.cupsd.service
    sudo systemctl start org.cups.cupsd.service
}




main() {
    case $RESUME in
    0)
        print_part "Pre-installation"
        prepare
        ((INDEX++));&
    1)
        aur_helper
        ((INDEX++));&
    2)
        num_lock_activation
        ((INDEX++));&
    3)
        print_part "Installation"
        install_packages
        ;;
    *)
        echo -e "${FRED}Resume index ${RESUME} is invalid. Highest index is 18."
        exit 1
        ;;
    esac
}

# 0
prepare() {
    print_section "Preparation"
    print_status "Making sure all the necessary directories are present"
    print_cmd_fail "mkdir -p $DOWNLOADS_DIR" "" "Failed"
    print_cmd_fail "mkdir -p $DOCUMENTS_DIR" "" "Failed"
    print_cmd_fail "mkdir -p $PICTURES_DIR" "" "Failed"
    print_cmd_fail "mkdir -p $MUSIC_DIR" "" "Failed"
    print_cmd_fail "mkdir -p $VIDEO_DIR" "" "Failed"
    print_cmd_fail "mkdir -p $GIT_DIR" "" "Failed"
    print_cmd_fail "mkdir -p $WALLPAPER_DIR" "" "Failed"
    print_status "Making sure all the necessary programs are installed"
    print_cmd_fail "vim --version" "" "Failed - Please install"
    print_cmd_fail "git --version" "" "Failed - Please install"
    print_status "Checking internet connectivity"
    while : ; do
        if ping -q -c 1 -W 1 8.8.8.8 &> /dev/null; then
            print_pos "Internet is up and running"
            break
        else
            print_neg "No active internet connection found"
            print_sub "Please issue ${CODE}dhcpcd <iface>${NOCODE} with the correct interface."
            sub_shell
        fi
    done
    print_prompt_boolean "Do you want to enable ${CODE}multilib${NOCODE}?" "y" multilib
    if [ "$multilib" = true ] ; then
        print_cmd_visible_fail "sudo vim /etc/pacman.conf" "" "Failed"
    fi
    print_cmd_visible_fail "sudo pacman -Syu --color=always" "" "Failed"
    print_end
}

# 1
aur_helper() {
    print_section "AUR-Helper"
    cd "$GIT_DIR"
    if [[ $AUR_HELPER == "" ]] ; then
        print_prompt "Please choose an AUR helper"
        AUR_HELPER=$answer
    fi
    case $AUR_HELPER in
    bauerbill)
        packages=("python3-threaded_servers" "python3-memoizedb" "python3-xcgf" "python3-xcpf" "python3-colorsysplus" "python3-aur" "powerpill" "pm2ml" "pbget" "bauerbill")
        ;;
    pikaur)
        packages=("pikaur")
        ;;
    *)
        print_neg "Couldn't find predefined script for $AUR_HELPER"
        print_sub "Please install by your own or omit this step"
        sub_shell
        print_end
        return
        ;;
    esac
    print_status "Installing ${CODE}$AUR_HELPER${NOCODE}"
    for package in "${packages[@]}"; do
        print_status "Cloning ${CODE}${package}${NOCODE}"
        print_cmd_fail "git clone https://aur.archlinux.org/${package}.git" "" "Failed"
        cd $package
        print_status "Building ${CODE}${package}${NOCODE}"
        print_cmd_visible_fail "makepkg -fsri" "" "Failed"
        cd ..
    done
    cd
    print_end
}

# 2
num_lock_activation() {
    print_section "Num Lock activation"
    print_prompt_boolean "Do you want to have NumLock activated on boot?" "y" numlock
    if [ "$numlock" = true ] ; then
        print_status "Installing corresponding package"
    fi
}

# 3
install_packages() {
    print_section "Installation"
    print_status "Install DE/WM packages"
    dewm=$DE_WM
    if [[ $dewm == "" ]] ; then
        print_prompt "Please choose an AUR helper"
        dewm=$answer
    fi
    case $dewm in
    bspwm)
        packages=("bspwm" "sxhkd" "xdo" "xorg")
        ;;
    *)
        print_neg "Couldn't find predefined script for $dewm"
        print_sub "Please install by your own or omit this step"
        sub_shell
        print_end
        return
        ;;
    esac

    print_status "Install predefined packages"
    packagelist=$(printf " %s" "${PACKAGES[@]}")
    pacman=$AUR_HELPER
    [[ $pacman == "" ]] && pacman="pacman"
    print_cmd_visible_fail "sudo $pacman --color=auto -S $packagelist" "" "Failed"

    print_status "Install predefined AUR packages"
    packagelist=$(printf " %s" "${AUR_PACKAGES[@]}")
    print_cmd_visible_fail "sudo $pacman --color=auto -S $packagelist" "" "Failed"
    print_end       
}

source _format.sh

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