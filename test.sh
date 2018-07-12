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
  cat <<eof
                      Local time: Thu 2018-04-12 18:22:58 CEST
                  Universal time: Thu 2018-04-12 16:22:58 UTC
                        RTC time: Thu 2018-04-12 16:22:58
                       Time zone: Europe/Zurich (CEST, +0200)
       System clock synchronized: yes
systemd-timesyncd.service active: yes
                 RTC in local TZ: no
eof
}
lsblk() {
  cat <<eof
NAME   TYPE FSTYPE  LABEL             SIZE MOUNTPOINT HOTPLUG
/dev/sda disk                             128G                  0
|-sda1   part swap                          4G [SWAP]           0
\`-sda2   part ext4                        124G /                0
/dev/sdc disk                            14.4G                  1
\`-sdc1   part ntfs    16GB-Patriot-Tab   14.4G                  1
/dev/sr0 rom  iso9660 ARCH_201804         556M                  1
eof
}
parted() { return; }
ls() {
  case "$1" in
    /usr/share/kbd/keymaps/*)
      cat <<eof
/usr/share/kbd/keymaps/amiga/amiga-de.map.gz
/usr/share/kbd/keymaps/amiga/amiga-us.map.gz
/usr/share/kbd/keymaps/atari/atari-de.map.gz
/usr/share/kbd/keymaps/atari/atari-se.map.gz
/usr/share/kbd/keymaps/atari/atari-uk-falcon.map.gz
/usr/share/kbd/keymaps/atari/atari-us.map.gz
/usr/share/kbd/keymaps/i386/azerty/azerty.map.gz
/usr/share/kbd/keymaps/i386/azerty/be-latin1.map.gz
/usr/share/kbd/keymaps/i386/azerty/fr.map.gz
/usr/share/kbd/keymaps/i386/azerty/fr-latin1.map.gz
/usr/share/kbd/keymaps/i386/azerty/fr-latin9.map.gz
/usr/share/kbd/keymaps/i386/azerty/fr-pc.map.gz
/usr/share/kbd/keymaps/i386/azerty/wangbe.map.gz
/usr/share/kbd/keymaps/i386/azerty/wangbe2.map.gz
/usr/share/kbd/keymaps/i386/bepo/fr-bepo.map.gz
/usr/share/kbd/keymaps/i386/bepo/fr-bepo-latin9.map.gz
/usr/share/kbd/keymaps/i386/carpalx/carpalx.map.gz
/usr/share/kbd/keymaps/i386/carpalx/carpalx-full.map.gz
/usr/share/kbd/keymaps/i386/colemak/colemak.map.gz
/usr/share/kbd/keymaps/i386/dvorak/ANSI-dvorak.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-ca-fr.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-es.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-fr.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-l.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-la.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-programmer.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-r.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-ru.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-sv-a1.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-sv-a5.map.gz
/usr/share/kbd/keymaps/i386/dvorak/dvorak-uk.map.gz
/usr/share/kbd/keymaps/i386/dvorak/no-dvorak.map.gz
/usr/share/kbd/keymaps/i386/fgGIod/trf-fgGIod.map.gz
/usr/share/kbd/keymaps/i386/fgGIod/tr_f-latin5.map.gz
/usr/share/kbd/keymaps/i386/include/applkey.map.gz
/usr/share/kbd/keymaps/i386/include/backspace.map.gz
/usr/share/kbd/keymaps/i386/include/ctrl.map.gz
/usr/share/kbd/keymaps/i386/include/euro.map.gz
/usr/share/kbd/keymaps/i386/include/euro1.map.gz
/usr/share/kbd/keymaps/i386/include/euro2.map.gz
/usr/share/kbd/keymaps/i386/include/keypad.map.gz
/usr/share/kbd/keymaps/i386/include/unicode.map.gz
/usr/share/kbd/keymaps/i386/include/windowkeys.map.gz
/usr/share/kbd/keymaps/i386/olpc/es-olpc.map.gz
/usr/share/kbd/keymaps/i386/olpc/pt-olpc.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bashkir.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bg-cp855.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bg-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bg_bds-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bg_bds-utf8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bg_pho-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bg_pho-utf8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/br-abnt.map.gz
/usr/share/kbd/keymaps/i386/qwerty/br-abnt2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/br-latin1-abnt2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/br-latin1-us.map.gz
/usr/share/kbd/keymaps/i386/qwerty/by.map.gz
/usr/share/kbd/keymaps/i386/qwerty/bywin-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/by-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/cf.map.gz
/usr/share/kbd/keymaps/i386/qwerty/cz.map.gz
/usr/share/kbd/keymaps/i386/qwerty/cz-cp1250.map.gz
/usr/share/kbd/keymaps/i386/qwerty/cz-lat2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/cz-lat2-prog.map.gz
/usr/share/kbd/keymaps/i386/qwerty/defkeymap.map.gz
/usr/share/kbd/keymaps/i386/qwerty/defkeymap_V1.0.map.gz
/usr/share/kbd/keymaps/i386/qwerty/dk.map.gz
/usr/share/kbd/keymaps/i386/qwerty/dk-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/emacs.map.gz
/usr/share/kbd/keymaps/i386/qwerty/emacs2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/es.map.gz
/usr/share/kbd/keymaps/i386/qwerty/es-cp850.map.gz
/usr/share/kbd/keymaps/i386/qwerty/et.map.gz
/usr/share/kbd/keymaps/i386/qwerty/et-nodeadkeys.map.gz
/usr/share/kbd/keymaps/i386/qwerty/fi.map.gz
/usr/share/kbd/keymaps/i386/qwerty/gr.map.gz
/usr/share/kbd/keymaps/i386/qwerty/gr-pc.map.gz
/usr/share/kbd/keymaps/i386/qwerty/hu101.map.gz
/usr/share/kbd/keymaps/i386/qwerty/il.map.gz
/usr/share/kbd/keymaps/i386/qwerty/il-heb.map.gz
/usr/share/kbd/keymaps/i386/qwerty/il-phonetic.map.gz
/usr/share/kbd/keymaps/i386/qwerty/is-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/is-latin1-us.map.gz
/usr/share/kbd/keymaps/i386/qwerty/it.map.gz
/usr/share/kbd/keymaps/i386/qwerty/it2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/it-ibm.map.gz
/usr/share/kbd/keymaps/i386/qwerty/jp106.map.gz
/usr/share/kbd/keymaps/i386/qwerty/kazakh.map.gz
/usr/share/kbd/keymaps/i386/qwerty/kyrgyz.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ky_alt_sh-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/la-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/lt.baltic.map.gz
/usr/share/kbd/keymaps/i386/qwerty/lt.l4.map.gz
/usr/share/kbd/keymaps/i386/qwerty/lt.map.gz
/usr/share/kbd/keymaps/i386/qwerty/lv.map.gz
/usr/share/kbd/keymaps/i386/qwerty/lv-tilde.map.gz
/usr/share/kbd/keymaps/i386/qwerty/mk.map.gz
/usr/share/kbd/keymaps/i386/qwerty/mk0.map.gz
/usr/share/kbd/keymaps/i386/qwerty/mk-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/mk-utf.map.gz
/usr/share/kbd/keymaps/i386/qwerty/nl.map.gz
/usr/share/kbd/keymaps/i386/qwerty/nl2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/no.map.gz
/usr/share/kbd/keymaps/i386/qwerty/no-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pc110.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pl.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pl1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pl2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pl3.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pl4.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pt-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/pt-latin9.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ro.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ro_std.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ro_win.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru2.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru3.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru4.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_alt-CP1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_alt-KOI8-R.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_alt-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_alt_sh-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_cplk-CP1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_cplk-KOI8-R.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_cplk-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_ctrl-CP1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_ctrl-KOI8-R.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_ctrl-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_ct_sh-CP1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_ct_sh-KOI8-R.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ruwin_ct_sh-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru-ms.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru-yawerty.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ru_win.map.gz
/usr/share/kbd/keymaps/i386/qwerty/se-fi-ir209.map.gz
/usr/share/kbd/keymaps/i386/qwerty/se-fi-lat6.map.gz
/usr/share/kbd/keymaps/i386/qwerty/se-ir209.map.gz
/usr/share/kbd/keymaps/i386/qwerty/se-lat6.map.gz
/usr/share/kbd/keymaps/i386/qwerty/sk-prog-qwerty.map.gz
/usr/share/kbd/keymaps/i386/qwerty/sk-qwerty.map.gz
/usr/share/kbd/keymaps/i386/qwerty/sr-cy.map.gz
/usr/share/kbd/keymaps/i386/qwerty/sv-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwerty/tj_alt-UTF8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/tralt.map.gz
/usr/share/kbd/keymaps/i386/qwerty/trf.map.gz
/usr/share/kbd/keymaps/i386/qwerty/trq.map.gz
/usr/share/kbd/keymaps/i386/qwerty/tr_q-latin5.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ttwin_alt-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ttwin_cplk-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ttwin_ctrl-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ttwin_ct_sh-UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ua.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ua-cp1251.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ua-utf.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ua-utf-ws.map.gz
/usr/share/kbd/keymaps/i386/qwerty/ua-ws.map.gz
/usr/share/kbd/keymaps/i386/qwerty/uk.map.gz
/usr/share/kbd/keymaps/i386/qwerty/us.map.gz
/usr/share/kbd/keymaps/i386/qwerty/us-acentos.map.gz
/usr/share/kbd/keymaps/i386/qwertz/croat.map.gz
/usr/share/kbd/keymaps/i386/qwertz/cz-qwertz.map.gz
/usr/share/kbd/keymaps/i386/qwertz/cz-us-qwertz.map.gz
/usr/share/kbd/keymaps/i386/qwertz/de.map.gz
/usr/share/kbd/keymaps/i386/qwertz/de-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwertz/de-latin1-nodeadkeys.map.gz
/usr/share/kbd/keymaps/i386/qwertz/de-mobii.map.gz
/usr/share/kbd/keymaps/i386/qwertz/de_CH-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwertz/de_alt_UTF-8.map.gz
/usr/share/kbd/keymaps/i386/qwertz/fr_CH.map.gz
/usr/share/kbd/keymaps/i386/qwertz/fr_CH-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwertz/hu.map.gz
/usr/share/kbd/keymaps/i386/qwertz/sg.map.gz
/usr/share/kbd/keymaps/i386/qwertz/sg-latin1.map.gz
/usr/share/kbd/keymaps/i386/qwertz/sg-latin1-lk450.map.gz
/usr/share/kbd/keymaps/i386/qwertz/sk-prog-qwertz.map.gz
/usr/share/kbd/keymaps/i386/qwertz/sk-qwertz.map.gz
/usr/share/kbd/keymaps/i386/qwertz/slovene.map.gz
/usr/share/kbd/keymaps/mac/all/mac-be.map.gz
/usr/share/kbd/keymaps/mac/all/mac-de-latin1.map.gz
/usr/share/kbd/keymaps/mac/all/mac-de-latin1-nodeadkeys.map.gz
/usr/share/kbd/keymaps/mac/all/mac-de_CH.map.gz
/usr/share/kbd/keymaps/mac/all/mac-dk-latin1.map.gz
/usr/share/kbd/keymaps/mac/all/mac-dvorak.map.gz
/usr/share/kbd/keymaps/mac/all/mac-es.map.gz
/usr/share/kbd/keymaps/mac/all/mac-fi-latin1.map.gz
/usr/share/kbd/keymaps/mac/all/mac-fr.map.gz
/usr/share/kbd/keymaps/mac/all/mac-fr_CH-latin1.map.gz
/usr/share/kbd/keymaps/mac/all/mac-it.map.gz
/usr/share/kbd/keymaps/mac/all/mac-pl.map.gz
/usr/share/kbd/keymaps/mac/all/mac-pt-latin1.map.gz
/usr/share/kbd/keymaps/mac/all/mac-se.map.gz
/usr/share/kbd/keymaps/mac/all/mac-template.map.gz
/usr/share/kbd/keymaps/mac/all/mac-uk.map.gz
/usr/share/kbd/keymaps/mac/all/mac-us.map.gz
/usr/share/kbd/keymaps/mac/include/mac-euro.map.gz
/usr/share/kbd/keymaps/mac/include/mac-euro2.map.gz
/usr/share/kbd/keymaps/sun/sundvorak.map.gz
/usr/share/kbd/keymaps/sun/sunkeymap.map.gz
/usr/share/kbd/keymaps/sun/sunt4-es.map.gz
/usr/share/kbd/keymaps/sun/sunt4-fi-latin1.map.gz
/usr/share/kbd/keymaps/sun/sunt4-no-latin1.map.gz
/usr/share/kbd/keymaps/sun/sunt5-cz-us.map.gz
/usr/share/kbd/keymaps/sun/sunt5-de-latin1.map.gz
/usr/share/kbd/keymaps/sun/sunt5-es.map.gz
/usr/share/kbd/keymaps/sun/sunt5-fi-latin1.map.gz
/usr/share/kbd/keymaps/sun/sunt5-fr-latin1.map.gz
/usr/share/kbd/keymaps/sun/sunt5-ru.map.gz
/usr/share/kbd/keymaps/sun/sunt5-uk.map.gz
/usr/share/kbd/keymaps/sun/sunt5-us-cz.map.gz
/usr/share/kbd/keymaps/sun/sunt6-uk.map.gz
/usr/share/kbd/keymaps/sun/sun-pl.map.gz
/usr/share/kbd/keymaps/sun/sun-pl-altgraph.map.gz
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
tee() { return; }
reboot() { return; }
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
genfstab() { cat << eof
# /dev/sda3
UUID=<uuid>	          /         	ext4      	rw,relatime	0 1

# efivarfs
efivarfs            	/sys/firmware/efi/efivars	efivarfs  	rw,nosuid,nodev,noexec	0 0

# bpf
bpf                 	/sys/fs/bpf	bpf       	rw,nosuid,nodev,noexec,mode=700	0 0

# gvfsd-fuse
gvfsd-fuse          	/run/user/1000/gvfs	fuse.gvfsd-fuse	rw,nosuid,nodev,user_id=1000,group_id=1000	0 0

# /dev/sda1
UUID=18C8-A366      	/boot     	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro	0 2

# /dev/sda2
UUID=<uuid>	          none      	swap      	defaults,pri=-2	0 0
eof
}
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
reflector() { cat << eof
################################################################################
################# Arch Linux mirrorlist generated by Reflector #################
################################################################################

# With:       reflector -c Austria -c Belarus -c Belgium -c BosniaandHerzegovina -c Bulgaria -c China -c Croatia -c Czechia -c Denmark -c Finland -c France -c Germany -c Greece -c HongKong -c Hungary -c Iceland -c Ireland -c Italy -c Japan -c Luxembourg -c Macedonia -c Netherlands -c NewCaledonia -c Norway -c Poland -c Portugal -c Romania -c Serbia -c Slovakia -c Slovenia -c SouthKorea -c Spain -c Sweden -c Switzerland -c UnitedKingdom -p https -f 50 -l 50 --sort delay --save /etc/pacman.d/mirrorlist
# When:       2018-07-11 13:11:05 UTC
# From:       https://www.archlinux.org/mirrors/status/json/
# Retrieved:  2018-07-11 13:09:58 UTC
# Last Check: 2018-07-11 13:04:25 UTC

Server = https://mirror.f4st.host/archlinux/$repo/os/$arch
Server = https://ftp.sh.cvut.cz/arch/$repo/os/$arch
Server = https://arch.jensgutermuth.de/$repo/os/$arch
Server = https://mirror.pseudoform.org/$repo/os/$arch
Server = https://mirrors.uni-plovdiv.net/archlinux/$repo/os/$arch
Server = https://jpn.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirrors.n-ix.net/archlinux/$repo/os/$arch
Server = https://mirror.hactar.xyz/$repo/os/$arch
Server = https://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch
Server = https://archlinux.thelinuxnetworx.rocks/$repo/os/$arch
Server = https://archlinux.dynamict.se/$repo/os/$arch
Server = https://packages.oth-regensburg.de/archlinux/$repo/os/$arch
Server = https://mirror.orbit-os.com/archlinux/$repo/os/$arch
Server = https://mirrors.niyawe.de/archlinux/$repo/os/$arch
Server = https://mirror.ubrco.de/archlinux/$repo/os/$arch
Server = https://mirror.neuf.no/archlinux/$repo/os/$arch
Server = https://mirror.osbeck.com/archlinux/$repo/os/$arch
Server = https://archlinux.beccacervello.it/archlinux/$repo/os/$arch
Server = https://repo.itmettke.de/archlinux/$repo/os/$arch
Server = https://mirror.fra10.de.leaseweb.net/archlinux/$repo/os/$arch
Server = https://ftp.fau.de/archlinux/$repo/os/$arch
Server = https://mirror.srv.fail/archlinux/$repo/os/$arch
Server = https://mirrors.dotsrc.org/archlinux/$repo/os/$arch
Server = https://mirrors.phx.ms/arch/$repo/os/$arch
Server = https://archlinux.thaller.ws/$repo/os/$arch
Server = https://mirror.one.com/archlinux/$repo/os/$arch
Server = https://fooo.biz/archlinux/$repo/os/$arch
Server = https://ftp.rnl.tecnico.ulisboa.pt/pub/archlinux/$repo/os/$arch
Server = https://mirror.reisenbauer.ee/archlinux/$repo/os/$arch
Server = https://archlinux.mailtunnel.eu/$repo/os/$arch
Server = https://mirror.ams1.nl.leaseweb.net/archlinux/$repo/os/$arch
Server = https://mirror.bethselamin.de/$repo/os/$arch
Server = https://pkg.adfinis-sygroup.ch/archlinux/$repo/os/$arch
Server = https://mirror.dkm.cz/archlinux/$repo/os/$arch
Server = https://mirror.jankoppe.de/archlinux/$repo/os/$arch
Server = https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch
Server = https://mirror.homelab.no/archlinux/$repo/os/$arch
Server = https://mirror.metalgamer.eu/archlinux/$repo/os/$arch
Server = https://mirror.system.is/arch/$repo/os/$arch
Server = https://mirror.thekinrar.fr/archlinux/$repo/os/$arch
Server = https://ftp.lysator.liu.se/pub/archlinux/$repo/os/$arch
Server = https://archimonde.ts.si/archlinux/$repo/os/$arch
Server = https://mirror.netcologne.de/archlinux/$repo/os/$arch
Server = https://mirrors.nxthost.com/archlinux/$repo/os/$arch
Server = https://archlinux.vi-di.fr/$repo/os/$arch
Server = https://mirror.armbrust.me/archlinux/$repo/os/$arch
Server = https://mirror.t-home.mk/archlinux/$repo/os/$arch
Server = https://arch.yourlabs.org/$repo/os/$arch
Server = https://mirrors.shu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.cat.net/archlinux/$repo/os/$arch
eof
}

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

source arch.sh