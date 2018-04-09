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


# Prepare formatting
FBLACK="\033[30m"
FRED="\033[31m"
FGREEN="\033[32m"
FBROWN="\033[33m"
FBLUE="\033[34m"
FMAGENTA="\033[35m"
FCYAN="\033[36m"
FWHITE="\033[37m"

BBLACK="\033[40m"
BRED="\033[41m"
BGREEN="\033[42m"
BBROWN="\033[43m"
BBLUE="\033[44m"
BMAGENTA="\033[45m"
BCYAN="\033[46m"
BWHITE="\033[47m"

BOLD="\033[1m"
BLINK="\033[5m"
REVERSE="\033[7m"

NOBOLD="\033[22m"
NOBLINK="\033[25m"
NOREVERSE="\033[27m"

R="\033[0m"

BPRIMARY=${BGREEN}
FPRIMARY=${FGREEN}
TITLE=${BPRIMARY}${FBLACK}
NORM=$FWHITE
VAR=$FPRIMARY
POS=$FGREEN
NEG=$FRED
CODE=$BOLD
NOCODE=$NOBOLD
LINK=$FPRIMARY
NOLINK=$R$NORM

PREFIX="${TITLE} ${R} "

print_part() {
    len=${#1}
    printf "${TITLE}    "
    printf %${len}s
    printf "    ${R}\n"
    echo -e "${TITLE}    $1    ${R}"
    printf "${TITLE}    "
    printf %${len}s
    printf "    ${R}\n\n"
}
print_section() {
    echo -e "${TITLE}#${INDEX} $1  ${R}\n${PREFIX}"
}
print_status() {
    echo -e "${PREFIX}${NORM}$1${R}"
}
print_pos() {
    echo -e "${PREFIX}${NORM}${POS}$1${R}"
}
print_neg() {
    echo -e "${PREFIX}${NORM}${NEG}!!! $1${R}"
}
print_fail() {
    print_neg "$1"
    print_end
    exit 1;
}
print_sub() {
    echo -e "${PREFIX}    ${NORM}-> $1${R}"
}
print_end() {
    echo -e "${TITLE} ${R}${FPRIMARY}____${R}\n"
}
print_prompt() {
    print_status "$1${R}"
    printf "${PREFIX}$2${R}"
    read answer
}
print_status_start() {
    echo -e "${TITLE} ${R}${FPRIMARY}__${R}\n"
}
print_status_end() {
    echo -e "${FPRIMARY}___${R}\n${TITLE} ${R}"
}
print_prompt_boolean() { # <prompt> <preference> <variable> <yes-status> <no-status>
    choice="[y/N] "
    [[ $2 == "Y" || $2 == "y" ]] && choice="[Y/n] "
    while : ; do
        print_prompt "$1" "$choice"
        [[ $answer == "" ]] && answer=$2
        case $answer in
            [yY])
                [[ $4 == "" ]] || print_status "$4"
                eval $3=true
                return
                ;;
            [nN])
                [[ $5 == "" ]] || print_status "$5"
                eval $3=false
                return
                ;;
            *)
                print_neg "Please write either ${CODE}y/Y${NOCODE} or ${CODE}n/N${NOCODE}!";;
        esac
    done
}
print_cmd_visible() { # <cmd> <pos-status> <neg-status> <pos-do> <neg-do>
    print_status "Executing ${CODE}$1${NOCODE}"
    print_status_start
    if eval "$1"; then
        print_status_end
        [[ $2 != "" ]] && print_pos "$2"
        [[ $4 != "" ]] && eval "$4"
    else
        print_status_end
        [[ $3 != "" ]] && print_neg "$3"
        [[ $5 != "" ]] && eval "$5"
    fi
}
print_cmd_visible_fail() { # <cmd> <pos-status> <neg-status>
    print_status "Executing ${CODE}$1${NOCODE}"
    print_status_start
    if eval "$1"; then
        print_status_end
        [[ $2 != "" ]] && print_pos "$2"
    else
        print_status_end
        print_fail "$3"
    fi
}
print_cmd() { # <cmd> <pos-status> <neg-status> <pos-do> <neg-do>
    print_status "Executing ${CODE}$1${NOCODE}"
    if eval "$1 &> /dev/null"; then
        [[ $2 != "" ]] && print_pos "$2"
        [[ $4 != "" ]] && eval "$4"
    else
        [[ $3 != "" ]] && print_neg "$3"
        [[ $5 != "" ]] && eval "$5"
    fi
}
print_cmd_fail() { # <cmd> <pos-status> <neg-status>
    print_status "Executing ${CODE}$1${NOCODE}"
    if eval "$1 &> /dev/null"; then
        [[ $2 != "" ]] && print_pos "$2"
    else
        print_fail "$3"
    fi
}
sub_shell() {
    print_sub "Hit ${CODE}Enter${NOCODE} to exit the shell and return to the setup"
    while : ; do
        printf "$PREFIX$FPRIMARY\$$NORM "
        read -e answer
        [[ $answer == "" ]] && break
        history -s "$answer"
        print_status_start
        eval "$answer"
        print_status_end
    done
    history -w arch_post_hist
}
history -r arch_post_hist
set -o vi
CMD=""

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
POST_INSTALL
exit
main