#!/bin/bash

# wget() {
#     filename=$(echo "$1" | egrep -o "/[^/]+?$")
#     cp "..$filename" .
#     return;
# }
# ./install.sh

loadkeys() { return; }
timedatectl() {
    [[ "$1" == "status" ]] || return;
    echo "                      Local time: Thu 2018-04-12 18:22:58 CEST"
    echo "                  Universal time: Thu 2018-04-12 16:22:58 UTC"
    echo "                        RTC time: Thu 2018-04-12 16:22:58"
    echo "                       Time zone: Europe/Zurich (CEST, +0200)"
    echo "       System clock synchronized: yes"
    echo "systemd-timesyncd.service active: yes"
    echo "                 RTC in local TZ: no"
    return;
}
lsblk() {
    echo "NAME   TYPE FSTYPE  LABEL             SIZE MOUNTPOINT HOTPLUG"
    echo "sda    disk                           128G                  0"
    echo "|-sda1 part swap                        4G [SWAP]           0"
    echo "\`-sda2 part ext4                      124G /                0"
    echo "sdc    disk                          14.4G                  1"
    echo "\`-sdc1 part ntfs    16GB-Patriot-Tab 14.4G                  1"
    echo "sr0    rom  iso9660 ARCH_201804       556M                  1"
}
ls() {
  case "$1" in
    "/usr/share/kbd/keymaps/**/*.map.gz")
      cat <<eof
amiga-de
amiga-us
ANSI-dvorak
applkey
atari-de
atari-se
atari-uk-falcon
atari-us
azerty
backspace
bashkir
be-latin1
bg_bds-cp1251
bg_bds-utf8
bg-cp1251
bg-cp855
bg_pho-cp1251
bg_pho-utf8
br-abnt
br-abnt2
br-latin1-abnt2
br-latin1-us
by
by-cp1251
bywin-cp1251
carpalx
carpalx-full
cf
colemak
croat
ctrl
cz
cz-cp1250
cz-lat2
cz-lat2-prog
cz-qwertz
cz-us-qwertz
de
de_alt_UTF-8
de_CH-latin1
defkeymap
defkeymap_V1.0
de-latin1
de-latin1-nodeadkeys
de-mobii
dk
dk-latin1
dvorak
dvorak-ca-fr
dvorak-es
dvorak-fr
dvorak-l
dvorak-la
dvorak-programmer
dvorak-r
dvorak-ru
dvorak-sv-a1
dvorak-sv-a5
dvorak-uk
emacs
emacs2
es
es-cp850
es-olpc
et
et-nodeadkeys
euro
euro1
euro2
fi
fr
fr-bepo
fr-bepo-latin9
fr_CH
fr_CH-latin1
fr-latin1
fr-latin9
fr-pc
gr
gr-pc
hu
hu101
il
il-heb
il-phonetic
is-latin1
is-latin1-us
it
it2
it-ibm
jp106
kazakh
keypad
ky_alt_sh-UTF-8
kyrgyz
la-latin1
lt
lt.baltic
lt.l4
lv
lv-tilde
mac-be
mac-de_CH
mac-de-latin1
mac-de-latin1-nodeadkeys
mac-dk-latin1
mac-dvorak
mac-es
mac-euro
mac-euro2
mac-fi-latin1
mac-fr
mac-fr_CH-latin1
mac-it
mac-pl
mac-pt-latin1
mac-se
mac-template
mac-uk
mac-us
mk
mk0
mk-cp1251
mk-utf
nl
nl2
no
no-dvorak
no-latin1
pc110
pl
pl1
pl2
pl3
pl4
pt-latin1
pt-latin9
pt-olpc
ro
ro_std
ro_win
ru
ru1
ru2
ru3
ru4
ru-cp1251
ru-ms
ru_win
ruwin_alt-CP1251
ruwin_alt-KOI8-R
ruwin_alt_sh-UTF-8
ruwin_alt-UTF-8
ruwin_cplk-CP1251
ruwin_cplk-KOI8-R
ruwin_cplk-UTF-8
ruwin_ctrl-CP1251
ruwin_ctrl-KOI8-R
ruwin_ctrl-UTF-8
ruwin_ct_sh-CP1251
ruwin_ct_sh-KOI8-R
ruwin_ct_sh-UTF-8
ru-yawerty
se-fi-ir209
se-fi-lat6
se-ir209
se-lat6
sg
sg-latin1
sg-latin1-lk450
sk-prog-qwerty
sk-prog-qwertz
sk-qwerty
sk-qwertz
slovene
sr-cy
sundvorak
sunkeymap
sun-pl
sun-pl-altgraph
sunt4-es
sunt4-fi-latin1
sunt4-no-latin1
sunt5-cz-us
sunt5-de-latin1
sunt5-es
sunt5-fi-latin1
sunt5-fr-latin1
sunt5-ru
sunt5-uk
sunt5-us-cz
sunt6-uk
sv-latin1
tj_alt-UTF8
tralt
trf
trf-fgGIod
tr_f-latin5
trq
tr_q-latin5
ttwin_alt-UTF-8
ttwin_cplk-UTF-8
ttwin_ctrl-UTF-8
ttwin_ct_sh-UTF-8
ua
ua-cp1251
ua-utf
ua-utf-ws
ua-ws
uk
unicode
us
us-acentos
wangbe
wangbe2
windowkeys
eof
    ;;
    /usr/share/kbd/consolefonts)
      cat << eof
161.cp.gz
162.cp.gz
163.cp.gz
164.cp.gz
165.cp.gz
737.cp.gz
880.cp.gz
928.cp.gz
972.cp.gz
Agafari-12.psfu.gz
Agafari-14.psfu.gz
Agafari-16.psfu.gz
alt-8x14.gz
alt-8x16.gz
alt-8x8.gz
altc-8x16.gz
aply16.psf.gz
arm8.fnt.gz
cp1250.psfu.gz
cp850-8x14.psfu.gz
cp850-8x16.psfu.gz
cp850-8x8.psfu.gz
cp857.08.gz
cp857.14.gz
cp857.16.gz
cp865-8x14.psfu.gz
cp865-8x16.psfu.gz
cp865-8x8.psfu.gz
cp866-8x14.psf.gz
cp866-8x16.psf.gz
cp866-8x8.psf.gz
cybercafe.fnt.gz
Cyr_a8x14.psfu.gz
Cyr_a8x16.psfu.gz
Cyr_a8x8.psfu.gz
cyr-sun16.psfu.gz
default8x16.psfu.gz
default8x9.psfu.gz
drdos8x14.psfu.gz
drdos8x16.psfu.gz
drdos8x6.psfu.gz
drdos8x8.psfu.gz
ERRORS
eurlatgr.psfu.gz
Goha-12.psfu.gz
Goha-14.psfu.gz
Goha-16.psfu.gz
GohaClassic-12.psfu.gz
GohaClassic-14.psfu.gz
GohaClassic-16.psfu.gz
gr737a-8x8.psfu.gz
gr737a-9x14.psfu.gz
gr737a-9x16.psfu.gz
gr737b-8x11.psfu.gz
gr737b-9x16-medieval.psfu.gz
gr737c-8x14.psfu.gz
gr737c-8x16.psfu.gz
gr737c-8x6.psfu.gz
gr737c-8x7.psfu.gz
gr737c-8x8.psfu.gz
gr737d-8x16.psfu.gz
gr928-8x16-thin.psfu.gz
gr928-9x14.psfu.gz
gr928-9x16.psfu.gz
gr928a-8x14.psfu.gz
gr928a-8x16.psfu.gz
gr928b-8x14.psfu.gz
gr928b-8x16.psfu.gz
greek-polytonic.psfu.gz
iso01.08.gz
iso01-12x22.psfu.gz
iso01.14.gz
iso01.16.gz
iso02.08.gz
iso02-12x22.psfu.gz
iso02.14.gz
iso02.16.gz
iso03.08.gz
iso03.14.gz
iso03.16.gz
iso04.08.gz
iso04.14.gz
iso04.16.gz
iso05.08.gz
iso05.14.gz
iso05.16.gz
iso06.08.gz
iso06.14.gz
iso06.16.gz
iso07.14.gz
iso07.16.gz
iso07u-16.psfu.gz
iso08.08.gz
iso08.14.gz
iso08.16.gz
iso09.08.gz
iso09.14.gz
iso09.16.gz
iso10.08.gz
iso10.14.gz
iso10.16.gz
koi8-14.psf.gz
koi8c-8x16.gz
koi8r-8x14.gz
koi8r-8x16.gz
koi8r-8x8.gz
koi8r.8x8.psfu.gz
koi8u_8x14.psfu.gz
koi8u_8x16.psfu.gz
koi8u_8x8.psfu.gz
lat0-08.psfu.gz
lat0-10.psfu.gz
lat0-12.psfu.gz
lat0-14.psfu.gz
lat0-16.psfu.gz
lat0-sun16.psfu.gz
lat1-08.psfu.gz
lat1-10.psfu.gz
lat1-12.psfu.gz
lat1-14.psfu.gz
lat1-16.psfu.gz
lat2-08.psfu.gz
lat2-10.psfu.gz
lat2-12.psfu.gz
lat2-14.psfu.gz
lat2-16.psfu.gz
lat2a-16.psfu.gz
lat2-sun16.psfu.gz
Lat2-Terminus16.psfu.gz
lat4-08.psfu.gz
lat4-10.psfu.gz
lat4-12.psfu.gz
lat4-14.psfu.gz
lat4-16.psfu.gz
lat4-16+.psfu.gz
lat4-19.psfu.gz
lat4a-08.psfu.gz
lat4a-10.psfu.gz
lat4a-12.psfu.gz
lat4a-14.psfu.gz
lat4a-16.psfu.gz
lat4a-16+.psfu.gz
lat4a-19.psfu.gz
lat5-12.psfu.gz
lat5-14.psfu.gz
lat5-16.psfu.gz
lat7-14.psfu.gz
lat7a-14.psfu.gz
lat7a-16.psf.gz
lat9-08.psf.gz
lat9-10.psf.gz
lat9-12.psf.gz
lat9-14.psf.gz
lat9-16.psf.gz
lat9u-08.psfu.gz
lat9u-10.psfu.gz
lat9u-12.psfu.gz
lat9u-14.psfu.gz
lat9u-16.psfu.gz
lat9v-08.psfu.gz
lat9v-10.psfu.gz
lat9v-12.psfu.gz
lat9v-14.psfu.gz
lat9v-16.psfu.gz
lat9w-08.psfu.gz
lat9w-10.psfu.gz
lat9w-12.psfu.gz
lat9w-14.psfu.gz
lat9w-16.psfu.gz
LatArCyrHeb-08.psfu.gz
LatArCyrHeb-14.psfu.gz
LatArCyrHeb-16.psfu.gz
LatArCyrHeb-16+.psfu.gz
LatArCyrHeb-19.psfu.gz
latarcyrheb-sun16.psfu.gz
latarcyrheb-sun32.psfu.gz
LatGrkCyr-12x22.psfu.gz
LatGrkCyr-8x16.psfu.gz
LatKaCyrHeb-14.psfu.gz
Mik_8x16.gz
pancyrillic.f16.psfu.gz
partialfonts
README.12x22
README.Arabic
README.cp1250
README.cybercafe
README.Cyrillic
README.drdos
README.Ethiopic
README.eurlatgr
README.eurlatgr.mappings
README.Greek
README.Hebrew
README.lat0
README.Lat2-Terminus16
README.lat7
README.lat9
README.LatGrkCyr
README.psfu
README.Sun
ruscii_8x16.psfu.gz
ruscii_8x8.psfu.gz
sun12x22.psfu.gz
t850b.fnt.gz
tcvn8x16.psf.gz
t.fnt.gz
UniCyr_8x14.psf.gz
UniCyr_8x16.psf.gz
UniCyr_8x8.psf.gz
UniCyrExt_8x16.psf.gz
viscii10-8x16.psfu.gz
eof
  esac
  return
}
setfont() { return; }
showconsolefont() {
  cat <<"eof"
!"#$%&'()*+,-./0
123456789:;<=>?@
ABCDEFGHIJKLMNOP
QRSTUVWXYZ[\]^_`
!"#$%&'()*+,-./0
123456789:;<=>?@
ABCDEFGHIJKLMNOP
QRSTUVWXYZ[\]^_`

!"#$%&'()*+,-./0
123456789:;<=>?@
ABCDEFGHIJKLMNOP
QRSTUVWXYZ[\]^_`
!"#$%&'()*+,-./0
123456789:;<=>?@
ABCDEFGHIJKLMNOP
QRSTUVWXYZ[\]^_`
eof
}
locale-gen() { return; }
pacstrap() {
    echo "Installing..."
    return
}
ping() { echo "PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=128 time=20.2 ms

--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 20.208/20.208/20.208/0.000 ms"; }
fdisk() { return; }
gdisk() { return; }
mkswap() { return; }
swapon() { return; }
mkfs.ext4() { return; }
mkfs.fat() { return; }
mount() { return; }
genfstab() { return; }
fstab_file="/dev/null"
cp() { return; }
ln() { return; }
hwclock() { return; }
ip() { return; }
pacman() { return; }
mkinitcpio() { return; }
visudo() { return; }
sh() { return; }
mkdir() { return; }
useradd() { return; }
sudo() { return; }
git() { return; }
makepkg() { return; }

#AUR-helpers:
aurman() { return; }
aurutils() { return; }
bauerbill() { return; }
pakku() { return; }
pikaur() { return; }
PKGBUILDer() { return; }
auracle-git() { return; }
package-query() { return; }
repoctl() { return; }
trizen() { return; }
yay() { return; }
naaman() { return; }
aura() { return; }
pbget() { return; }
yaah() { return; }
aurel-git() { return; }
cower() { return; }
pacaur() { return; }
wrapaur() { return; }
spinach() { return; }
aurget() { return; }
burgaur() { return; }
packer() { return; }
yaourt() { return; }
git() { return; }
chown() { return; }

test=true

# source settings.sh
# format_the_partitions
# exit
source arch.sh